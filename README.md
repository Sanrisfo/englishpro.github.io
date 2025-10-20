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

### Requisitos Previos

**Solo necesitas Docker Desktop:**

- [Docker Desktop para Windows](https://www.docker.com/products/docker-desktop)
- [Docker Desktop para macOS](https://www.docker.com/products/docker-desktop)
- [Docker para Linux](https://docs.docker.com/engine/install/)

**No necesitas instalar Flutter, Dart, PostgreSQL ni Node.js.** Todo corre en contenedores Docker.

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd EnglishProApp
```

### 2. Configurar Firebase

Debes obtener las credenciales de Firebase del equipo o crear tu propio proyecto:

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Copiar google-services.json de ejemplo
cp app/android/app/google-services.json.example app/android/app/google-services.json
```

Edita `.env` y `google-services.json` con las credenciales reales de Firebase.
Ver [SETUP.md](SETUP.md) para instrucciones detalladas.

### 3. Iniciar la Aplicación

```bash
# Windows (PowerShell)
.\start.ps1

# Linux/macOS
./start.sh
```

Este script automáticamente:
- ✅ Construye las imágenes Docker
- ✅ Inicia PostgreSQL con las 16 tablas
- ✅ Carga datos de prueba (cursos, usuarios, etc)
- ✅ Inicia el backend API
- ✅ Inicia Flutter Web

### 4. Acceder a la Aplicación

Abre tu navegador en **http://localhost:5000**

**Servicios disponibles:**
- 📱 **Flutter Web:** http://localhost:5000
- 🔌 **Backend API:** http://localhost:8080
- 🗄️ **PostgreSQL:** localhost:5432

**Usuarios de prueba:**
- `student@englishpro.com` / `password` (Plan Freemium)
- `teacher@englishpro.com` / `password` (Docente)
- `premium@englishpro.com` / `password` (Plan Premium)

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

Firebase es **OBLIGATORIO** para que la aplicación funcione (autenticación y almacenamiento).

### Opción A: Usar proyecto Firebase del equipo
Pide al líder del equipo las credenciales y el archivo `google-services.json`.

### Opción B: Crear tu propio proyecto Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Crea un nuevo proyecto "EnglishPro-Dev"
3. Habilita **Firebase Authentication** → Email/Password
4. Habilita **Firebase Storage** → Modo de prueba
5. En configuración, agrega una app Android:
   - Package name: `com.englishpro.app`
   - Descarga `google-services.json`
6. Copia el archivo a `app/android/app/google-services.json`
7. Completa las credenciales en el archivo `.env`

**Ver [SETUP.md](SETUP.md) para instrucciones detalladas paso a paso.**

## 📊 Planes de Suscripción

| Plan | Precio | Preguntas/Habilidad | Retroalimentación | Sesiones en Vivo | Simulacros |
|------|--------|---------------------|-------------------|------------------|------------|
| **Freemium** | $0.00 | 1 | Automática | ❌ | ❌ |
| **Básico** | $9.99 | 3 | Automática | ❌ | ❌ |
| **Pro** | $19.99 | 5 | Auto + Manual | ❌ | ❌ |
| **Premium** | $39.99 | 5 | Auto + Manual | ✅ 5 | ✅ 2 |

## 🧪 Testing

### Con Docker

```bash
# Tests del backend
docker-compose exec backend dart test

# Tests de Flutter
docker-compose exec flutter_web flutter test
```

### Sin Docker (si tienes Flutter instalado)

```bash
# Backend
cd backend
dart test

# Flutter
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
- [x] Containerización completa con Docker (Sprint 6 - Día 1-3)
- [ ] Build de producción (Sprint 6 - Día 4-7)
- [ ] Publicación en Play Store (Sprint 6 - Día 8-14)

## 📄 Licencia

Este proyecto es privado y está desarrollado como proyecto académico para la Universidad Nacional Mayor de San Marcos (UNMSM) - FISI.

## 🔗 Recursos

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Firebase Docs](https://firebase.google.com/docs)

---

