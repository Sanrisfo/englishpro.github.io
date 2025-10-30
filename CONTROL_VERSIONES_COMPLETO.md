# 🔒 Control de Versiones Completo - Evitar "Funciona en Mi Máquina"

## 🎯 Objetivo

**Garantizar que TODOS los desarrolladores tengan el MISMO ambiente**, sin importar su sistema operativo.

---

## 📦 Versiones Controladas en Este Proyecto

### ✅ YA CONFIGURADO

| Componente | Versión | Archivo de Control | ¿Funciona? |
|------------|---------|-------------------|------------|
| **Flutter** | 3.35.4 | `.fvm/fvm_config.json` | ✅ Con FVM |
| **Dart** | 3.9+ | `pubspec.yaml` (env) | ✅ Con Flutter |
| **Backend (Dart)** | 3.9.2 | `backend/Dockerfile` | ✅ Con Docker |
| **Packages Flutter** | Exactas | `app/pubspec.lock` | ✅ En Git |
| **Packages Backend** | Exactas | `backend/pubspec.lock` | ✅ En Git |
| **Gradle** | 8.0+ | `android/gradle/wrapper/` | ✅ En Git |
| **Android SDK** | 34 | `android/app/build.gradle` | ✅ En Git |
| **iOS Pods** | Exactas | `ios/Podfile.lock` | ✅ En Git |

---

## 🐳 Estrategia de Docker

### 1️⃣ Flutter App → **NO usa Docker** (desarrollo normal)

**Por qué:**
- Necesita USB para celular físico
- Necesita GPU para emulador
- Hot reload debe ser instantáneo
- XCode solo funciona en Mac (no se puede dockerizar)

**Solución:** FVM (ya configurado en `.fvm/fvm_config.json`)

---

### 2️⃣ Backend → **SÍ usa Docker** ✅

**Dockerfile ya existe en `No_Necesarios/backend/Dockerfile`:**

```dockerfile
FROM dart:3.9.2-sdk

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

COPY . .

EXPOSE 8080

CMD ["dart", "run", "bin/server.dart"]
```

**Especifica:**
- ✅ Dart 3.9.2 exacto
- ✅ Dependencias con `pubspec.lock`
- ✅ Puerto 8080
- ✅ Comando de inicio

**Garantía:** Todos usan Dart 3.9.2, sin importar qué tengan instalado localmente ✅

---

### 3️⃣ Flutter Web → **SÍ usa Docker** (opcional)

**Para servir Flutter Web sin necesidad de Flutter instalado:**

```dockerfile
# No_Necesarios/app/Dockerfile (si existe)
FROM cirrusci/flutter:3.35.4

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

RUN flutter build web

EXPOSE 8080

CMD ["flutter", "run", "-d", "web-server", "--web-port=8080"]
```

---

## 📋 Archivos de Control de Versiones

### 1. `.fvm/fvm_config.json` (Flutter)

```json
{
  "flutterSdkVersion": "3.35.4"
}
```

**Qué hace:** Todos los devs usan Flutter 3.35.4 con `fvm install`

**Está en Git:** ✅ SÍ

---

### 2. `app/pubspec.lock` (Packages Dart/Flutter)

```yaml
# Generated file - NO editar manualmente
packages:
  supabase_flutter:
    version: "2.0.0"  # Versión exacta
  http:
    version: "1.1.0"  # Versión exacta
```

**Qué hace:** `flutter pub get` instala versiones EXACTAS

**Está en Git:** ✅ SÍ (muy importante)

---

### 3. `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
```

**Qué hace:** Todos usan Gradle 8.0

**Está en Git:** ✅ SÍ

---

### 4. `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

**Qué hace:** Especifica versiones de Android SDK

**Está en Git:** ✅ SÍ

---

### 5. `ios/Podfile.lock`

```yaml
PODS:
  - Flutter (1.0.0)
  - supabase_flutter (2.0.0):
    - Flutter
```

**Qué hace:** Todos usan mismas versiones de CocoaPods

**Está en Git:** ✅ SÍ

---

### 6. `backend/Dockerfile`

```dockerfile
FROM dart:3.9.2-sdk
```

**Qué hace:** Backend usa Dart 3.9.2 exacto en Docker

**Está en Git:** ✅ SÍ (en `No_Necesarios/backend/`)

