# EnglishPro - Guía de Testing Manual

## Sprint 1 Días 11-14: Testing de Autenticación y Navegación

### Fecha: 2025-10-07
### Estado: En Progreso

---

## 📋 Checklist de Testing

### 1. Sistema de Autenticación con Firebase

#### 1.1 Registro de Usuario
- [ ] **Test 1**: Registro exitoso con datos válidos
  - Email: `test@englishpro.com`
  - Contraseña: `Test123456!`
  - Nombre: `Test User`
  - **Resultado esperado**: Usuario creado, redirección al Home

- [ ] **Test 2**: Registro con email duplicado
  - Usar el mismo email del Test 1
  - **Resultado esperado**: Error mostrado al usuario

- [ ] **Test 3**: Registro con email inválido
  - Email: `invalidemail`
  - **Resultado esperado**: Error de validación

- [ ] **Test 4**: Registro con contraseña débil
  - Contraseña: `123`
  - **Resultado esperado**: Error de Firebase (mínimo 6 caracteres)

- [ ] **Test 5**: Registro con campos vacíos
  - **Resultado esperado**: Error de validación

#### 1.2 Login de Usuario
- [ ] **Test 6**: Login exitoso con credenciales correctas
  - Email: `test@englishpro.com`
  - Contraseña: `Test123456!`
  - **Resultado esperado**: Login exitoso, redirección al Home

- [ ] **Test 7**: Login con credenciales incorrectas
  - Email: `test@englishpro.com`
  - Contraseña: `WrongPassword`
  - **Resultado esperado**: Error de autenticación mostrado

- [ ] **Test 8**: Login con usuario no existente
  - Email: `noexiste@englishpro.com`
  - **Resultado esperado**: Error de autenticación

- [ ] **Test 9**: Login con campos vacíos
  - **Resultado esperado**: Error de validación

- [ ] **Test 10**: Persistencia de sesión
  - Login exitoso → Cerrar app → Abrir app
  - **Resultado esperado**: Usuario sigue logueado

#### 1.3 Logout
- [ ] **Test 11**: Logout exitoso
  - Login → Presionar botón Logout
  - **Resultado esperado**: Redirección a Login screen

---

### 2. Navegación entre Pantallas

#### 2.1 Home Screen
- [ ] **Test 12**: Visualización del Home Screen
  - **Resultado esperado**: 4 tarjetas de cursos visibles

- [ ] **Test 13**: Navegación a TOEFL
  - Click en tarjeta TOEFL
  - **Resultado esperado**: Pantalla TOEFL cargada correctamente

- [ ] **Test 14**: Navegación a IELTS
  - Click en tarjeta IELTS
  - **Resultado esperado**: Pantalla IELTS cargada correctamente

- [ ] **Test 15**: Navegación a Business English
  - Click en tarjeta Business English
  - **Resultado esperado**: Pantalla Business English cargada correctamente

- [ ] **Test 16**: Navegación a English in Action
  - Click en tarjeta English in Action
  - **Resultado esperado**: Pantalla English in Action cargada correctamente

#### 2.2 Pantallas de Cursos
- [ ] **Test 17**: TOEFL Screen - Visualización
  - **Resultado esperado**: Header, progress bar, 4 skills (Reading, Listening, Speaking, Writing)

- [ ] **Test 18**: IELTS Screen - Visualización
  - **Resultado esperado**: Header, progress bar, 4 skills

- [ ] **Test 19**: Business English - Visualización
  - **Resultado esperado**: Header, progress bar, módulos (primero desbloqueado, resto bloqueados)

- [ ] **Test 20**: English in Action - Visualización
  - **Resultado esperado**: Header, progress bar, módulos (primero desbloqueado, resto bloqueados)

- [ ] **Test 21**: Botón Back en pantallas de curso
  - **Resultado esperado**: Regreso al Home Screen

---

### 3. UI/UX Testing

#### 3.1 Splash Screen
- [ ] **Test 22**: Animación Lottie
  - **Resultado esperado**: Animación fluida, transición automática

#### 3.2 Responsive Design
- [ ] **Test 23**: Scroll en pantallas largas
  - **Resultado esperado**: Scroll funcional sin overflow

- [ ] **Test 24**: Colores y temas
  - **Resultado esperado**: Colores consistentes con diseño

- [ ] **Test 25**: Íconos y tipografía
  - **Resultado esperado**: Todos los íconos visibles y textos legibles

---

### 4. Integración Firebase

#### 4.1 Firebase Authentication
- [ ] **Test 26**: Conexión con Firebase
  - **Resultado esperado**: Autenticación funcional sin errores de consola

- [ ] **Test 27**: Verificación de email (opcional)
  - **Resultado esperado**: Email de verificación enviado

#### 4.2 Firebase Storage (Preparación)
- [ ] **Test 28**: Configuración de Storage
  - **Resultado esperado**: Bucket creado y accesible

---

### 5. Performance Testing

- [ ] **Test 29**: Tiempo de carga del Splash
  - **Resultado esperado**: < 3 segundos

- [ ] **Test 30**: Tiempo de navegación entre pantallas
  - **Resultado esperado**: < 1 segundo

- [ ] **Test 31**: Tiempo de login/registro
  - **Resultado esperado**: < 2 segundos

---

## 📊 Resultados del Testing

### Resumen
- **Total de Tests**: 31
- **Tests Pasados**: ___ / 31
- **Tests Fallidos**: ___ / 31
- **Bugs Encontrados**: ___

### Bugs Reportados

#### Bug #1: [Título del Bug]
- **Severidad**: Alta/Media/Baja
- **Descripción**:
- **Pasos para reproducir**:
- **Resultado esperado**:
- **Resultado actual**:
- **Estado**: Abierto/En Progreso/Resuelto

---

## 🔧 Comandos de Testing

### Análisis de código
```bash
cd app
flutter analyze
```

### Ejecutar tests unitarios
```bash
cd app
flutter test
```

### Ejecutar app en modo debug
```bash
cd app
flutter run
```

### Ver logs en tiempo real
```bash
cd app
flutter logs
```

---

## 📝 Notas del Tester

### Observaciones Generales
-

### Recomendaciones
-

---

## ✅ Aprobación del Sprint 1 Días 11-14

- [ ] Todos los tests pasados
- [ ] Bugs críticos resueltos
- [ ] Documentación actualizada
- [ ] Código revisado y commiteado

**Tester**: Santiago Rodriguez
**Fecha de Aprobación**: __________
**Firma**: __________

---

## 🎯 Próximos Pasos (Sprint 2)

1. Implementar modelos de datos completos
2. Crear endpoints del backend
3. Integrar Flutter con API REST
4. Implementar sistema de progreso real
