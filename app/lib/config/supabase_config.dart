import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Clase de configuración para inicializar el cliente de Supabase.
///
/// Esta clase centraliza la lógica de inicialización de Supabase,
/// obteniendo las credenciales necesarias desde un archivo `.env`.
///
/// ### Requisitos:
///
/// Se debe crear un archivo `.env` en el directorio `app/` con el siguiente formato:
///
/// ```env
/// SUPABASE_URL=https://tu-url-de-supabase.supabase.co
/// SUPABASE_ANON_KEY=tu-anon-key-de-supabase
/// ```
///
/// ### Ejemplo de uso:
///
/// La inicialización debe realizarse en el `main()` de la aplicación antes de
/// ejecutar `runApp()`.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Cargar variables de entorno
///   await dotenv.load(fileName: '.env');
///
///   // Inicializar Supabase
///   await SupabaseConfig.initialize();
///
///   runApp(const MyApp());
/// }
/// ```
class SupabaseConfig {
  /// Inicializa la instancia global de [Supabase] con las credenciales
  /// del archivo `.env`.
  ///
  /// Lanza una [Exception] si las variables `SUPABASE_URL` o `SUPABASE_ANON_KEY`
  /// no se encuentran en el archivo `.env`.
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Faltan las credenciales de Supabase en el archivo .env. '
        'Asegúrate de añadir SUPABASE_URL y SUPABASE_ANON_KEY.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }
}

/// Instancia global del cliente de Supabase.
///
/// Después de llamar a `SupabaseConfig.initialize()`, esta variable puede ser
/// utilizada en toda la aplicación para interactuar con la base de datos,
/// autenticación, almacenamiento y funciones de Supabase.
///
/// ### Ejemplo de consulta:
///
/// ```dart
/// final response = await supabase.from('cursos').select();
/// ```
final supabase = Supabase.instance.client;
