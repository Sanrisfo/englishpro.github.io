# Font Assets

## 🔤 Fuentes Personalizadas para EnglishPro

Esta carpeta contiene fuentes tipográficas personalizadas (OPCIONAL).

---

## 📋 Fuentes Recomendadas

### Para UI moderna:
1. **Poppins**
   - Poppins-Regular.ttf
   - Poppins-Medium.ttf
   - Poppins-Bold.ttf

### Para contenido:
2. **Roboto** (ya incluida en Material Design)
3. **Inter**
4. **Open Sans**

---

## ✅ Formatos Aceptados
- TTF (TrueType Font)
- OTF (OpenType Font)

---

## 📝 Cómo agregar fuentes:

1. **Descargar fuentes** de [Google Fonts](https://fonts.google.com)

2. **Colocar archivos** en esta carpeta

3. **Actualizar pubspec.yaml**:
```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/Poppins-Regular.ttf
      - asset: assets/fonts/Poppins-Medium.ttf
        weight: 500
      - asset: assets/fonts/Poppins-Bold.ttf
        weight: 700
```

4. **Usar en Flutter**:
```dart
TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.bold,
)
```

---

## 🔍 Dónde conseguir fuentes:
- [Google Fonts](https://fonts.google.com) ⭐ Recomendado
- [Font Squirrel](https://www.fontsquirrel.com)
- [DaFont](https://www.dafont.com)

---

## 💡 Nota:
Las fuentes personalizadas son **OPCIONALES**.
Material Design ya incluye Roboto.
Solo agregar si quieres un estilo único.
