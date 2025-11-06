# 📱 APP FLUTTER - EnglishPro

**Estructura completa del código Flutter, servicios, pantallas y flujos**

---

## 📊 Resumen

- **Framework**: Flutter 3.35.4
- **Lenguaje**: Dart 3.9.2+
- **Total archivos Dart**: 37+
- **Pantallas**: 13+
- **Modelos**: 8
- **Servicios**: 4
- **Widgets**: 3+

---

## 📁 Estructura de Carpetas

```
app/
├── lib/
│   ├── main.dart                    # Entry point
│   │
│   ├── config/                      # Configuración
│   │   ├── supabase_config.dart    # ✅ Config Supabase
│   │   └── firebase_config.dart    # ❌ DEPRECATED
│   │
│   ├── models/                      # Modelos de datos (8)
│   │   ├── user.dart               # Usuario (Supabase compatible)
│   │   ├── user_model.dart         # Usuario (legacy)
│   │   ├── course_model.dart
│   │   ├── skill_model.dart
│   │   ├── material_model.dart
│   │   ├── question_model.dart
│   │   ├── progress_model.dart
│   │   ├── plan_model.dart
│   │   ├── notification.dart
│   │   └── models.dart             # Barrel file
│   │
│   ├── services/                    # Servicios (4)
│   │   ├── supabase_auth_service.dart       # ✅ Auth
│   │   ├── supabase_storage_service.dart    # ✅ Storage
│   │   ├── api_service.dart                 # Backend API (futuro)
│   │   └── storage_service.dart             # ❌ DEPRECATED
│   │
│   ├── providers/                   # State management (1)
│   │   └── auth_provider.dart
│   │
│   ├── screens/                     # Pantallas (13+)
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── teacher_dashboard_screen.dart
│   │   ├── courses_list_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── quiz_results_screen.dart
│   │   ├── progress_dashboard_screen.dart
│   │   ├── subscription_plans_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── manual_grading_screen.dart
│   │   ├── teacher_materials_screen.dart
│   │   └── courses/
│   │       ├── toefl_screen.dart
│   │       ├── ielts_screen.dart
│   │       ├── business_english_screen.dart
│   │       └── english_in_action_screen.dart
│   │
│   └── widgets/                     # Componentes reutilizables (3+)
│       ├── audio_recorder_widget.dart
│       ├── video_player_widget.dart
│       └── pdf_viewer_widget.dart
│
├── assets/                          # Recursos estáticos
│   ├── images/
│   ├── animations/
│   ├── audio/
│   ├── videos/
│   ├── pdfs/
│   └── icons/
│
├── android/                         # Configuración Android
├── ios/                             # Configuración iOS
├── web/                             # Configuración Web
│
├── .env                            # Credenciales Supabase
├── pubspec.yaml                    # Dependencias
└── pubspec.lock                    # Versiones exactas (EN GIT)
```

---

## 🚀 Entry Point - main.dart

**Archivo:** `app/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar variables de entorno (.env)
  await dotenv.load(fileName: '.env');

  // 2. Inicializar Supabase
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'EnglishPro',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
```

**Responsabilidades:**
1. Cargar `.env` (credenciales Supabase)
2. Inicializar Supabase
3. Configurar Provider (estado global)
4. Configurar tema Material Design 3
5. Mostrar SplashScreen

---

## ⚙️ Configuración - config/

### supabase_config.dart

**Archivo:** `app/lib/config/supabase_config.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

**Qué hace:**
- Lee credenciales de `.env`
- Inicializa cliente Supabase
- Proporciona instancia singleton

**Usado en:** Todos los servicios que acceden a Supabase

---

## 📦 Modelos - models/

### 1. user.dart (Supabase compatible)

**Archivo:** `app/lib/models/user.dart`

```dart
class User {
  final int idUsuario;
  final String nombreCompleto;
  final String email;
  final String? profesion;
  final int idPlan;
  final bool esDocente;
  final String rol;
  final DateTime fechaRegistro;
  final String? firebaseUid;
  final bool emailVerificado;

  User({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.email,
    this.profesion,
    required this.idPlan,
    required this.esDocente,
    required this.rol,
    required this.fechaRegistro,
    this.firebaseUid,
    required this.emailVerificado,
  });