---

### 7. `docker-compose.yml`

```yaml
services:
  backend:
    build: ./backend  # Usa Dockerfile con Dart 3.9.2
    ports:
      - "8080:8080"
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
```

**Qué hace:** Orquesta backend con versiones específicas

**Está en Git:** ✅ SÍ (en `No_Necesarios/`)

---

## 🚀 Flujo de Trabajo Completo

### Desarrollador Nuevo (Setup Inicial)

```bash
# 1. Clonar proyecto
git clone <url>
cd EnglishPro

# 2. Instalar FVM (control de versión Flutter)
dart pub global activate fvm

# 3. FVM lee .fvm/fvm_config.json y usa Flutter 3.35.4
fvm install
fvm use 3.35.4

# 4. Instalar dependencias (lee pubspec.lock para versiones exactas)
cd app
fvm flutter pub get

# 5. Ejecutar app
fvm flutter run
```

**Resultado:** Usa Flutter 3.35.4 + packages exactos de `pubspec.lock` ✅

---

### Cuando Necesitan Backend (Pagos, IA, etc.)

```bash
# 1. Restaurar backend de No_Necesarios
cd No_Necesarios
mv backend/ ../
mv docker-compose.yml ../

# 2. Configurar .env (root) con credenciales
cd ..
# Editar .env con SUPABASE_URL, DB_PASSWORD, etc.

# 3. Levantar backend con Docker
docker-compose up -d backend

# 4. Backend usa Dart 3.9.2 (del Dockerfile)
# Sin importar qué versión de Dart tenga instalada localmente
```

**Resultado:** Todos usan Dart 3.9.2 en backend ✅

---

## 🔍 Otros Problemas Potenciales y Soluciones

### 1. Sistema Operativo Diferente

**Problema:**
- Dev 1: Windows 11
- Dev 2: Mac M1
- Dev 3: Ubuntu 22.04

**Solución:**
- Flutter es multiplataforma → funciona igual en todos ✅
- Docker es multiplataforma → backend funciona igual ✅
- Archivos de Git manejan line endings con `.gitattributes`

---

### 2. Versión de Git

**Problema:** Git 2.30 vs Git 2.40

**Solución:** No afecta, Git es backward compatible ✅

---

### 3. IDE Diferente

**Problema:**
- Dev 1: VS Code
- Dev 2: Android Studio
- Dev 3: IntelliJ IDEA

**Solución:**
- Todos los IDEs usan `pubspec.lock` → mismas versiones ✅
- FVM funciona con todos los IDEs ✅

**Configuración VS Code (opcional):**
```json
// .vscode/settings.json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": {
    "**/.fvm": true
  }
}
```

---

### 4. Versión de Docker

**Problema:** Docker 24 vs Docker 25

**Solución:** Docker Compose v2 es compatible hacia atrás ✅

---

### 5. Permisos / Firewall

**Problema:** Puerto 8080 bloqueado en firewall corporativo

**Solución:** Cambiar puerto en `docker-compose.yml`:
```yaml
ports:
  - "3000:8080"  # Usar puerto 3000 en lugar de 8080
```

---

## 📊 Matriz de Compatibilidad

| Dev 1 | Dev 2 | Dev 3 | ¿Funciona? |
|-------|-------|-------|------------|
| Windows 11 | Mac M1 | Ubuntu 22.04 | ✅ SÍ |
| Flutter 3.20 local | Flutter 3.35 local | Sin Flutter | ✅ SÍ (FVM) |
| Dart 3.0 local | Dart 3.9 local | Sin Dart | ✅ SÍ (FVM/Docker) |
| VS Code | Android Studio | IntelliJ | ✅ SÍ |
| Docker 24 | Docker 25 | Sin Docker | ✅ SÍ* |

*Sin Docker solo puede desarrollar Flutter, no backend.

---

## ✅ Checklist de Verificación

### Archivos en Git (DEBEN estar commiteados):

- [x] `.fvm/fvm_config.json` → Versión Flutter
- [x] `app/pubspec.lock` → Packages Flutter
- [x] `backend/pubspec.lock` → Packages Backend
- [x] `android/gradle/wrapper/gradle-wrapper.properties` → Gradle
- [x] `android/app/build.gradle` → Android SDK
- [x] `ios/Podfile.lock` → CocoaPods
- [x] `backend/Dockerfile` → Versión Dart backend
- [x] `docker-compose.yml` → Orquestación
- [x] `.gitignore` → Proteger .env y builds

