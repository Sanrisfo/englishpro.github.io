# Animation Assets

## 🎬 Animaciones Lottie para EnglishPro

Esta carpeta contiene animaciones en formato JSON (Lottie).

---

## 📋 Animaciones Actuales

### Ya tienes:
- Splash screen animation (si existe)

---

## 📋 Animaciones Recomendadas

### Feedback:
1. **success.json** - Respuesta correcta ✅
2. **error.json** - Respuesta incorrecta ❌
3. **celebration.json** - Completar módulo 🎉

### Estados:
4. **loading.json** - Cargando contenido
5. **empty_state.json** - Sin contenido
6. **confetti.json** - Logro desbloqueado

---

## ✅ Formato
- **JSON** (Lottie)
- Tamaño: < 200 KB
- Duración: 1-3 segundos

---

## 📝 Cómo usar Lottie:

```dart
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/animations/success.json',
  width: 200,
  height: 200,
  repeat: false,
)
```

---

## 🔍 Dónde conseguir animaciones:
- [LottieFiles](https://lottiefiles.com) ⭐ Recomendado
  - Buscar: "success", "error", "loading", "celebration"
- Todas son gratis para uso comercial

---

## 💡 Tips:
- Descarga la versión JSON, no GIF
- Prefiere animaciones simples y ligeras
- Loop: false para feedback, true para loading
