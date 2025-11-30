/// Pantalla de arranque que muestra el logotipo y resuelve navegación
/// inicial según la existencia de sesión y el rol del usuario.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'teacher_dashboard_screen.dart';
import '../config/supabase_config.dart';

/// Splash con animación breve y enrutamiento condicional.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Duración de la animación de llenado
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Curva de animación suave
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });
  }

  /// Verifica sesión y rol para decidir la primera pantalla.
  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 0));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    String? role = prefs.getString('user_role');
    bool? isTeacher = prefs.getBool('user_is_teacher');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Backfill role from Supabase if not persisted (handles old sessions)
      if (isTeacher == null && (role == null || role.isEmpty)) {
        try {
          final current = supabase.auth.currentUser;
          if (current != null) {
            final data = await supabase
                .from('usuarios')
                .select('rol, es_docente')
                .eq('supabase_uid', current.id)
                .single();
            role = (data['rol'] as String?) ?? '';
            isTeacher = (data['es_docente'] as bool?) ?? (role == 'Docente');
            // Persist for next launches
            await prefs.setString('user_role', role!);
            await prefs.setBool('user_is_teacher', isTeacher!);
          }
        } catch (_) {
          // Silently continue; default to student if unknown
        }
      }

      // Route based on final role
      if (isTeacher == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _fillAnimation,
          builder: (context, child) {
            return SizedBox(
              width: 250,
              height: 100,
              child: Stack(
                children: [
                  ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: _fillAnimation.value,
                      child: Image.asset(
                        'assets/images/logo_completo.png',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
