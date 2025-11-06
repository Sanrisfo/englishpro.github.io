# 🏗️ ARQUITECTURA DEL SISTEMA - EnglishPro

**Arquitectura completa, flujos de datos y decisiones técnicas**

---

## 📊 Diagrama General

```
┌─────────────────────────────────────────────────────────┐
│                    ENGLISHPRO                            │
│          Aplicación Móvil Educativa de Inglés           │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  FLUTTER APP  │  │    BACKEND    │  │   SUPABASE    │
│               │  │  (OPCIONAL)   │  │               │
│  Dart 3.9.2+  │  │               │  │  PostgreSQL   │
│  Flutter 3.35.4│  │  Dart 3.9.2   │  │  Auth         │
│               │  │  (Docker)     │  │  Storage      │
│  Android/iOS  │  │               │  │  Realtime     │
└───────────────┘  └───────────────┘  └───────────────┘
      ↓                    ↓                   ↑
   Usuario            (Deshabilitado)        Cloud
                                              ↑
                                     Conexión directa
```

---

## 🔄 Arquitectura Actual vs Futura

### FASE 1: ACTUAL (Octubre 2024) ✅

```
┌──────────────┐         ┌──────────────┐
│  App Flutter │────────▶│   Supabase   │
│              │  Auth   │   (Cloud)    │
│  Login       │  CRUD   │              │
│  Cursos      │ Storage │  PostgreSQL  │
│  Quiz        │         │  Auth        │
│  Progreso    │         │  Storage     │
└──────────────┘         └──────────────┘

✅ NO necesita Docker
✅ NO necesita backend local
✅ Conecta directo a Supabase
✅ Auth + Base de datos + Storage en cloud
```

**Ventajas:**
- Setup rápido (5 minutos)
- Sin infraestructura local
- Escalable desde día 1
- Sin mantenimiento de servidores

---

### FASE 2: FUTURA (Cuando se necesite)

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  App Flutter │────────▶│   Backend    │────────▶│   Supabase   │
│              │  API    │   (Docker)   │  Query  │   (Cloud)    │
│              │         │              │         │              │
│  Login ──────┼────────▶│  Stripe API  │────────▶│  PostgreSQL  │
│  Pagos ──────┤         │  OpenAI API  │         │              │
│  IA Audio ───┤         │  Email API   │         │              │
│  Certs PDF ──┤         │  PDF Gen     │         │              │
└──────────────┘         └──────────────┘         └──────────────┘

