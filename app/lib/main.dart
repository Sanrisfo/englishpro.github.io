import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart'; // 🆕 Supabase
// import 'config/firebase_config.dart'; // ❌ DEPRECATED - Commented for migration
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// Punto de entrada principal de la aplicación EnglishPro.
///
/// Esta función se encarga de realizar las inicializaciones críticas antes de
/// que la aplicación se ejecute, incluyendo:
///
/// 1.  **Asegurar la inicialización de los bindings de Flutter.**
/// 2.  **Configurar la UI del sistema** para un modo inmersivo, mostrando solo la barra de estado.
/// 3.  **Cargar las variables de entorno** desde el archivo `.env`.
/// 4.  **Inicializar Supabase** para la conexión con el backend.
///
/// Una vez completadas las inicializaciones, se ejecuta el widget raíz [MyApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //by santiago: Esto es para que la barra de navegación del celular se oculte
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top], // solo mostramos la status bar
  );

  // Cargar variables de entorno
  await dotenv.load(fileName: 'assets/env');

  // 🆕 Inicializar Supabase (reemplaza a Firebase)
  await SupabaseConfig.initialize();

  // ❌ DEPRECATED - Firebase initialization commented out
  // await FirebaseConfig.initialize();

  runApp(const MyApp());
}

/// Widget raíz de la aplicación EnglishPro.
///
/// Este widget es el ancestro de todos los demás widgets de la aplicación.
/// Sus responsabilidades principales son:
///
/// 1.  **Proveer el [AuthProvider]** al árbol de widgets usando [ChangeNotifierProvider],
///     permitiendo que el estado de autenticación sea accesible globalmente.
/// 2.  **Configurar el [MaterialApp]**, que define el título de la aplicación, el tema
///     visual (incluyendo colores y tipografía con Google Fonts) y la pantalla inicial.
/// 3.  **Establecer [SplashScreen]** como la pantalla de inicio (`home`), que se
///     encargará de determinar la navegación inicial basada en el estado de autenticación.
class MyApp extends StatelessWidget {
  /// Crea una instancia del widget raíz de la aplicación.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'EnglishPro',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.ptSansTextTheme(Theme.of(context).textTheme),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
