# =========================================
# PROYECTO: English Pro
# REQUISITOS DEL SISTEMA
# =========================================

## 1. Requisitos Funcionales

### RF-01: Registro de Usuarios
El sistema debe permitir el registro de usuarios solicitando nombre, correo único, número de teléfono y contraseña, validando duplicados y enviando correo de confirmación.

### RF-02: Inicio de Sesión
El sistema debe permitir el inicio de sesión de usuarios existentes con correo y contraseña, validando credenciales.

### RF-03: Control de Acceso por Plan
El sistema debe controlar el acceso al contenido según el plan del usuario (freemium, básico, pro, premium).

### RF-04: Pantalla Principal con Pestañas
El sistema debe mostrar en la pantalla principal las cuatro pestañas: TOEFL, IELTS, Business English y English in Action.

### RF-05: Habilidades por Curso
El sistema debe mostrar las habilidades específicas de cada curso (ej. Writing, Speaking en TOEFL/IELTS).

### RF-06: Materiales por Habilidad
El sistema debe mostrar materiales asociados a cada habilidad: teoría, ejercicios, audios, videos y tips.

### RF-07: Ejecución de Cuestionarios
El sistema debe permitir la ejecución de cuestionarios por habilidad, con preguntas de opción múltiple, redacción (Writing) y grabación de voz (Speaking).

### RF-08: Retroalimentación de Cuestionarios
El sistema debe generar retroalimentación inmediata al finalizar un cuestionario, mostrando puntaje, aciertos, errores y explicaciones.

### RF-09: Registro de Progreso
El sistema debe registrar y mostrar el progreso del usuario según el curso: % en TOEFL/IELTS, secuencial en Business/Action.

### RF-10: Panel de Docentes
El sistema debe habilitar un panel para docentes donde puedan subir y organizar bancos de preguntas, materiales y sesiones en vivo.

## 2. Requisitos No Funcionales

### RNF-01: Compatibilidad Móvil
La plataforma debe ser accesible desde dispositivos móviles con Android e iOS, asegurando una experiencia fluida y consistente en ambos sistemas operativos.

### RNF-02: Disponibilidad y Rendimiento
- La app debe tener alta disponibilidad (90.9% uptime) y estar operativa en todo momento.
- El tiempo de carga de las pantallas debe ser rápido (máximo 2 segundos) para asegurar una experiencia de usuario óptima.

### RNF-03: Escalabilidad
- La plataforma debe ser escalable, permitiendo aumentar el número de usuarios, bancos de preguntas y simulacros sin comprometer el rendimiento.
- Debe poder soportar un crecimiento en la cantidad de usuarios activos simultáneamente.

### RNF-04: Seguridad
La plataforma debe contar con medidas de seguridad adecuadas para proteger la información personal y académica de los usuarios, incluyendo el cifrado de datos sensibles y un sistema de autenticación seguro.

### RNF-05: Diseño Profesional
- La app debe tener un diseño profesional y atractivo, con una interfaz intuitiva que permita a los usuarios navegar fácilmente por las diferentes funcionalidades.
- El diseño debe ser moderno, con un enfoque en la experiencia de usuario (UX) para facilitar el uso sin complicaciones.

### RNF-06: Experiencia de Usuario
El sistema debe proporcionar una experiencia de usuario amigable, con una navegación clara, iconos bien definidos y un flujo de interacción lógico, lo que permita a los usuarios realizar todas las acciones necesarias sin dificultad.

### RNF-07: Mantenibilidad
- La plataforma debe ser fácil de actualizar y mantener.
- Debe permitir la incorporación de nuevas funcionalidades, materiales de estudio y mejoras sin interrumpir el servicio ni afectar la experiencia del usuario.