✅ Backend en Docker (Dart 3.9.2)
✅ Integración con APIs externas
✅ Procesamiento pesado server-side
```

**Cuándo restaurar backend:**
- Implementar pagos con Stripe
- IA para calificar pronunciación (Whisper)
- Generar certificados PDF
- Enviar emails transaccionales

---

## 🛠️ Stack Tecnológico Detallado

### Frontend (App)

| Componente | Tecnología | Versión | Propósito |
|------------|------------|---------|-----------|
| **Framework** | Flutter | 3.35.4 | UI multiplataforma |
| **Lenguaje** | Dart | 3.9.2+ | Lógica de negocio |
| **Estado** | Provider | 6.1.0 | State management |
| **Navegación** | GoRouter | 13.0.0 | Routing |
| **HTTP** | http, dio | 1.2.0, 5.4.0 | API calls |
| **Auth** | supabase_flutter | 2.0.0 | Autenticación |
| **Storage local** | shared_preferences | 2.2.2 | Persistencia |
| **Audio** | record, audioplayers | 6.1.0, 6.0.0 | Grabación/reproducción |
| **Video** | video_player, chewie | 2.8.0, 1.7.0 | Reproducción video |
| **PDF** | flutter_pdfview | 1.3.0 | Visualización PDF |
| **Charts** | fl_chart | 0.68.0 | Gráficos progreso |
| **Animaciones** | lottie | 3.0.0 | Animaciones JSON |

**Total dependencias: 22+**

---

### Backend (Cloud - Supabase)

| Servicio | Tecnología | Propósito |
|----------|------------|-----------|
| **Base de Datos** | PostgreSQL 15 | Almacenamiento |
| **Auth** | Supabase Auth | Login/Register |
| **Storage** | Supabase Storage | Archivos multimedia |
| **Realtime** | WebSockets | Updates en tiempo real |
| **Edge Functions** | Deno | Serverless functions |

---

### Backend (Local - Opcional)

| Componente | Tecnología | Versión |
|------------|------------|---------|
| **Framework** | Dart Shelf | 1.4.0 |
| **Runtime** | Docker | - |
| **Image** | dart:3.9.2-sdk | Oficial |
| **Pagos** | Stripe API | - |
| **IA** | OpenAI Whisper | - |
| **PDF** | pdf package | - |

---

## 📁 Arquitectura de Carpetas

### App Flutter

```
app/
├── lib/
│   ├── main.dart                    # Entry point + Supabase init
│   │
│   ├── config/                      # Configuración
│   │   ├── supabase_config.dart    # Config Supabase
│   │   └── firebase_config.dart    # DEPRECATED (comentado)
│   │
│   ├── models/                      # Modelos de datos
│   │   ├── user.dart               # Usuario (compatible Supabase)
│   │   ├── user_model.dart         # Usuario (legacy)
│   │   ├── course_model.dart       # Cursos
│   │   ├── skill_model.dart        # Habilidades
│   │   ├── material_model.dart     # Materiales
│   │   ├── question_model.dart     # Preguntas
│   │   ├── progress_model.dart     # Progreso
│   │   ├── plan_model.dart         # Planes suscripción
│   │   └── notification.dart       # Notificaciones
│   │
│   ├── services/                    # Servicios
│   │   ├── supabase_auth_service.dart       # Auth Supabase
│   │   ├── supabase_storage_service.dart    # Storage Supabase
│   │   ├── api_service.dart                 # API backend (futuro)
│   │   └── storage_service.dart             # DEPRECATED (Firebase)
│   │
│   ├── providers/                   # State management
│   │   └── auth_provider.dart      # Estado autenticación
│   │
│   ├── screens/                     # Pantallas
│   │   ├── splash_screen.dart      # Splash inicial
│   │   ├── login_screen.dart       # Login
│   │   ├── register_screen.dart    # Registro
│   │   ├── home_screen.dart        # Home estudiantes
│   │   ├── teacher_dashboard_screen.dart  # Dashboard docentes
│   │   ├── courses_list_screen.dart       # Lista cursos
│   │   ├── quiz_screen.dart               # Quiz
│   │   ├── quiz_results_screen.dart       # Resultados
│   │   ├── progress_dashboard_screen.dart # Progreso
│   │   ├── subscription_plans_screen.dart # Planes
│   │   ├── notifications_screen.dart      # Notificaciones
│   │   ├── manual_grading_screen.dart     # Calificación docentes
│   │   ├── teacher_materials_screen.dart  # Materiales docentes
│   │   └── courses/
│   │       ├── toefl_screen.dart
│   │       ├── ielts_screen.dart
│   │       ├── business_english_screen.dart
│   │       └── english_in_action_screen.dart
│   │
│   └── widgets/                     # Componentes reutilizables
│       ├── audio_recorder_widget.dart
│       ├── video_player_widget.dart
│       └── pdf_viewer_widget.dart
│
├── assets/                          # Assets estáticos
│   ├── images/
│   ├── animations/
│   ├── audio/
│   ├── videos/
│   ├── pdfs/
│   └── icons/
│
├── .env                            # Credenciales Supabase
└── pubspec.yaml                    # Dependencias
```

---

## 🔄 Flujos de Datos Principales

### 1. Autenticación (Login/Register)

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │ Email/Password
       ↓
┌─────────────────────────────────────┐
│  app/lib/screens/login_screen.dart  │
└──────┬──────────────────────────────┘
       │ Llamada a servicio
       ↓
┌───────────────────────────────────────────────┐
│  app/lib/services/supabase_auth_service.dart │
│                                                │
│  signIn(email, password)                      │
│  signUp(email, password, name, profession)    │
└──────┬────────────────────────────────────────┘
       │ API call
       ↓
┌─────────────────────┐
│  Supabase Auth API  │
│  POST /auth/signin  │
└──────┬──────────────┘
       │ Verifica credenciales
       ↓
┌──────────────────────┐
│  Tabla: Usuarios     │
│  (PostgreSQL)        │
│                      │
│  - ID_Usuario        │
│  - Email             │
│  - Password_Hash     │
│  - Rol               │
└──────┬───────────────┘
       │ Trigger auto: create_user_benefits
       ↓
┌──────────────────────┐
│ Beneficios_Usuario   │
│ (Fila creada auto)   │
└──────┬───────────────┘
       │ Return session + user
       ↓
┌─────────────────────┐
│  AuthProvider       │
│  (Provider state)   │
│                     │
│  - user             │
│  - isAuthenticated  │
└──────┬──────────────┘
       │ Navegación
       ↓
┌─────────────────────┐
│  HomeScreen         │
└─────────────────────┘
```

