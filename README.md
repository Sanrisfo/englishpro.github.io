# EnglishPro 

**Aplicación móvil educativa para estudiantes de inglés de nivel intermedio y avanzado**

## Descripción

EnglishPro es una plataforma de aprendizaje de inglés que ayuda a estudiantes a prepararse para exámenes internacionales (TOEFL, IELTS) y mejorar sus habilidades comunicativas en contextos profesionales y cotidianos.

### 🎯 Características Principales

- **4 Módulos Educativos**: TOEFL, IELTS, Business English, English in Action
- **4 Habilidades**: Writing, Speaking, Listening, Reading
- **Contenido Multimedia**: Audio, video, texto, PDFs
- **Sistema de Planes**: Freemium, Básico, Pro, Premium
- **Retroalimentación**: Automática y manual por docentes
- **Grabación de Audio**: Para práctica de Speaking
- **Seguimiento de Progreso**: Personalizado por curso

## 🛠️ Stack Tecnológico

| Componente | Tecnología |
|------------|------------|
| **Frontend** | Flutter 3.35.4 / Dart 3.9.2 |
| **Backend** | Dart (Shelf) |
| **Base de Datos** | PostgreSQL 15 |
| **Autenticación** | Firebase Auth |
| **Storage** | Firebase Storage |
| **Containerización** | Docker & Docker Compose |

## 📁 Estructura del Proyecto

```
EnglishPro/
├── app/                    # Aplicación Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   └── providers/
│   ├── assets/
│   │   ├── images/
│   │   └── animations/
│   └── pubspec.yaml
├── backend/                # API Backend en Dart
│   ├── bin/
│   │   └── server.dart
│   ├── lib/
│   │   ├── models/
│   │   ├── services/
│   │   ├── middleware/
│   │   └── utils/
│   └── pubspec.yaml
├── database/               # Scripts SQL
│   └── schema.sql         # 16 tablas
├── docker-compose.yml     # Configuración Docker
├── .env                   # Variables de entorno
└── README.md
```

## 🚀 Inicio Rápido

### ⚡ Opción 1: Con Docker (Recomendado - Solo necesitas Docker)

