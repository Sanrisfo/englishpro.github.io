# 🛠️ Requisitos para Desarrolladores

## ⚠️ IMPORTANTE: Versiones Exactas

Para evitar problemas de "en mi máquina funciona", **todos deben usar las mismas versiones**.

---

## 📦 Software Requerido

### 1. Flutter SDK

**Versión requerida:** `3.24.0` (o superior compatible)

**Verificar tu versión:**
```bash
flutter --version
```

**Si tienes otra versión:**
```bash
# Opción A: Actualizar a la última
flutter upgrade

# Opción B: Usar versión específica con FVM (recomendado)
# Ver sección FVM abajo
```

---

### 2. Dart SDK

**Versión:** Incluida con Flutter 3.24.0 → Dart 3.5.0

**Verificar:**
```bash
dart --version
```

---

### 3. FVM (Flutter Version Manager) - RECOMENDADO ✅

**¿Por qué FVM?**
- Garantiza que todos usen Flutter 3.24.0 exactamente
- Permite tener múltiples versiones de Flutter instaladas
- Evita conflictos entre proyectos

**Instalar FVM:**
```bash
# Instalar globalmente
dart pub global activate fvm

# Verificar instalación
fvm --version
```

**Usar en el proyecto:**
```bash
# 1. Navegar al proyecto
cd EnglishPro

# 2. Instalar la versión especificada en .fvm/fvm_config.json
fvm install

# 3. Usar esa versión en este proyecto
fvm use 3.24.0

# 4. Desde ahora, usar "fvm flutter" en lugar de "flutter"
fvm flutter pub get
fvm flutter run
```

**Ventaja:** El archivo `.fvm/fvm_config.json` está en Git, así que todos automáticamente usan Flutter 3.24.0 ✅

---

### 4. Android Studio (para desarrollo Android)

**Versión mínima:** 2023.1.1 o superior

**Componentes necesarios:**
- Android SDK Platform (API 34)
- Android SDK Build-Tools
- Android Emulator (opcional, si no usas celular físico)

**Verificar:**
```bash
flutter doctor
```

Debe mostrar:
```
✓ Android toolchain - develop for Android devices (Android SDK version 34.0.0)
✓ Android Studio (version 2023.1)
```

---

### 5. XCode (solo para desarrollo iOS - Mac)

**Versión mínima:** 15.0+

**Verificar:**
```bash
xcodebuild -version
```

---

### 6. Git

**Versión:** Cualquier versión reciente

```bash
git --version
```

---

### 7. Docker (OPCIONAL - solo para backend)

**¿Cuándo lo necesitas?**
- ❌ Para login/register → NO
- ❌ Para desarrollo Flutter básico → NO
- ✅ Para backend (pagos, IA, emails) → SÍ

**Instalar:**
- Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Linux: `sudo apt install docker.io docker-compose`

**Verificar:**
```bash
docker --version
docker-compose --version
```

---

## 🚀 Setup Inicial (Nuevos Desarrolladores)

### Paso 1: Instalar Flutter + FVM

```bash
# 1. Instalar Flutter
# Descarga de: https://flutter.dev/docs/get-started/install

# 2. Instalar FVM
dart pub global activate fvm

# 3. Verificar
flutter doctor
fvm --version
```

---

### Paso 2: Clonar el Proyecto

```bash
git clone <url-del-repo>
cd EnglishPro
```

---

### Paso 3: Configurar FVM en el Proyecto

```bash
# Instalar Flutter 3.24.0 específicamente
fvm install 3.24.0

# Usar esa versión para este proyecto
fvm use 3.24.0

# Verificar (debe mostrar 3.24.0)
fvm flutter --version
```

---

### Paso 4: Configurar Variables de Entorno

```bash
cd app

# Crear archivo .env (pedir credenciales al líder del equipo)
```

**Contenido de `app/.env`:**
```env
SUPABASE_URL=https://hfanmjbhxqbljrcxvgxk.supabase.co
SUPABASE_ANON_KEY=<pedir_al_lider>
```

---

### Paso 5: Instalar Dependencias

```bash
# Desde la carpeta app/
fvm flutter pub get
```

---

### Paso 6: Ejecutar la App