**Archivos involucrados:**
- `app/lib/screens/login_screen.dart:45` - UI Login
- `app/lib/screens/register_screen.dart:60` - UI Register
- `app/lib/services/supabase_auth_service.dart:25` - Lógica auth
- `app/lib/providers/auth_provider.dart:15` - Estado
- `database/FIX_TRIGGER.sql:10` - Trigger beneficios

---

### 2. Listar Cursos

```
┌─────────────┐
│  HomeScreen │
└──────┬──────┘
       │ initState()
       ↓
┌──────────────────────┐
│  Supabase Client     │
│  .from('Cursos')     │
│  .select('*')        │
└──────┬───────────────┘
       │ Query PostgreSQL
       ↓
┌──────────────────────┐
│  Tabla: Cursos       │
│                      │
│  1. TOEFL            │
│  2. IELTS            │
│  3. Business English │
│  4. English in Action│
└──────┬───────────────┘
       │ Return List<Map>
       ↓
┌──────────────────────┐
│  CourseModel.fromMap │
│  (Modelo)            │
└──────┬───────────────┘
       │ setState()
       ↓
┌──────────────────────┐
│  ListView.builder    │
│  (UI actualizado)    │
└──────────────────────┘
```

**Archivos:**
- `app/lib/screens/home_screen.dart:80` - Fetch cursos
- `app/lib/models/course_model.dart:15` - Modelo

---

### 3. Responder Quiz

```
┌─────────────┐
│  Usuario    │
│  Responde   │
└──────┬──────┘
       │ Selecciona opción
       ↓
┌──────────────────────┐
│  quiz_screen.dart    │
│  _submitAnswer()     │
└──────┬───────────────┘
       │ Supabase insert
       ↓
┌────────────────────────────────────┐
│  .from('Respuestas_Usuario')      │
│  .insert({                         │
│    ID_Usuario: currentUser.id,    │
│    ID_Pregunta: question.id,      │
│    ID_Opcion_Seleccionada: ans.id │
│  })                                │
└──────┬─────────────────────────────┘
       │ Insert PostgreSQL
       ↓
┌──────────────────────┐
│  Respuestas_Usuario  │
│  (nueva fila)        │
└──────┬───────────────┘
       │ Trigger: update_progress (si existe)
       ↓
┌──────────────────────┐
│  Progreso_Usuarios   │
│  (actualiza stats)   │
│                      │
│  Preguntas_         │
│  Respondidas++       │
└──────┬───────────────┘
       │ Return result
       ↓
┌──────────────────────┐
│  quiz_results_screen │
│  Muestra resultado   │
└──────────────────────┘
```

