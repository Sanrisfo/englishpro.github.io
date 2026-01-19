import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'courses/toefl_screen.dart';
import 'courses/ielts_screen.dart';
import 'courses/business_english_screen.dart';
import 'courses/english_in_action_screen.dart';
import 'courses_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/supabase_config.dart';
import '../providers/auth_provider.dart';

/// Pantalla principal del estudiante con acceso rápido a módulos y cursos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Cierra la sesión local y redirige al inicio de sesión.
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_is_teacher');

    if (!context.mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _load() async {
    try {
      final userName = await supabase.from('usuarios').select('id_usuario');
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.watch<AuthProvider>().user?.nombreCompleto ??
                          "Student",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23408E),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'logout') {
                      _logout(context);
                    }
                  },
                  offset: const Offset(0, 60),
                  color: Color(0xFFFBFBFB),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),

                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Color(0xFFD9232A)),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(color: Color(0xFFD9232A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFD9D9D9),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                Image.asset('assets/images/logo_completo.png', height: 100),
                const SizedBox(height: 16),
                const Text(
                  'Your fluency starts here.',
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),

                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCourseCard(
                        'TOEFL',
                        'assets/images/icono_toefl_new.png',
                        const Color(0xFFD9232A),
                      ),
                      _buildCourseCard(
                        'IELTS',
                        'assets/images/icono_ielts.png',
                        const Color(0xFF23408E),
                      ),
                      _buildCourseCard(
                        'Business en.',
                        'assets/images/icono_business.png',
                        const Color(0xFFB02224),
                      ),
                      _buildCourseCard(
                        'En. in action',
                        'assets/images/icono_conversational.png',
                        const Color(0xFF1F3A89),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de curso con imagen y navegación hacia la pantalla del curso.
  Widget _buildCourseCard(String title, String imagePath, Color color) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => _navigateToCourse(context, title),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      title,
                      style: GoogleFonts.ptSans(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Image.asset(
                    imagePath,
                    height: 70,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Enruta a la pantalla correspondiente según el nombre del curso.
  void _navigateToCourse(BuildContext context, String courseTitle) {
    Widget screen;

    switch (courseTitle) {
      case 'TOEFL':
        screen = const ToeflScreen();
        break;
      case 'IELTS':
        screen = const IeltsScreen();
        break;
      case 'Business en.':
        screen = const BusinessEnglishScreen();
        break;
      case 'En. in action':
        screen = const EnglishInActionScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