  // Crear desde JSON de Supabase
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      idUsuario: map['ID_Usuario'] ?? 0,
      nombreCompleto: map['Nombre_Completo'] ?? '',
      email: map['Email'] ?? '',
      profesion: map['Profesion'],
      idPlan: map['ID_Plan'] ?? 1,
      esDocente: map['Es_Docente'] ?? false,
      rol: map['Rol'] ?? 'Estudiante',
      fechaRegistro: DateTime.parse(map['Fecha_Registro']),
      firebaseUid: map['Firebase_UID'],
      emailVerificado: map['Email_Verificado'] ?? false,
    );
  }

  // Convertir a JSON para Supabase
  Map<String, dynamic> toMap() {
    return {
      'ID_Usuario': idUsuario,
      'Nombre_Completo': nombreCompleto,
      'Email': email,
      'Profesion': profesion,
      'ID_Plan': idPlan,
      'Es_Docente': esDocente,
      'Rol': rol,
      'Email_Verificado': emailVerificado,
    };
  }
}
```

**Usado en:**
- `services/supabase_auth_service.dart`
- `providers/auth_provider.dart`
- Todas las pantallas que muestran info de usuario

---

### 2. course_model.dart

```dart
class Course {
  final int idCurso;
  final String nombreCurso;
  final String? descripcion;
  final String tipoCurso; // 'Examen' o 'Inmersivo'
  final String estiloProgreso; // 'Porcentaje' o 'Modular'
  final String? urlImagen;
  final bool activo;

  Course({...});

  factory Course.fromMap(Map<String, dynamic> map) {...}
  Map<String, dynamic> toMap() {...}
}
```

**Relación con DB:** Tabla `Cursos`

**Usado en:**
- `screens/home_screen.dart` - Listar cursos
- `screens/courses_list_screen.dart`

---

### 3. skill_model.dart

```dart
class Skill {
  final int idHabilidad;
  final int idCurso;
  final String nombreHabilidad; // Writing, Speaking, Listening, Reading
  final String? descripcion;
  final int orden;

  Skill({...});
  factory Skill.fromMap(Map<String, dynamic> map) {...}
}
```

**Relación con DB:** Tabla `Habilidades`

---

### 4. material_model.dart

```dart
class Material {
  final int idMaterial;
  final int idHabilidad;
  final String titulo;
  final String tipoMaterial; // PDF, Video, Audio, Texto, Imagen
  final String? urlRecurso;
  final String? contenidoTexto;
  final int? duracionMinutos;
  final String nivelAcceso; // Freemium, Basico, Pro, Premium

  Material({...});
  factory Material.fromMap(Map<String, dynamic> map) {...}
}
```

**Relación con DB:** Tabla `Materiales_Estudio`

**Usado en:**
- `widgets/pdf_viewer_widget.dart`
- `widgets/video_player_widget.dart`

---

### 5. question_model.dart

```dart
class Question {
  final int idPregunta;
  final int idHabilidad;
  final String textoPregunta;
  final String tipoPregunta; // Multiple Choice, Texto Abierto, Audio Grabacion
  final String? urlAudio;
  final String? urlVideo;
  final String? urlImagen;
  final int puntos;
  final String nivelDificultad;
  final List<Option> opciones; // Opciones de respuesta

  Question({...});
  factory Question.fromMap(Map<String, dynamic> map) {...}
}

class Option {
  final int idOpcion;
  final int idPregunta;
  final String textoOpcion;
  final bool esCorrecta;
  final int orden;

  Option({...});
  factory Option.fromMap(Map<String, dynamic> map) {...}
}
```

**Relación con DB:** Tablas `Preguntas` y `Opciones_Respuesta`

**Usado en:**
- `screens/quiz_screen.dart`

---

### 6. progress_model.dart

```dart
class Progress {
  final int idProgreso;
  final int idUsuario;
  final int idCurso;
  final double avancePorcentaje;
  final int modulosCompletados;
  final int preguntasRespondidas;
  final int preguntasCorrectas;
  final int puntosTotales;
  final DateTime ultimaActividad;

  Progress({...});
  factory Progress.fromMap(Map<String, dynamic> map) {...}
}
```

**Relación con DB:** Tabla `Progreso_Usuarios`

**Usado en:**
- `screens/progress_dashboard_screen.dart`

---

### 7. plan_model.dart

```dart
class Plan {
  final int idPlan;
  final String nombrePlan;
  final double precio;
  final int limitePreguntasPorHabilidad;
  final bool accesoSesionesVivo;
  final int cantidadSesionesVivo;
  final bool accesoSimulacros;
  final int cantidadSimulacros;
  final String? descripcion;