**Archivos:**
- `app/lib/screens/quiz_screen.dart:120` - Submit respuesta
- `app/lib/screens/quiz_results_screen.dart:30` - Resultados
- `app/lib/models/question_model.dart:20` - Modelo pregunta

---

### 4. Upload de Audio (Speaking)

```
┌─────────────┐
│  Usuario    │
│  Graba audio│
└──────┬──────┘
       │ Presiona "Stop"
       ↓
┌──────────────────────────────┐
│  audio_recorder_widget.dart  │
│  _stopRecording()            │
└──────┬───────────────────────┘
       │ File audio guardado local
       ↓
┌─────────────────────────────────────────┐
│  supabase_storage_service.dart          │
│                                          │
│  uploadAudio(File audioFile, userId)    │
└──────┬──────────────────────────────────┘
       │ Supabase Storage API
       ↓
┌──────────────────────┐
│  Supabase Storage    │
│  Bucket: audios/     │
│                      │
│  audios/user_123/    │
│    speaking_001.m4a  │
└──────┬───────────────┘
       │ Return public URL
       ↓
┌──────────────────────┐
│  .from('Respuestas_  │
│  Usuario')           │
│  .insert({           │
│    URL_Grabacion: url│
│  })                  │
└──────┬───────────────┘
       │ Guardado en DB
       ↓
┌──────────────────────┐
│  Respuestas_Usuario  │
│  URL_Grabacion:      │
│  https://...m4a      │
└──────────────────────┘
```

**Archivos:**
- `app/lib/widgets/audio_recorder_widget.dart:45` - Grabación
- `app/lib/services/supabase_storage_service.dart:30` - Upload
- `database/schema.sql:172` - Campo URL_Grabacion

---

## 🔐 Seguridad y Permisos

### Row Level Security (RLS)

**Estado actual: DESHABILITADO** (para desarrollo rápido)

```sql
-- database/DISABLE_RLS_TEMPORAL.sql (YA EJECUTADO)
ALTER TABLE Usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE Respuestas_Usuario DISABLE ROW LEVEL SECURITY;
-- ... todas las tablas
```

**Por qué:**
- Trigger recursivo causaba error
- Desarrollo más rápido sin RLS
- Producción: habilitar RLS con políticas correctas

**RLS correcto (futuro):**

```sql
-- Usuarios solo ven sus propios datos
CREATE POLICY "Users can view own data" ON Usuarios
  FOR SELECT USING (auth.uid()::text = Firebase_UID);

-- Usuarios solo actualizan sus propios datos
CREATE POLICY "Users can update own data" ON Usuarios
  FOR UPDATE USING (auth.uid()::text = Firebase_UID);
```

Ver `No_Necesarios/database/RLS_CORRECTO.sql` para implementación completa.

---

### Autenticación

```dart
// app/lib/services/supabase_auth_service.dart

class SupabaseAuthService {
  final supabase = Supabase.instance.client;

  // Login
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Guarda sesión automáticamente
    // Token JWT en localStorage
    return response.user!.toJson();
  }

  // Logout
  Future<void> signOut() async {
    await supabase.auth.signOut();
    // Borra sesión local
  }

  // Usuario actual
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
```

**Token JWT:**
- Generado por Supabase Auth
- Guardado en localStorage automáticamente
- Renovado automáticamente
- Enviado en headers de cada request

---

## 🚀 Decisiones de Arquitectura

