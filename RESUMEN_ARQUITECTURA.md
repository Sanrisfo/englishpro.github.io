# 🏗️ Arquitectura del Proyecto - Resumen Visual

## 📊 Stack Tecnológico

```
┌─────────────────────────────────────────────────────────┐
│                    ENGLISHPRO                            │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  FLUTTER APP  │  │    BACKEND    │  │   SUPABASE    │
│               │  │               │  │               │
│  Dart 3.9+    │  │  Dart 3.9.2   │  │  PostgreSQL   │
│  Flutter 3.35 │  │  Express      │  │  Auth         │
│               │  │  (Docker)     │  │  Storage      │
│  Android/iOS  │  │               │  │               │
└───────────────┘  └───────────────┘  └───────────────┘
      ↓                    ↓                   ↑
   Celular           http://localhost:8080    Cloud
   Emulador                 ↓
                           API
                            ↑
                    ┌───────┴────────┐
                    │                │
              Login/Register    Pagos/IA
              (Directo)         (Backend)
```

---

## 🔧 Control de Versiones

```
┌─────────────────────────────────────────────────────┐
│              GIT (Fuente de Verdad)                  │
├─────────────────────────────────────────────────────┤
│                                                      │
│  📱 FLUTTER                                          │
│  ├─ .fvm/fvm_config.json → 3.35.4                  │
│  ├─ app/pubspec.lock → Packages exactos            │
│  └─ FVM maneja versiones                           │
│                                                      │
│  🔧 BACKEND                                          │
│  ├─ backend/Dockerfile → Dart 3.9.2                │
│  ├─ docker-compose.yml → Orquestación              │
│  └─ Docker maneja versiones                        │
│                                                      │
│  🤖 ANDROID                                          │
│  ├─ build.gradle → SDK 34                          │
│  ├─ gradle-wrapper.properties → Gradle 8.0         │
│  └─ Android Studio sincroniza                      │
│                                                      │
│  🍎 iOS                                              │
│  ├─ Podfile.lock → Pods exactos                    │
│  └─ CocoaPods sincroniza                           │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Flujo de Desarrollo

### Fase 1: ACTUAL (Sin Backend)

```
┌──────────────┐
│ Desarrollador│
└──────────────┘
       ↓
   git clone
       ↓
   fvm install (Flutter 3.35.4)
       ↓
   flutter pub get (packages exactos)
       ↓
   flutter run
       ↓
┌──────────────┐         ┌──────────────┐
│  App Mobile  │────────▶│   Supabase   │
│              │  Auth   │   (Cloud)    │
│  Login       │  CRUD   │              │
│  Cursos      │ Storage │              │
└──────────────┘         └──────────────┘

✅ NO necesita Docker
✅ NO necesita backend local
✅ Conecta directo a Supabase
```

---

### Fase 2: FUTURO (Con Backend para Pagos/IA)

```
┌──────────────┐
│ Desarrollador│
└──────────────┘
       ↓
   Restaurar backend de No_Necesarios/
       ↓
   docker-compose up backend
       ↓
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  App Mobile  │────────▶│   Backend    │────────▶│   Supabase   │
│              │  API    │   (Docker)   │  Query  │   (Cloud)    │
│  Login ──────┼────────▶│              │────────▶│              │
│  Pagos ──────┤         │  Dart 3.9.2  │         │  PostgreSQL  │
│  IA Audio ───┤         │  Stripe API  │         │              │
│  Certs PDF ──┤         │  OpenAI API  │         │              │
└──────────────┘         └──────────────┘         └──────────────┘

✅ SÍ necesita Docker (backend)
✅ Backend usa Dockerfile (Dart 3.9.2)
✅ App sigue sin Docker
```

---

## 📂 Estructura de Archivos

```
EnglishPro/
│
├── 📱 FLUTTER APP
│   ├── app/
│   │   ├── .env                    # ⚠️ Credenciales (NO en Git)
│   │   ├── pubspec.yaml            # Dependencias
│   │   ├── pubspec.lock            # ✅ Versiones exactas (EN GIT)
│   │   └── lib/
│   │       ├── main.dart
│   │       ├── services/
│   │       │   └── supabase_auth_service.dart
│   │       └── screens/
│   │
│   └── .fvm/
│       └── fvm_config.json         # ✅ Flutter 3.35.4 (EN GIT)
│
├── 🔧 CONTROL DE VERSIONES
│   ├── .gitignore                  # Proteger secretos
│   ├── .gitattributes              # Line endings
│   └── README.md
│
├── 🗄️ DATABASE
│   ├── schema.sql                  # Ya ejecutado en Supabase
│   ├── DISABLE_RLS_TEMPORAL.sql    # Ya ejecutado
│   └── FIX_TRIGGER.sql             # Ya ejecutado
│
└── 📦 NO_NECESARIOS/ (Backend, Docker, Docs)
    ├── backend/
    │   ├── Dockerfile              # ✅ Dart 3.9.2 (EN GIT)
    │   ├── pubspec.yaml
    │   └── pubspec.lock            # ✅ Versiones exactas (EN GIT)
    │
    ├── docker-compose.yml          # ✅ Orquestación (EN GIT)
    │
    └── *.md (20+ documentos)