  Plan({...});
  factory Plan.fromMap(Map<String, dynamic> map) {...}
}
```

**Relación con DB:** Tabla `Planes`

**Usado en:**
- `screens/subscription_plans_screen.dart`

---

### 8. notification.dart

```dart
class Notification {
  final int idNotificacion;
  final int idUsuario;
  final String titulo;
  final String mensaje;
  final String tipo; // Info, Retroalimentacion, Pago, Sistema
  final bool leida;
  final DateTime fechaCreacion;

  Notification({...});
  factory Notification.fromMap(Map<String, dynamic> map) {...}
}
```

**Relación con DB:** Tabla `Notificaciones`

**Usado en:**
- `screens/notifications_screen.dart`

---

## 🔧 Servicios - services/

### 1. supabase_auth_service.dart

**Archivo:** `app/lib/services/supabase_auth_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart';

class SupabaseAuthService {
  final supabase = SupabaseConfig.client;

  // REGISTER
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String nombreCompleto,
    String? profesion,
  }) async {
    try {
      // 1. Crear usuario en Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario');
      }

      // 2. Insertar en tabla Usuarios
      final userData = {
        'Nombre_Completo': nombreCompleto,
        'Email': email,
        'Password_Hash': 'managed_by_supabase',
        'Profesion': profesion,
        'ID_Plan': 1, // Freemium por defecto
        'Es_Docente': false,
        'Rol': 'Estudiante',
        'Firebase_UID': authResponse.user!.id,
        'Email_Verificado': false,
      };

      await supabase.from('Usuarios').insert(userData);

      return {
        'success': true,
        'user': authResponse.user,
        'message': 'Usuario creado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Obtener datos completos de tabla Usuarios
      final userData = await supabase
          .from('Usuarios')
          .select()
          .eq('Firebase_UID', response.user!.id)
          .single();

      return {
        'success': true,
        'user': User.fromMap(userData),
        'message': 'Login exitoso',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // USUARIO ACTUAL
  User? getCurrentUser() {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return null;

    // Fetch from Usuarios table
    // (En práctica, usar Provider para cachear)
    return null;
  }

  // VERIFICAR SI ESTÁ LOGUEADO
  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }
}
```

**Métodos:**
- `signUp()` - Registro de usuario
- `signIn()` - Login
- `signOut()` - Logout
- `getCurrentUser()` - Usuario actual
- `isAuthenticated()` - Verificar sesión

**Usado en:**
- `screens/login_screen.dart:80`
- `screens/register_screen.dart:120`
- `providers/auth_provider.dart:30`

---

### 2. supabase_storage_service.dart

**Archivo:** `app/lib/services/supabase_storage_service.dart`

```dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseStorageService {
  final supabase = SupabaseConfig.client;

  // UPLOAD AUDIO (Speaking)
  Future<String?> uploadAudio(File audioFile, int userId) async {
    try {
      final fileName = 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = 'audios/user_$userId/$fileName';

      await supabase.storage.from('englishpro').upload(path, audioFile);

      // Obtener URL pública
      final publicUrl = supabase.storage.from('englishpro').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  // UPLOAD PDF
  Future<String?> uploadPdf(File pdfFile, int userId) async {
    try {
      final fileName = 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = 'pdfs/user_$userId/$fileName';

      await supabase.storage.from('englishpro').upload(path, pdfFile);

      final publicUrl = supabase.storage.from('englishpro').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      print('Error uploading PDF: $e');
      return null;
    }
  }

  // UPLOAD VIDEO
  Future<String?> uploadVideo(File videoFile, int userId) async {
    try {
      final fileName = 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final path = 'videos/user_$userId/$fileName';

      await supabase.storage.from('englishpro').upload(path, videoFile);

      final publicUrl = supabase.storage.from('englishpro').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  // DELETE FILE
  Future<bool> deleteFile(String path) async {
    try {
      await supabase.storage.from('englishpro').remove([path]);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
```

**Métodos:**
- `uploadAudio()` - Subir grabación de Speaking
- `uploadPdf()` - Subir PDF
- `uploadVideo()` - Subir video
- `deleteFile()` - Eliminar archivo

**Usado en:**
- `widgets/audio_recorder_widget.dart:90`
- `screens/teacher_materials_screen.dart:60`

---

### 3. api_service.dart (Backend futuro)

**Archivo:** `app/lib/services/api_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://192.168.1.16:8080/api';

  // PROCESAR PAGO (Stripe)
  Future<Map<String, dynamic>> procesarPago({
    required int userId,
    required int planId,
    required String stripeToken,
  }) async {
    // TODO: Implementar cuando se active backend
    return {'success': false, 'message': 'Backend no disponible'};
  }

  // CALIFICAR AUDIO (OpenAI Whisper)
  Future<Map<String, dynamic>> calificarAudio({
    required String audioUrl,
    required int preguntaId,
  }) async {
    // TODO: Implementar cuando se active backend
    return {'success': false, 'message': 'Backend no disponible'};
  }

  // GENERAR CERTIFICADO PDF
  Future<String?> generarCertificado({
    required int userId,
    required int cursoId,
  }) async {
    // TODO: Implementar cuando se active backend
    return null;
  }
}
```

**Estado:** Preparado para futuro (backend deshabilitado)

---

## 🎨 Providers - providers/

### auth_provider.dart

**Archivo:** `app/lib/providers/auth_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/supabase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  final _authService = SupabaseAuthService();

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (response['success']) {
      _user = response['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    }
  }

  // REGISTER
  Future<bool> register({
    required String email,
    required String password,
    required String nombreCompleto,
    String? profesion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.signUp(
      email: email,
      password: password,
      nombreCompleto: nombreCompleto,
      profesion: profesion,
    );

    _isLoading = false;

    if (response['success']) {
      // Auto login después de registro
      return await login(email, password);
    } else {
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
```

**Usado en:**
- `screens/login_screen.dart`
- `screens/register_screen.dart`
- `screens/home_screen.dart`
- Cualquier pantalla que necesite saber si usuario está logueado

**Patrón:** Provider (ChangeNotifier)

---

## 📱 Pantallas - screens/

### 1. splash_screen.dart

**Responsabilidad:** Mostrar logo mientras verifica sesión

```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(Duration(seconds: 2));

    final authService = SupabaseAuthService();

    if (authService.isAuthenticated()) {
      // Usuario logueado → HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      // No logueado → LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(Icons.school, size: 100),
            SizedBox(height: 20),
            Text('EnglishPro', style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

---

### 2. login_screen.dart

**Responsabilidad:** Pantalla de login

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            authProvider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Ubicación:** `app/lib/screens/login_screen.dart:45`

---

### 3. register_screen.dart

**Responsabilidad:** Pantalla de registro

Similar a `login_screen.dart`, pero con campos adicionales:
- Nombre completo
- Email
- Password
- Profesión (opcional)

**Ubicación:** `app/lib/screens/register_screen.dart:60`

---

### 4. home_screen.dart

**Responsabilidad:** Home de estudiantes - Lista 4 cursos

```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final supabase = SupabaseConfig.client;

    final data = await supabase
        .from('Cursos')
        .select()
        .eq('Activo', true);

    setState(() {
      _courses = (data as List).map((e) => Course.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EnglishPro')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return ListTile(
                  title: Text(course.nombreCurso),
                  subtitle: Text(course.descripcion ?? ''),
                  onTap: () {
                    // Navegar a pantalla del curso
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseScreen(course: course),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
```

**Ubicación:** `app/lib/screens/home_screen.dart:80`

---

### 5. quiz_screen.dart

**Responsabilidad:** Pantalla de quiz/cuestionario

**Flujo:**
1. Cargar preguntas de una habilidad
2. Mostrar pregunta actual
3. Usuario selecciona respuesta
4. Submit respuesta a Supabase
5. Navegar a siguiente pregunta o resultados

**Ubicación:** `app/lib/screens/quiz_screen.dart:120`

---

### 6. teacher_dashboard_screen.dart

**Responsabilidad:** Dashboard para docentes

**Funcionalidades:**
- Ver respuestas pendientes de revisión
- Calificar manualmente
- Ver estadísticas
- Subir materiales

**Ubicación:** `app/lib/screens/teacher_dashboard_screen.dart:25`

---

## 🧩 Widgets - widgets/

### 1. audio_recorder_widget.dart

**Responsabilidad:** Grabar audio para Speaking

```dart
class AudioRecorderWidget extends StatefulWidget {
  final Function(String audioUrl) onAudioRecorded;

  AudioRecorderWidget({required this.onAudioRecorded});

  @override
  _AudioRecorderWidgetState createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final _recorder = Record();
  bool _isRecording = false;
  String? _audioPath;

  Future<void> _startRecording() async {
    await _recorder.start();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    _audioPath = await _recorder.stop();
    setState(() {
      _isRecording = false;
    });

    // Upload a Supabase
    final storageService = SupabaseStorageService();
    final audioUrl = await storageService.uploadAudio(
      File(_audioPath!),
      userId, // ID del usuario actual
    );

    if (audioUrl != null) {
      widget.onAudioRecorded(audioUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          onPressed: _isRecording ? _stopRecording : _startRecording,
        ),
        Text(_isRecording ? 'Grabando...' : 'Presiona para grabar'),
      ],
    );
  }
}
```

**Ubicación:** `app/lib/widgets/audio_recorder_widget.dart:45`

**Packages usados:**
- `record: ^6.1.0`
- `supabase_storage`

---

### 2. video_player_widget.dart

**Responsabilidad:** Reproducir videos de materiales

```dart
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Packages usados:**
- `video_player: ^2.8.0`
- `chewie: ^1.7.0` (controles)

---

### 3. pdf_viewer_widget.dart

**Responsabilidad:** Ver PDFs de materiales

```dart
class PdfViewerWidget extends StatelessWidget {
  final String pdfUrl;

  PdfViewerWidget({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: pdfUrl,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
    );
  }
}
```

**Package usado:**
- `flutter_pdfview: ^1.3.0`

---

## 📦 Dependencias (pubspec.yaml)

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Navigation
  go_router: ^13.0.0

  # State Management
  provider: ^6.1.0

  # HTTP
  http: ^1.2.0
  dio: ^5.4.0

  # Supabase
  supabase_flutter: ^2.0.0

  # Audio
  record: ^6.1.0
  audioplayers: ^6.0.0

  # UI/UX
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  lottie: ^3.0.0
  fl_chart: ^0.68.0

  # Video
  video_player: ^2.8.0
  chewie: ^1.7.0

  # PDF
  flutter_pdfview: ^1.3.0

  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.1

  # Utilities
  intl: ^0.19.0
  timeago: ^3.6.0
  flutter_dotenv: ^5.1.0
```

**Total: 22+ dependencias**

---

## 🔄 Flujos Importantes

### Flujo de Login

```
Usuario ingresa email/password
    ↓
LoginScreen._login()
    ↓
AuthProvider.login(email, password)
    ↓
SupabaseAuthService.signIn(email, password)
    ↓
Supabase.auth.signInWithPassword()
    ↓
Supabase verifica credenciales
    ↓
Return session + user data
    ↓
AuthProvider actualiza _user
    ↓
notifyListeners()
    ↓
UI se actualiza → HomeScreen
```

---

### Flujo de Quiz

```
Usuario selecciona habilidad
    ↓
QuizScreen carga preguntas de Supabase
    ↓
.from('Preguntas')
.select('*, Opciones_Respuesta(*)')
.eq('ID_Habilidad', skillId)
    ↓
Muestra pregunta actual
    ↓
Usuario selecciona opción
    ↓
_submitAnswer()
    ↓
.from('Respuestas_Usuario').insert({
  ID_Usuario: currentUser.id,
  ID_Pregunta: question.id,
  ID_Opcion_Seleccionada: selectedOption.id,
  Es_Correcta: selectedOption.esCorrecta,
  Puntos_Obtenidos: selectedOption.esCorrecta ? question.puntos : 0,
})
    ↓
Siguiente pregunta o QuizResultsScreen
```

---

## 🎯 Patrones y Buenas Prácticas

### 1. Service Layer

Toda lógica de negocio en servicios, NO en UI.

```dart
// ❌ MAL
class LoginScreen {
  void login() {
    Supabase.instance.client.auth.signIn(...);
  }
}

// ✅ BIEN
class LoginScreen {
  final _authService = SupabaseAuthService();

  void login() {
    _authService.signIn(...);
  }
}
```

---

### 2. Provider para Estado Global

```dart
// AuthProvider en main.dart
ChangeNotifierProvider(
  create: (_) => AuthProvider(),
  child: MaterialApp(...),
)

// Consumir en cualquier pantalla
final authProvider = Provider.of<AuthProvider>(context);
```

---

### 3. Modelos con fromMap/toMap

```dart
// Consistencia en parseo de Supabase
factory User.fromMap(Map<String, dynamic> map) {...}
Map<String, dynamic> toMap() {...}
```

---

## 🆘 Debugging

### "Missing Supabase credentials"

**Verificar:** `app/.env` existe y tiene credenciales

---

### "User not found after login"

**Causa:** Tabla `Usuarios` no tiene fila con Firebase_UID

**Solución:** Verificar que `signUp()` inserte correctamente

---

### "Widget rebuilding infinitely"

**Causa:** Provider mal usado (listen: true en build)

**Solución:** Usar `listen: false` en callbacks

---

## 📚 Siguiente Paso

**Lee `04_ESTADO_Y_PROXIMOS_PASOS.md`** para entender el estado actual del proyecto y qué sigue.