**Requisitos:**
- [Docker Desktop](https://www.docker.com/get-started)
- [Git](https://git-scm.com/)

**Pasos:**

```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd EnglishPro

# 2. Configurar variables de entorno
cp .env.example .env

# 3. Iniciar todo con un comando
# Windows (PowerShell)
.\docker-start.ps1

# Linux/macOS
./docker-start.sh
```

**¡Listo!** Todo está corriendo:
- PostgreSQL → localhost:5432
- Backend API → http://localhost:8080
- Flutter Web → http://localhost:8081

**Para desarrollo con hot-reload:**
```bash
# Windows
.\docker-dev.ps1

# Linux/macOS
./docker-dev.sh

# Luego en otra terminal
cd app
flutter run
```

📖 **Ver guía completa**: [DOCKER_SETUP.md](DOCKER_SETUP.md)

---

### 🔧 Opción 2: Instalación Manual (Requiere todas las dependencias)

**Requisitos:**
- [Flutter](https://flutter.dev/docs/get-started/install) 3.35.4
- [Dart](https://dart.dev/get-dart) 3.9.2
- [Docker](https://www.docker.com/get-started) (solo para PostgreSQL)
- [Git](https://git-scm.com/)

**Pasos:**

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd EnglishPro
```

### 2. Configurar Variables de Entorno

```bash
cp .env.example .env
# Editar .env con tus credenciales
```

### 3. Iniciar PostgreSQL con Docker

```bash
docker compose up -d postgres
```

### 4. Iniciar Backend

```bash
cd backend
dart pub get
dart run bin/server.dart
```

### 5. Ejecutar App Flutter

```bash
cd app
flutter pub get
flutter run
```

---

## 🗄️ Base de Datos

### 16 Tablas Principales

1. **Planes** - Freemium, Básico, Pro, Premium
2. **Usuarios** - Estudiantes y docentes
3. **Docentes** - Información de profesores
4. **Cursos** - TOEFL, IELTS, Business, Action
5. **Habilidades** - Writing, Speaking, Listening, Reading
6. **Materiales_Estudio** - PDFs, videos, audios
7. **Cuestionarios** - Evaluaciones por habilidad
8. **Preguntas** - Preguntas multimedia
9. **Cuestionario_Preguntas** - Relación N:M
10. **Opciones_Respuesta** - Opciones múltiple choice
11. **Respuestas_Usuario** - Respuestas de estudiantes
12. **Retroalimentacion_Docente** - Evaluaciones manuales
13. **Progreso_Usuarios** - Seguimiento por curso
14. **Pagos** - Historial de transacciones
15. **Beneficios_Usuario** - Sesiones y simulacros
16. **Notificaciones** - Sistema de notificaciones

### Acceso a la Base de Datos

```bash
# Conectar con psql
docker exec -it englishpro_db psql -U admin -d englishpro_db
```

## 🔥 Configuración de Firebase

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Habilitar **Firebase Authentication** (Email/Password)
3. Habilitar **Firebase Storage**
4. Descargar `google-services.json` y colocarlo en `app/android/app/`
5. Actualizar credenciales en `.env`

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar
firebase init
```

## 📊 Planes de Suscripción

| Plan | Precio | Preguntas/Habilidad | Retroalimentación | Sesiones en Vivo | Simulacros |
|------|--------|---------------------|-------------------|------------------|------------|
| **Freemium** | $0.00 | 1 | Automática | ❌ | ❌ |
| **Básico** | $9.99 | 3 | Automática | ❌ | ❌ |
| **Pro** | $19.99 | 5 | Auto + Manual | ❌ | ❌ |
| **Premium** | $39.99 | 5 | Auto + Manual | ✅ 5 | ✅ 2 |

## 🧪 Testing

### Backend

```bash
cd backend
dart test
```

### Flutter

```bash
cd app
flutter test
```

## 📦 Endpoints API

| Módulo | Endpoints Principales |
|--------|----------------------|
| **Auth** | `/api/auth/register`, `/api/auth/login`, `/api/auth/me` |
| **Courses** | `/api/courses`, `/api/courses/:id` |
| **Skills** | `/api/skills`, `/api/skills/course/:id` |
| **Materials** | `/api/materials`, `/api/materials/skill/:id` |
| **Questions** | `/api/questions/skill/:id`, `/api/answers` |
| **Quizzes** | `/api/quizzes/:id`, `/api/attempts` |
| **Progress** | `/api/progress/user/:id`, `/api/stats/user/:id` |
| **Payments** | `/api/payments`, `/api/payments/subscriptions` |
| **Feedback** | `/api/feedback`, `/api/feedback/pending/all` |
| **Teachers** | `/api/teachers`, `/api/teachers/:id/stats` |
| **Notifications** | `/api/notifications/:userId`, `/api/notifications/:userId/unread` |

Ver documentación completa de todos los endpoints en [TESTING.md](TESTING.md)

## 👥 Equipo

- **Pedro Yanyachi** - Jefe de Proyecto
- **Angelo Goitia** - Analista de Requisitos
- **Juan Diego Bernilla** - Diseñador UI/UX
- **Josue Martines** - Desarrollador Móvil
- **Santiago Rodriguez** - Tester de Calidad
- **Piero Vargas** - Documentador

## 📅 Roadmap

- [x] Setup inicial (Sprint 1 - Día 1-5)
- [x] Sistema de Autenticación (Sprint 1 - Día 6-10)
- [x] Home screen y navegación (Sprint 1 - Día 11-14)
- [x] Estructura de contenido (Sprint 2)
- [x] Sistema de evaluación (Sprint 3)
- [x] Progreso y monetización (Sprint 4)
- [x] Panel docente (Sprint 5 - Día 1-5)
- [x] Sistema de roles (Sprint 5)
- [x] Notificaciones (Sprint 5 - Día 6-9)
- [x] Testing completo (Sprint 5 - Día 10-14)
- [ ] Optimización y documentación (Sprint 6 - Día 1-3)
- [ ] Build de producción (Sprint 6 - Día 4-7)
- [ ] Publicación en Play Store (Sprint 6 - Día 8-14)

## 🐳 Desarrollo con Docker

EnglishPro está completamente dockerizado para facilitar la colaboración y eliminar problemas de dependencias.

### Ventajas de usar Docker:

✅ **Solo necesitas Docker** - No instalar Flutter, Dart, PostgreSQL, etc.
✅ **Entorno idéntico** - Todos usan las mismas versiones
✅ **Inicio rápido** - Nuevos colaboradores listos en minutos
✅ **Sin conflictos** - Aislado de tu sistema operativo
✅ **Multiplataforma** - Funciona igual en Windows, Mac y Linux

### Modos de ejecución:

**Modo Completo** (Todo en Docker):
```bash
./docker-start.sh    # Linux/macOS
.\docker-start.ps1   # Windows
```

**Modo Desarrollo** (Backend en Docker, Flutter local con hot-reload):
```bash
./docker-dev.sh      # Linux/macOS
.\docker-dev.ps1     # Windows
```

📖 **Guía completa**: [DOCKER_SETUP.md](DOCKER_SETUP.md)

---

## 📄 Licencia

Este proyecto es privado y está desarrollado como proyecto académico para la Universidad Nacional Mayor de San Marcos (UNMSM) - FISI.

## 📚 Documentación

- [README.md](README.md) - Este archivo
- [QUICKSTART.md](QUICKSTART.md) - Inicio rápido para nuevos colaboradores
- [DOCKER_SETUP.md](DOCKER_SETUP.md) - Guía completa de Docker
- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitectura del sistema
- [TESTING.md](TESTING.md) - Guía de testing y endpoints API
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Configuración de Firebase
- [programacion_de_trabajo.md](programacion_de_trabajo.md) - Roadmap del proyecto

## 🔗 Recursos Externos

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Firebase Docs](https://firebase.google.com/docs)
- [Docker Docs](https://docs.docker.com/)

---

