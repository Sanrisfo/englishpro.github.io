# 🚀 INICIO RÁPIDO - EnglishPro

**Lee esto primero antes de trabajar en el proyecto**

---

## 📋 Resumen Ejecutivo

**EnglishPro** es una aplicación móvil educativa para estudiantes de inglés de nivel intermedio-avanzado que se preparan para exámenes internacionales (TOEFL, IELTS) o quieren mejorar su inglés profesional/cotidiano.

### Estado Actual
- ✅ **Fase 1 COMPLETA**: Login/Register con Supabase funcional
- ✅ **Migración a Supabase**: Completada (desde Firebase)
- ✅ **Backend**: Deshabilitado temporalmente (no necesario ahora)
- ✅ **Estructura**: Limpia y organizada

---

## 🎯 ¿Qué hace la aplicación?

### 4 Módulos Educativos
1. **TOEFL** - Preparación para examen
2. **IELTS** - Preparación para examen
3. **Business English** - Inglés corporativo (estilo Rosetta Stone)
4. **English in Action** - Inglés cotidiano (estilo Rosetta Stone)

### 4 Habilidades por Módulo
- 📝 **Writing** - Redacción
- 🗣️ **Speaking** - Expresión oral (con grabación de audio)
- 👂 **Listening** - Comprensión auditiva
- 📖 **Reading** - Comprensión lectora

### 4 Planes de Suscripción
- **Freemium** ($0) - 1 pregunta/habilidad
- **Básico** ($9.99) - 3 preguntas/habilidad
- **Pro** ($19.99) - 5 preguntas + retroalimentación docente
- **Premium** ($39.99) - Todo + sesiones en vivo + simulacros

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| **Frontend** | Flutter | 3.35.4 (FVM) |
| **Lenguaje** | Dart | 3.9.2+ |
| **Base de Datos** | Supabase (PostgreSQL) | Cloud |
| **Auth** | Supabase Auth | Cloud |
| **Storage** | Supabase Storage | Cloud |
| **Backend** | Dart (Shelf) | 3.9.2 (Docker - opcional) |
| **Control de versiones** | Git + FVM | - |

---

## 📁 Estructura del Proyecto

```
EnglishPro/
├── 📱 app/                          # Aplicación Flutter
│   ├── lib/
│   │   ├── main.dart               # Entry point
│   │   ├── config/
│   │   │   └── supabase_config.dart
│   │   ├── services/
│   │   │   ├── supabase_auth_service.dart
│   │   │   └── supabase_storage_service.dart
│   │   ├── screens/                # 13+ pantallas
│   │   ├── models/                 # 8 modelos
│   │   ├── widgets/                # Componentes reutilizables
│   │   └── providers/              # Estado (Provider)
│   ├── .env                        # Credenciales Supabase
│   └── pubspec.yaml                # Dependencias
│
├── 🗄️ database/                    # Scripts SQL
│   ├── schema.sql                  # 16 tablas (YA EJECUTADO)
│   ├── seed.sql                    # Datos de prueba
│   ├── DISABLE_RLS_TEMPORAL.sql    # (YA EJECUTADO)
│   └── FIX_TRIGGER.sql             # (YA EJECUTADO)
│
├── 📦 No_Necesarios/               # Backend + Documentación antigua
│   ├── backend/                    # Servidor Dart (para futuro)
│   ├── docker-compose.yml          # Docker (para futuro)
│   └── *.md                        # 28 archivos de documentación
│
├── 📚 contexto/                    # 👈 ESTA CARPETA (contexto rápido)
│   ├── 00_INICIO_RAPIDO.md        # Este archivo
│   ├── 01_ARQUITECTURA.md          # Arquitectura del sistema
│   ├── 02_BASE_DE_DATOS.md         # Esquema y relaciones
│   ├── 03_APP_FLUTTER.md           # Estructura de la app
│   └── 04_ESTADO_Y_PROXIMOS_PASOS.md
│
├── .fvm/                           # Flutter Version Manager
│   └── fvm_config.json             # Flutter 3.35.4
│
├── .env                            # Variables backend (opcional)
├── .gitignore
└── README.md
```

---

## ⚡ Setup en 5 Minutos

### Prerrequisitos
- Flutter 3.35.4 (o usar FVM)
- Dart 3.9.2+
- Git
- Celular o emulador Android/iOS

### Pasos

```bash
# 1. Clonar proyecto
git clone <url-del-repo>
cd EnglishPro

# 2. (Opcional pero recomendado) Instalar FVM
dart pub global activate fvm
fvm install 3.35.4
fvm use 3.35.4

# 3. Crear archivo .env en app/
cd app
# Crear .env con credenciales Supabase (pedir al líder)

# 4. Instalar dependencias
fvm flutter pub get
# O sin FVM: flutter pub get

# 5. Ejecutar app
fvm flutter run
# O sin FVM: flutter run
```

### Contenido de `app/.env`

```env
SUPABASE_URL=https://robuivsvyajriongiafh.supabase.co
SUPABASE_ANON_KEY=<pedir_al_lider_del_equipo>
```

---

## 🔑 Credenciales y Accesos

