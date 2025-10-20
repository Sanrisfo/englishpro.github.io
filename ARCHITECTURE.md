# EnglishPro - Arquitectura del Sistema

## Índice
- [Visión General](#visión-general)
- [Stack Tecnológico](#stack-tecnológico)
- [Arquitectura de Capas](#arquitectura-de-capas)
- [Modelos de Datos](#modelos-de-datos)
- [Flujo de Datos](#flujo-de-datos)
- [Seguridad](#seguridad)
- [Escalabilidad](#escalabilidad)

---

## Visión General

EnglishPro es una aplicación móvil educativa construida con una arquitectura de tres capas:

```
┌─────────────────────────────────────────┐
│         Flutter Mobile App              │  (Presentación)
│  - Screens (UI)                          │
│  - Widgets (Componentes)                 │
│  - Models (Datos locales)                │
│  - Services (API Client)                 │
└─────────────────────────────────────────┘
                   ↕ HTTP/REST
┌─────────────────────────────────────────┐
│       Dart Backend (Shelf)               │  (Lógica de Negocio)
│  - Routes (Endpoints)                    │
│  - Services (Lógica)                     │
│  - Models (Estructuras)                  │
│  - Middleware (Auth, CORS)               │
└─────────────────────────────────────────┘
                   ↕ SQL
┌─────────────────────────────────────────┐
│       PostgreSQL Database                │  (Persistencia)
│  - 16 Tablas relacionales                │
│  - Constraints y Validaciones            │
│  - Datos iniciales (seed)                │
└─────────────────────────────────────────┘
```

---

## Stack Tecnológico

### Frontend (Móvil)
- **Framework**: Flutter 3.35.4
- **Lenguaje**: Dart 3.9.2
- **Gestión de Estado**: Provider
- **HTTP Client**: Dio / http package
- **Almacenamiento Local**: SharedPreferences
- **Multimedia**:
  - `flutter_sound` (Grabación de audio)
  - `video_player` (Reproducción de video)
  - `flutter_pdfview` (Visualización de PDFs)
  - `lottie` (Animaciones)
- **Gráficos**: fl_chart
- **Autenticación**: Firebase Auth

### Backend (API)
- **Framework**: Shelf (Dart)
- **Arquitectura**: RESTful API
- **Autenticación**: JWT (JSON Web Tokens)
- **Encriptación**: BCrypt (contraseñas)
- **Base de Datos**: PostgreSQL driver (postgres package)
- **Validación**: Custom validators
- **CORS**: shelf_cors middleware

### Base de Datos
- **DBMS**: PostgreSQL 15
- **Contenedor**: Docker
- **Migraciones**: SQL scripts
- **Backup**: docker volumes

### Infraestructura
- **Containerización**: Docker & Docker Compose
- **Storage**: Firebase Storage (multimedia)
- **Authentication**: Firebase Auth
- **CI/CD**: Git (GitHub)

---

## Arquitectura de Capas

### 1. Capa de Presentación (Flutter App)

```
app/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── models/                   # Modelos de datos locales
│   │   ├── user.dart
│   │   ├── course.dart
│   │   ├── skill.dart
│   │   ├── question.dart
│   │   ├── notification.dart
│   │   └── ...
│   ├── screens/                  # Pantallas principales
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── course_detail_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── progress_dashboard_screen.dart
│   │   ├── subscription_plans_screen.dart
│   │   ├── teacher_dashboard_screen.dart
│   │   ├── manual_grading_screen.dart
│   │   └── notifications_screen.dart
│   ├── widgets/                  # Componentes reutilizables
│   │   ├── audio_recorder_widget.dart
│   │   ├── video_player_widget.dart
│   │   ├── pdf_viewer_widget.dart
│   │   └── ...
│   ├── services/                 # Servicios
│   │   ├── api_service.dart      # Cliente HTTP para backend
│   │   └── firebase_service.dart
│   └── providers/                # Estado global
│       └── user_provider.dart
└── assets/                       # Recursos estáticos
    ├── images/
    ├── animations/
    ├── audio/
    ├── videos/
    └── pdfs/
```

**Responsabilidades:**
- Renderizar UI
- Manejar interacciones del usuario
- Validación de formularios
- Navegación entre pantallas
- Llamadas a la API
- Almacenamiento local (tokens, preferencias)

---

### 2. Capa de Lógica de Negocio (Backend)

```
backend/
├── bin/
│   └── server.dart               # Servidor principal
├── lib/
│   ├── models/                   # Modelos de datos
│   │   ├── user_model.dart
│   │   ├── course_model.dart
│   │   ├── question_model.dart
│   │   ├── payment_model.dart
│   │   ├── feedback_model.dart
│   │   ├── teacher_model.dart
│   │   ├── notification_model.dart
│   │   └── ...
│   ├── services/                 # Lógica de negocio
│   │   ├── auth_service.dart
│   │   ├── course_service.dart
│   │   ├── question_service.dart
│   │   ├── quiz_service.dart
│   │   ├── progress_service.dart
│   │   ├── payment_service.dart
│   │   ├── plan_validation_service.dart
│   │   ├── feedback_service.dart
│   │   ├── teacher_service.dart
│   │   ├── notification_service.dart
│   │   └── ...
│   ├── routes/                   # Endpoints REST
│   │   ├── auth_routes.dart
│   │   ├── course_routes.dart
│   │   ├── question_routes.dart
│   │   ├── quiz_routes.dart
│   │   ├── progress_routes.dart
│   │   ├── payment_routes.dart
│   │   ├── feedback_routes.dart
│   │   ├── teacher_routes.dart
│   │   ├── notification_routes.dart
│   │   └── ...
│   ├── middleware/               # Middleware
│   │   ├── auth_middleware.dart  # JWT validation
│   │   └── cors_middleware.dart
│   └── utils/                    # Utilidades
│       ├── database.dart         # Conexión a PostgreSQL
│       ├── jwt_helper.dart
│       └── validators.dart
└── pubspec.yaml
```

**Responsabilidades:**
- Validar requests
- Autenticación y autorización
- Lógica de negocio
- Interacción con la base de datos
- Generación de respuestas JSON
- Manejo de errores

---

### 3. Capa de Persistencia (PostgreSQL)

```
database/
├── schema.sql                    # Esquema de base de datos
└── seed.sql                      # Datos iniciales
```

**16 Tablas Principales:**

1. **Planes** - Freemium, Básico, Pro, Premium
2. **Usuarios** - Estudiantes, Docentes, Admins
3. **Docentes** - Información de profesores
4. **Cursos** - TOEFL, IELTS, Business, Action
5. **Habilidades** - Writing, Speaking, Listening, Reading
6. **Materiales_Estudio** - PDFs, videos, audios
7. **Cuestionarios** - Evaluaciones
8. **Preguntas** - Preguntas multimedia
9. **Cuestionario_Preguntas** - Relación N:M
10. **Opciones_Respuesta** - Opciones múltiple choice
11. **Respuestas_Usuario** - Respuestas de estudiantes
12. **Retroalimentacion_Docente** - Evaluaciones manuales
13. **Progreso_Usuarios** - Seguimiento por curso
14. **Pagos** - Historial de transacciones
15. **Beneficios_Usuario** - Sesiones y simulacros
16. **Notificaciones** - Sistema de notificaciones

---

## Modelos de Datos

### Diagrama ER Simplificado

```
┌─────────────┐       ┌──────────────┐       ┌──────────────┐
│   Planes    │───────│   Usuarios   │───────│   Docentes   │
└─────────────┘  1:N  └──────────────┘  1:1  └──────────────┘
                             │
                          1:N│
                             ↓
                      ┌──────────────┐
                      │   Progreso   │
                      └──────────────┘
                             ↑
                          N:1│
┌─────────────┐       ┌──────────────┐       ┌──────────────┐
│   Cursos    │───────│ Habilidades  │───────│ Cuestionarios│
└─────────────┘  1:N  └──────────────┘  1:N  └──────────────┘
      │                      │                       │
   1:N│                   1:N│                    N:M│
      ↓                      ↓                       ↓
┌─────────────┐       ┌──────────────┐       ┌──────────────┐
│ Materiales  │       │  Preguntas   │───────│Cuest_Pregun  │
└─────────────┘       └──────────────┘  N:M  └──────────────┘
                             │
                          1:N│
                             ↓
                      ┌──────────────┐
                      │Resp_Usuario  │
                      └──────────────┘
                             │
                          1:1│
                             ↓
                      ┌──────────────┐
                      │Retroaliment  │
                      └──────────────┘
```

---

## Flujo de Datos

### 1. Flujo de Autenticación

```
Usuario ingresa credenciales
        ↓
LoginScreen (Flutter)
        ↓
ApiService.login()
        ↓ HTTP POST /api/auth/login
Backend: AuthRoutes
        ↓
AuthService.login()
        ↓
Verifica password con BCrypt
        ↓
Genera JWT token
        ↓
← Response { user, token }
        ↓
Flutter guarda token en SharedPreferences
        ↓
Navega a HomeScreen o TeacherDashboardScreen según rol
```

### 2. Flujo de Cuestionario

```
Usuario selecciona cuestionario
        ↓
QuizScreen (Flutter)
        ↓
ApiService.getQuizById()
        ↓ HTTP GET /api/quizzes/:id
Backend: QuizRoutes
        ↓
QuizService.getQuizWithQuestions()
        ↓
← Response { quiz, questions[] }
        ↓
Usuario responde preguntas
        ↓
ApiService.submitAnswer()
        ↓ HTTP POST /api/answers
Backend: QuestionRoutes
        ↓
QuestionService.submitAnswer()
        ↓
Guarda respuesta en BD
        ↓
Actualiza progreso
        ↓
← Response { isCorrect, points }
        ↓
QuizResultsScreen muestra resultados
```

### 3. Flujo de Retroalimentación Manual

```
Usuario responde pregunta de Writing/Speaking
        ↓
ApiService.createFeedback()
        ↓ HTTP POST /api/feedback
Backend: FeedbackRoutes
        ↓
FeedbackService.createFeedback()
        ↓
Guarda feedback con estado 'Pendiente'
        ↓
Crea notificación para docentes
        ↓
← Response { feedback }
        ↓
Docente ve feedback pendiente en TeacherDashboardScreen
        ↓
ManualGradingScreen
        ↓
Docente califica
        ↓
ApiService.gradeFeedback()
        ↓ HTTP POST /api/feedback/:id/grade
Backend: FeedbackService.gradeFeedback()
        ↓
Actualiza puntuación y comentarios
        ↓
Crea notificación para estudiante
        ↓
← Response { feedback }
        ↓
Estudiante recibe notificación
```

---

## Seguridad

### 1. Autenticación

- **JWT Tokens**:
  - Generados en login/registro
  - Almacenados en SharedPreferences (Flutter)
  - Enviados en header `Authorization: Bearer <token>`
  - Validados en middleware del backend

### 2. Autorización

- **Roles**: Estudiante, Docente, Admin
- **Validación por endpoint**: Middleware verifica rol en JWT
- **Control de acceso**:
  - Docentes solo acceden a TeacherDashboardScreen
  - Estudiantes solo acceden a sus datos
  - Validación de plan antes de acceder a contenido premium

### 3. Encriptación

- **Contraseñas**: BCrypt con salt rounds = 10
- **Tokens**: HS256 algorithm para JWT
- **HTTPS**: Comunicación segura (producción)

### 4. Validaciones

- **Frontend**: Validación de formularios en tiempo real
- **Backend**: Validación de datos en servicios
- **Base de Datos**: Constraints y CHECK clauses

### 5. Protección contra ataques

- **CORS**: Configurado en middleware
- **SQL Injection**: Uso de queries parametrizadas
- **XSS**: Sanitización de inputs
- **Rate Limiting**: (Pendiente para producción)

---

## Escalabilidad

### Estrategias Actuales

1. **Containerización con Docker**
   - PostgreSQL en contenedor
   - Backend fácilmente replicable
   - Aislamiento de dependencias

2. **API Stateless**
   - No mantiene sesión en servidor
   - Escalado horizontal posible
   - JWT para autenticación sin estado

3. **Firebase Storage**
   - Almacenamiento escalable de multimedia
   - CDN global de Google
   - No sobrecarga el backend con archivos

### Mejoras Futuras

1. **Cache Layer**
   - Redis para cache de queries frecuentes
   - Reducir carga en PostgreSQL

2. **Load Balancer**
   - NGINX para distribuir tráfico
   - Múltiples instancias del backend

3. **CDN**
   - CloudFlare o AWS CloudFront
   - Servir assets estáticos

4. **Database Scaling**
   - Read replicas para PostgreSQL
   - Connection pooling
   - Índices optimizados

5. **Microservicios**
   - Separar Payment Service
   - Separar Notification Service
   - Comunicación vía message queue (RabbitMQ)

6. **Monitoreo**
   - New Relic o DataDog
   - Logs centralizados (ELK stack)
   - Alertas automáticas

---

## Flujo de Desarrollo

```
Desarrollo Local
        ↓
Git Push a GitHub
        ↓
Review de Código
        ↓
Tests Automatizados
        ↓
Merge a main
        ↓
Build de Producción
        ↓
Deploy a servidor
        ↓
Monitoreo y mantenimiento
```

---

## Convenciones de Código

### Flutter (Dart)

- **Nombrado**:
  - Clases: `PascalCase`
  - Variables/funciones: `camelCase`
  - Archivos: `snake_case.dart`
  - Constantes: `UPPER_CASE`

- **Estructura**:
  - Widgets en carpeta `widgets/`
  - Screens en carpeta `screens/`
  - Models en carpeta `models/`

### Backend (Dart)

- **Nombrado**:
  - Clases: `PascalCase`
  - Funciones: `camelCase`
  - Archivos: `snake_case.dart`

- **Estructura**:
  - Un service por entidad
  - Un route file por módulo
  - Models reflejan estructura de BD

### Base de Datos

- **Nombrado**:
  - Tablas: `PascalCase`
  - Columnas: `snake_case`
  - Constraints: `tabla_columna_tipo`

---

## Documentación Relacionada

- [README.md](README.md) - Información general del proyecto
- [TESTING.md](TESTING.md) - Guía de testing y endpoints
- [programacion_de_trabajo.md](programacion_de_trabajo.md) - Roadmap de desarrollo