```bash
# Conectar celular o iniciar emulador
# Luego:
fvm flutter run
```

---

## ✅ Verificar que Todo Funciona

```bash
flutter doctor -v
```

**Debe mostrar:**
```
[✓] Flutter (Channel stable, 3.24.0, on <tu OS>)
[✓] Android toolchain
[✓] Chrome (para web)
[✓] Android Studio
[✓] Connected device (1 available)
[✓] Network resources
```

Si algo muestra `[✗]`, ejecuta las soluciones sugeridas.

---

## 🐛 Troubleshooting

### "fvm command not found"

**Causa:** No agregaste FVM al PATH.

**Solución:**
```bash
# Ver dónde está instalado
dart pub global list

# Agregar al PATH (ejemplo Linux/Mac):
export PATH="$PATH:$HOME/.pub-cache/bin"

# O agregar permanentemente a ~/.bashrc o ~/.zshrc
```

---

### "Flutter version mismatch"

**Causa:** Usaste `flutter` en lugar de `fvm flutter`.

**Solución:**
```bash
# Usar siempre "fvm flutter"
fvm flutter pub get
fvm flutter run

# O crear alias (opcional):
alias flutter="fvm flutter"
alias dart="fvm dart"
```

---

### "Could not find package supabase_flutter"

**Causa:** No ejecutaste `pub get`.

**Solución:**
```bash
cd app
fvm flutter pub get
```

---

### "No devices found"

**Causa:** No hay celular conectado ni emulador iniciado.

**Solución:**
```bash
# Ver dispositivos disponibles
fvm flutter devices

# Iniciar emulador Android
emulator -avd Pixel_5_API_34

# O conectar celular físico por USB (habilitar depuración USB)
```

---

## 📊 Resumen de Versiones

| Software | Versión Requerida | ¿Obligatorio? |
|----------|-------------------|---------------|
| **Flutter** | 3.24.0 | ✅ SÍ |
| **Dart** | 3.5.0 (con Flutter) | ✅ SÍ |
| **FVM** | Última | 🟡 Recomendado |
| **Android Studio** | 2023.1+ | ✅ SÍ (Android) |
| **XCode** | 15+ | ✅ SÍ (iOS - Mac) |
| **Docker** | Última | 🟢 Opcional |
| **Git** | Cualquiera | ✅ SÍ |

---

## 🎯 Comandos Rápidos

```bash
# Ver versión de Flutter
fvm flutter --version

# Instalar dependencias
fvm flutter pub get

# Ejecutar app
fvm flutter run

# Ejecutar tests
fvm flutter test

# Limpiar build (si hay problemas)
fvm flutter clean
fvm flutter pub get

# Ver dispositivos
fvm flutter devices

# Analizar código
fvm flutter analyze
```

---

## 🔄 Actualizar Flutter en el Futuro

**Si el equipo decide actualizar a Flutter 3.25.0:**

1. Líder actualiza `.fvm/fvm_config.json`:
   ```json
   {
     "flutterSdkVersion": "3.25.0"
   }
   ```

2. Commitea y pushea

3. Todos los devs ejecutan:
   ```bash
   git pull
   fvm install  # Instala 3.25.0
   fvm flutter pub get
   ```

**Todos automáticamente usan 3.25.0 ahora** ✅

---

## 📞 Soporte

Si tienes problemas:
1. Ejecuta `flutter doctor -v` y comparte el output
2. Verifica que estés usando `fvm flutter` (no solo `flutter`)
3. Asegúrate de tener `app/.env` configurado
4. Contacta al líder del equipo

---

## ✅ Checklist Final

- [ ] Flutter 3.24.0 instalado
- [ ] FVM instalado y configurado
- [ ] `fvm flutter --version` muestra 3.24.0
- [ ] Android Studio instalado (con Android SDK)
- [ ] `flutter doctor` muestra todo OK
- [ ] Proyecto clonado: `git clone ...`
- [ ] Variables configuradas: `app/.env` existe
- [ ] Dependencias instaladas: `fvm flutter pub get`
- [ ] App ejecuta: `fvm flutter run`

**Si todo tiene ✅ → Listo para desarrollar** 🚀