### Supabase
- **URL**: https://robuivsvyajriongiafh.supabase.co
- **Dashboard**: https://supabase.com/dashboard/project/robuivsvyajriongiafh
- **Credenciales**: En `app/.env` (NO en Git)

### Base de Datos
- **Host**: db.robuivsvyajriongiafh.supabase.co
- **Puerto**: 5432
- **Database**: postgres
- **16 Tablas** ya creadas y configuradas

---

## 📚 Archivos de Contexto (Esta Carpeta)

| Archivo | Qué contiene |
|---------|--------------|
| `00_INICIO_RAPIDO.md` | Este archivo - Resumen ejecutivo |
| `01_ARQUITECTURA.md` | Arquitectura del sistema, flujos, decisiones técnicas |
| `02_BASE_DE_DATOS.md` | Esquema completo, relaciones, triggers, RLS |
| `03_APP_FLUTTER.md` | Estructura de la app, servicios, pantallas, modelos |
| `04_ESTADO_Y_PROXIMOS_PASOS.md` | Qué funciona, qué falta, roadmap |

**Tiempo estimado de lectura completa: 15-20 minutos**

---

## 🎯 Flujo de Trabajo Actual

### Login/Register (FUNCIONAL ✅)

```
Usuario → App Flutter → Supabase Auth → Tabla Usuarios
              ↓                              ↓
        Guarda sesión                  Trigger crea
        localmente                    Beneficios_Usuario
```

### Cursos y Materiales (FUNCIONAL ✅)

```
Usuario → Home Screen → Selecciona Curso → Habilidades
                            ↓
                    Materiales (PDF, Video, Audio)
                            ↓
                    Quiz/Cuestionarios
                            ↓
                    Respuestas → Supabase
```

### Backend (DESHABILITADO TEMPORALMENTE)

El backend en `No_Necesarios/backend/` está disponible para:
- Integración con Stripe (pagos)
- IA para calificar pronunciación (OpenAI Whisper)
- Generación de certificados PDF
- Envío de emails

**No se necesita ahora**, pero está listo para restaurarse cuando sea necesario.

---

## 🚫 NO Necesitas

- ❌ Docker (ahora)
- ❌ Backend corriendo (ahora)
- ❌ PostgreSQL local
- ❌ Firebase (migrado a Supabase)
- ❌ Ejecutar SQL manualmente (ya ejecutado)

---

## ✅ SÍ Necesitas

- ✅ Flutter 3.35.4 (FVM recomendado)
- ✅ `app/.env` con credenciales Supabase
- ✅ Conexión a internet
- ✅ Celular o emulador
- ✅ Git

---

## 🧪 Probar que Funciona

```bash
cd app
fvm flutter run
# O: flutter run

# Espera a que compile...
# Se abre la app en tu celular/emulador

# Probar:
1. Tap en "Register"
2. Crear cuenta con email/password
3. Login
4. Deberías ver HomeScreen con 4 cursos
```

**Si ves los 4 cursos (TOEFL, IELTS, Business, Action) → ✅ TODO FUNCIONA**

---

## 📖 Siguiente Paso

**Lee los archivos de contexto en orden:**

1. `01_ARQUITECTURA.md` - Entender cómo funciona el sistema
2. `02_BASE_DE_DATOS.md` - Conocer las tablas y relaciones
3. `03_APP_FLUTTER.md` - Estructura de código Flutter
4. `04_ESTADO_Y_PROXIMOS_PASOS.md` - Qué sigue

---

## 🆘 Problemas Comunes

### "Missing Supabase credentials"
→ Falta crear `app/.env` con SUPABASE_URL y SUPABASE_ANON_KEY

### "Command not found: fvm"
→ Instalar FVM: `dart pub global activate fvm`

### "No devices found"
→ Conectar celular o iniciar emulador: `flutter devices`

### "Could not find table 'usuarios'"
→ SQL no ejecutado en Supabase (contactar líder del equipo)

---

## 👥 Equipo

- **Pedro Yanyachi** - Jefe de Proyecto
- **Angelo Goitia** - Analista de Requisitos
- **Juan Diego Bernilla** - Diseñador UI/UX
- **Josue Martines** - Desarrollador Móvil
- **Santiago Rodriguez** - Tester de Calidad
- **Piero Vargas** - Documentador

---

## 📅 Estado del Proyecto

**Sprint actual:** Sprint 6 (Final)
**Fecha:** Octubre 2024
**Estado:** ✅ Login/Register funcional, migración a Supabase completada

### Completado
- [x] Setup inicial
- [x] Sistema de autenticación (Supabase)
- [x] Home screen y navegación
- [x] Estructura de contenido
- [x] Sistema de evaluación
- [x] Progreso y monetización
- [x] Panel docente
- [x] Sistema de roles
- [x] Notificaciones

### Próximos Pasos
- [ ] Testing completo
- [ ] Optimización de rendimiento
- [ ] Build de producción
- [ ] Publicación en Play Store

---

## 🔗 Recursos

- [Flutter Docs](https://docs.flutter.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [Dart Docs](https://dart.dev/guides)
- [Documentación antigua](../No_Necesarios/) - 28 archivos MD

---

**¡Listo! Ahora lee `01_ARQUITECTURA.md` para entender cómo funciona el sistema** 🚀