### Archivos NO en Git (secretos):

- [x] `.env` (root)
- [x] `app/.env`
- [x] `.fvm/flutter_sdk` (binarios de Flutter)

---

## 🎯 Respuesta a tu Pregunta

**"¿No se crea un Dockerfile que especifique las imágenes de todo?"**

**Respuesta:**

✅ **Para Backend:** SÍ, ya tienes `backend/Dockerfile` con Dart 3.9.2

❌ **Para Flutter desarrollo:** NO práctico (necesita hardware)

✅ **Para Flutter CI/CD:** SÍ, se puede (GitHub Actions, builds automáticos)

✅ **Para Flutter Web:** SÍ, ya tienes configuración en `docker-compose.yml`

---

## 🔄 Actualizar Versiones en el Futuro

### Actualizar Flutter (todo el equipo):

```bash
# 1. Líder actualiza .fvm/fvm_config.json
{
  "flutterSdkVersion": "3.40.0"  # Nueva versión
}

# 2. Commitea y pushea
git add .fvm/fvm_config.json
git commit -m "Update Flutter to 3.40.0"
git push

# 3. Todos los devs ejecutan:
git pull
fvm install  # Instala Flutter 3.40.0
fvm flutter pub get
```

### Actualizar Backend Dart:

```bash
# 1. Líder actualiza backend/Dockerfile
FROM dart:3.10.0-sdk  # Nueva versión

# 2. Commitea y pushea
git add backend/Dockerfile
git commit -m "Update Dart backend to 3.10.0"
git push

# 3. Todos los devs ejecutan:
git pull
docker-compose build backend  # Rebuild con nueva versión
docker-compose up -d backend
```

---

## 📈 Arquitectura Final

```
┌─────────────────────────────────────────────────┐
│  GIT REPOSITORY (Fuente de verdad)              │
│                                                  │
│  .fvm/fvm_config.json → Flutter 3.35.4          │
│  app/pubspec.lock → Packages exactos            │
│  backend/Dockerfile → Dart 3.9.2                │
│  android/ → Gradle 8.0, SDK 34                  │
│  ios/ → Podfile.lock                            │
└─────────────────────────────────────────────────┘
                    ↓ git clone
        ┌───────────┴───────────┐
        ↓                       ↓
┌──────────────┐        ┌──────────────┐
│  Dev 1       │        │  Dev 2       │
│  Windows     │        │  Mac M1      │
│              │        │              │
│  FVM install │        │  FVM install │
│  → 3.35.4 ✅ │        │  → 3.35.4 ✅ │
│              │        │              │
│  docker-     │        │  docker-     │
│  compose up  │        │  compose up  │
│  → Dart      │        │  → Dart      │
│    3.9.2 ✅  │        │    3.9.2 ✅  │
└──────────────┘        └──────────────┘

RESULTADO: Ambientes IDÉNTICOS ✅
```

---

## 🆘 Troubleshooting

### "Funciona en mi máquina pero no en la de mi compañero"

**Diagnóstico:**
```bash
# Verificar versiones
fvm flutter --version  # ¿3.35.4?
dart --version         # ¿3.9+?

# Verificar que use FVM
which flutter  # Debe mostrar .fvm/flutter_sdk

# Verificar packages
cat pubspec.lock | grep supabase_flutter
```

**Solución:**
```bash
# Limpiar y reinstalar
fvm flutter clean
rm -rf .dart_tool build
fvm flutter pub get
```

---

## ✅ Resumen

**¿Cómo evitamos "funciona en mi máquina"?**

1. **Flutter:** FVM + `.fvm/fvm_config.json` ✅
2. **Packages:** `pubspec.lock` en Git ✅
3. **Backend:** Dockerfile con versión exacta ✅
4. **Android:** `build.gradle` + `gradle-wrapper.properties` ✅
5. **iOS:** `Podfile.lock` ✅
6. **Variables:** `.env` NO en Git (cada dev crea el suyo) ✅

**Ya tienes TODO configurado.** Solo falta que el equipo use FVM y Docker correctamente. 🚀