| Decisión | Razón | Alternativa Descartada |
|----------|-------|------------------------|
| **Flutter sin Docker** | Necesita hardware (USB, GPU, hot-reload) | Flutter en Docker (muy lento) |
| **Backend con Docker** | Aislar versiones de Dart, fácil deploy | Backend local (conflictos) |
| **Supabase Cloud** | Escalable, sin mantener DB, Auth listo | PostgreSQL local (más trabajo) |
| **FVM para Flutter** | Control exacto de versión | Confiar en `flutter upgrade` |
| **RLS deshabilitado** | Desarrollo rápido, evitar recursión | RLS habilitado (error trigger) |
| **Auth directo Supabase** | Menos código, más simple | Auth vía backend custom |
| **Provider para estado** | Simple, suficiente para app | Riverpod, Bloc (overkill) |
| **GoRouter para navegación** | Declarativo, deep linking | Navigator 1.0 (imperativo) |
| **Supabase Storage** | Integrado, simple | Firebase Storage, S3 |

---

## 📊 Patrones de Diseño Usados

### 1. Service Layer Pattern

```dart
// Separación de lógica de negocio
// UI → Service → Supabase

// ❌ MAL (todo en UI)
class LoginScreen {
  void login() {
    Supabase.instance.client.auth.signIn(...); // Lógica en UI
  }
}

// ✅ BIEN (Service Layer)
class LoginScreen {
  final authService = SupabaseAuthService();

  void login() {
    authService.signIn(...); // UI solo llama servicio
  }
}
```

---

### 2. Provider Pattern (State Management)

```dart
// app/lib/providers/auth_provider.dart

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // UI se actualiza

    _user = await authService.signIn(email, password);

    _isLoading = false;
    notifyListeners();
  }
}
```

**Consumo en UI:**

```dart
// app/lib/screens/home_screen.dart

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return HomeContent();
    } else {
      return LoginScreen();
    }
  }
}
```

---

### 3. Repository Pattern (Futuro)

**Actualmente no implementado**, pero recomendado para Fase 2:

```dart
// Abstraer fuente de datos
// UI → Repository → Supabase/Cache/LocalDB

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> getCourseById(int id);
}

class SupabaseCourseRepository implements CourseRepository {
  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase.from('Cursos').select();
    return data.map((e) => Course.fromMap(e)).toList();
  }
}
```

---

## 🔄 Control de Versiones

### FVM (Flutter Version Manager)

```json
// .fvm/fvm_config.json
{
  "flutterSdkVersion": "3.35.4"
}
```

**Garantía:** Todos los devs usan Flutter 3.35.4

---

### pubspec.lock

```yaml
# app/pubspec.lock (EN GIT ✅)
packages:
  supabase_flutter:
    version: "2.0.0"  # Versión exacta
  http:
    version: "1.2.0"
```

**Garantía:** Todos usan mismos packages

---

### Docker (Backend futuro)

```dockerfile
# No_Necesarios/backend/Dockerfile
FROM dart:3.9.2-sdk
# ...
```

**Garantía:** Backend usa Dart 3.9.2 exacto

---

## 📈 Escalabilidad

### Actual (< 1000 usuarios)
- ✅ Supabase Free Tier suficiente
- ✅ Auth + DB + Storage gratis
- ✅ Sin backend local

### Futuro (> 1000 usuarios)
- Upgrade a Supabase Pro ($25/mes)
- Agregar backend para:
  - Cache con Redis
  - CDN para videos/PDFs
  - Rate limiting
  - Analytics

---

## 🆘 Troubleshooting Arquitectura

### "No se conecta a Supabase"

**Verificar:**
1. `app/.env` tiene SUPABASE_URL y SUPABASE_ANON_KEY
2. Internet funciona
3. Supabase project está activo (no pausado)

---

### "Trigger recursivo"

**Causa:** RLS habilitado + trigger llama función que consulta misma tabla

**Solución:** RLS deshabilitado (actual) o política correcta (futuro)

---

### "Versión incorrecta de Flutter"

**Verificar:**
```bash
fvm flutter --version  # Debe mostrar 3.35.4
```

**Solución:**
```bash
fvm use 3.35.4
fvm flutter pub get
```

---

## 📚 Siguiente Paso

**Lee `02_BASE_DE_DATOS.md`** para entender el esquema completo de 16 tablas y sus relaciones.
