import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/supabase_auth_service.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'teacher_dashboard_screen.dart';

/// Pantalla de inicio de sesión para la aplicación.
///
/// Este widget `Stateful` presenta un formulario para que el usuario ingrese
/// su correo electrónico y contraseña. Utiliza [SupabaseAuthService] para
/// autenticar al usuario y, en caso de éxito, persiste la sesión y redirige
/// al panel correspondiente según el rol del usuario (Docente o Estudiante).
class LoginScreen extends StatefulWidget {
  /// Un servicio de autenticación que puede ser inyectado para facilitar las pruebas.
  ///
  /// Si se deja en `null`, se crea una instancia por defecto de [SupabaseAuthService].
  final SupabaseAuthService? authService;

  /// Crea una instancia de la pantalla de inicio de sesión.
  const LoginScreen({super.key, this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Clave global para el `Form` que permite la validación de los campos.
  final _formKey = GlobalKey<FormState>();

  /// Controlador para el campo de texto del correo electrónico.
  final _emailController = TextEditingController();

  /// Controlador para el campo de texto de la contraseña.
  final _passwordController = TextEditingController();

  /// Indica si una operación de inicio de sesión está en progreso.
  bool _isLoading = false;

  /// Controla la visibilidad de la contraseña en su campo de texto.
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Gestiona el proceso completo de inicio de sesión.
  ///
  /// 1.  Valida el formulario.
  /// 2.  Muestra un indicador de carga.
  /// 3.  Llama al método `login` de [SupabaseAuthService].
  /// 4.  Si el inicio de sesión es exitoso:
  ///     a. Persiste el token de sesión y el rol del usuario en [SharedPreferences].
  ///     b. Actualiza el [AuthProvider] con los datos del usuario y el token.
  ///     c. Navega a [TeacherDashboardScreen] si el rol es 'Docente' o a [HomeScreen] en caso contrario.
  /// 5.  Si falla, muestra un `SnackBar` con el mensaje de error.
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = widget.authService ?? SupabaseAuthService();
    final result = await authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    if (result['success'] == true) {
      final user = result['user'] as User;
      final session = result['session'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', session?.accessToken ?? '');
      await prefs.setString('user_role', user.rol);
      await prefs.setBool(
        'user_is_teacher',
        user.rol == 'Docente' || user.esDocente,
      );

      Provider.of<AuthProvider>(
        context,
        listen: false,
      ).setUser(user, session?.accessToken ?? '');

      // Redirigir según el rol del usuario.
      if (user.rol == 'Docente') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor: const Color(0xFFD9232A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Image.asset('assets/images/logo_completo.png', height: 120),
                const SizedBox(height: 8),
                const Text(
                  '¡Bienvenido de vuelta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor, ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes una cuenta?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