```

---

## 🎯 Decisiones de Arquitectura

| Decisión | Razón | Alternativa Descartada |
|----------|-------|------------------------|
| **Flutter sin Docker** | Necesita hardware (USB, GPU) | Docker para Flutter (muy lento) |
| **Backend con Docker** | Aislar versiones de Dart/Node | Backend local (conflictos de versión) |
| **Supabase Cloud** | Escalable, sin mantener DB | PostgreSQL local (más trabajo) |
| **FVM para Flutter** | Control exacto de versión | Confiar en `flutter upgrade` (inconsistente) |
| **RLS deshabilitado** | Desarrollo rápido | RLS habilitado (recursión infinita) |
| **Auth directo Supabase** | Menos código, más simple | Auth vía backend (más complejo) |

---

## 🔄 Workflows

### Login/Register (Ahora)

```
Usuario → App Flutter → Supabase Auth → Usuarios Table
                ↑                            ↓
                └──────── session ───────────┘
```

**Sin backend** ✅

---

### Pago con Stripe (Futuro)

```
Usuario → App Flutter → Backend (Docker) → Stripe API
                            ↓                  ↓
                        Supabase        Payment Success
                        (Update plan)
```

**Con backend** ✅

---

### Calificar Audio con IA (Futuro)

```
Usuario → Graba audio → App Flutter → Backend (Docker) → OpenAI Whisper
                                           ↓                    ↓
                                       Supabase           Transcription
                                       (Save score)
```

**Con backend** ✅

---

## ✅ Garantías de Este Setup

| Garantía | ¿Cómo? |
|----------|--------|
| **Misma versión Flutter** | FVM + `.fvm/fvm_config.json` en Git |
| **Mismos packages Flutter** | `pubspec.lock` en Git |
| **Misma versión Backend** | Dockerfile con `dart:3.9.2-sdk` |
| **Mismos packages Backend** | `backend/pubspec.lock` en Git |
| **Mismo Gradle** | `gradle-wrapper.properties` en Git |
| **Mismo Android SDK** | `build.gradle` en Git |
| **Mismos Pods iOS** | `Podfile.lock` en Git |
| **Mismos line endings** | `.gitattributes` en Git |

---

## 🆘 Troubleshooting Rápido

```bash
# Problema: "Funciona en mi máquina, no en la tuya"

# 1. Verificar versiones
fvm flutter --version  # ¿3.35.4?
dart --version         # ¿3.9+?

# 2. Limpiar y reinstalar
fvm flutter clean
rm -rf .dart_tool build
fvm flutter pub get

# 3. Verificar .env
cat app/.env  # ¿Tiene SUPABASE_URL?

# 4. Verificar packages
cat app/pubspec.lock | grep supabase_flutter
# Debe mostrar version: "2.0.0" (o la que sea)

# 5. Si nada funciona
git status  # ¿Cambios sin commitear?
git diff   # ¿Qué cambió?
```

---

## 📈 Roadmap

### ✅ Fase 1 (COMPLETADO)
- [x] Login/Register con Supabase
- [x] FVM configurado
- [x] RLS deshabilitado (temporal)
- [x] Estructura limpia
- [x] Documentación completa

### 🔄 Fase 2 (Futuro - Cuando necesiten)
- [ ] Restaurar backend de `No_Necesarios/`
- [ ] Implementar pagos con Stripe
- [ ] IA para calificar pronunciación
- [ ] Generar certificados PDF
- [ ] Habilitar RLS correcto

---

## 🎯 Resumen Ultra-Rápido

**¿Dockerizar todo?**
- Backend: ✅ SÍ (ya está)
- Flutter desarrollo: ❌ NO (FVM en su lugar)
- Flutter CI/CD: ✅ SÍ (opcional)

**¿Versiones controladas?**
- ✅ TODO controlado con archivos en Git
- ✅ FVM para Flutter
- ✅ Docker para Backend
- ✅ Lock files para packages

**¿Problema "funciona en mi máquina"?**
- ✅ RESUELTO con esta arquitectura

🚀 **Proyecto listo para escalar con múltiples desarrolladores**
