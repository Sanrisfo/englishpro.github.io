Flujo de Usuario Completo: Panel Docente

Este documento detalla el flujo de usuario completo para el panel de administración docente, desde el inicio de sesión hasta la gestión de contenidos, revisiones y estudiantes.

1. Autenticación y Acceso

1.1. Inicio de Sesión

El usuario accede a la pantalla de "Login".

1.2. Validación de Rol

El usuario ingresa sus credenciales. El sistema valida la autenticación y verifica el rol del usuario.

1.3. Ingreso al Panel

Si el atributo es_docente es true, el sistema concede acceso al Panel Docente.

2. Panel Principal (Dashboard)

2.1. Vista Principal

Al ingresar, el docente es dirigido al panel principal. La interfaz muestra el nombre del docente en la cabecera.

2.2. Navegación Principal

El panel presenta tres módulos funcionales clave. El docente seleccionará uno para iniciar un flujo de trabajo:

Módulos: (Ver sección 3)

Revisiones: (Ver sección 4)

Control de Usuario: (Ver sección 5)

3. Flujo: Módulo "Módulos" (Gestión de Contenido)

Este flujo se activa al seleccionar "Módulos" desde el Panel Principal.

3.1. Navegación Nivel 1 (Selección de Curso)

El docente accede a una pantalla titulada "MÓDULOS".

Esta pantalla presenta los dos cursos principales gestionables: TOEFL e IELTS.

3.2. Navegación Nivel 2 (Selección de Habilidad)

Al seleccionar un curso (ej. TOEFL), se accede a la pantalla de ese curso (titulada "TOEFL").

Esta pantalla muestra las cuatro habilidades (Reading, Listening, Writing, Speaking).

(El flujo para IELTS es idéntico al de TOEFL).

3.3. Navegación Nivel 3 (Gestión de Actividades)

Al seleccionar una habilidad (ej. Reading), el docente accede a la lista de "Actividades" existentes para esa habilidad.

3.4. Funcionalidad en "Gestión de Actividades" (CRUD)

3.4.1. Visualización y Eliminación (Read/Delete)

El docente ve una lista de todas las actividades creadas.

Cada actividad en la lista tiene un icono de eliminación (ej. "tacho de basura").

Al hacer clic en dicho icono, se despliega un pop-up de confirmación (ej. "¿Está seguro de que desea eliminar la actividad '[NombreActividad]'?") con las opciones "Sí" y "No".

3.4.2. Creación (Create)

En la parte inferior de la pantalla, se ubica un botón de "Creación" (ej. "Crear Nueva Actividad").

Al hacer clic, el docente es redirigido a la pantalla "Formulario de Creación".

3.5. Pantalla "Formulario de Creación de Actividad"

3.5.1. Campos Principales

El formulario solicita:

Título de la actividad.

Temporizador (tiempo límite para la actividad).

Descripción de la tarea.

3.5.2. Carga de Recursos (Contextual)

El formulario permite subir los archivos de recursos necesarios, adaptándose a la habilidad seleccionada:

Reading: Carga de texto plano o imágenes.

Listening: Carga de audio o video.

Writing/Speaking: Carga de audio, video, texto o imágenes (como prompts).

3.5.3. Creación de Preguntas

El formulario incluye una sección para crear preguntas de opción múltiple (Multiple Choice).

Permite definir 4 opciones de respuesta.

Requiere que el docente marque una de las opciones como la "Respuesta Correcta" y las restantes como erróneas.

3.5.4. Confirmación

Al presionar el botón "Crear", el sistema valida el formulario.

Si es exitoso, muestra un pop-up de confirmación (ej. "Actividad creada exitosamente").

El sistema redirige al docente de vuelta a la pantalla "Gestión de Actividades" (Nivel 3.3), donde la nueva actividad aparece ahora en la lista.

4. Flujo: Módulo "Revisiones"

Este flujo se activa al seleccionar "Revisiones" desde el Panel Principal.

4.1. Acceso al Módulo y Selección de Curso (Nivel 1)

Al ingresar al módulo, la interfaz principal se titula "Pendientes".

La pantalla presenta opciones de navegación (botones) para filtrar las revisiones pendientes por curso:

TOEFL

IELTS

4.2. Bandeja de Revisiones Pendientes (Nivel 2)

Acción: El docente selecciona uno de los cursos (ej. TOEFL).

Resultado: El sistema redirige a la "Bandeja de Revisiones" de dicho curso.

Interfaz:

Esta pantalla muestra una lista de todas las entregas de los alumnos pendientes de calificación, presentadas como tarjetas (cards).

Cada tarjeta debe incluir:

Avatar del alumno.

Nombre del alumno (ej. "Olivia Rodriguez").

Nombre de la tarea (ej. "Oral Presentation: Q3 Report").

Habilidad (ej. "Speaking", "Writing").

Fecha de entrega (ej. "Oct 26").

4.3. Interfaz de Corrección Individual (Nivel 3)

Acción: El docente selecciona una entrega/alumno específico de la lista (ej. "Olivia Rodriguez").

Resultado: El sistema navega a la "Interfaz de Corrección" individual para esa entrega.

Diseño de la Interfaz:

Cabecera: Muestra el nombre del alumno (ej. "olivia rodriguez").

Visor de Contenido: Una sección principal renderiza la entrega del alumno. El contenido es contextual:

Para Writing: Se muestra el texto enviado por el alumno.

Para Speaking: Se muestra un reproductor de audio para escuchar la grabación del alumno.

4.4. Formulario y Envío de Retroalimentación

Formulario: Debajo del visor de contenido, se presenta:

Un campo de entrada para la Calificación (ej. "PUNTUACION -- / 20").

Un área de texto para Comentarios (ej. "CAJA DE COMENTARIOS").

Acción de Envío: En la parte inferior de la pantalla, se ubica un botón de "ENVIAR".

Proceso de Envío: Al hacer clic en "ENVIAR":

El sistema guarda la calificación y los comentarios.

Se muestra un pop-up de confirmación (ej. "¡Revisión enviada al alumno [Nombre del Alumno]!").

El sistema marca la tarea como "revisada".

Redirección: Tras cerrar el pop-up, el sistema redirige al docente de vuelta a la "Bandeja de Revisiones" (Nivel 2), donde la entrega calificada ya no figura como pendiente.

5. Flujo: Módulo "Control de Usuario" (Student Roster)

Este flujo se activa al seleccionar "Control de Usuario" desde el Panel Principal.

5.1. Acceso y Visualización del "Student Roster" (Nivel 1)

Acción: Al ingresar a la sección "Control de Usuario".

Resultado: El docente accede a la pantalla principal titulada "Student Roster".

Interfaz:

La pantalla muestra una lista completa de los estudiantes registrados, presentados en formato de tarjetas (cards).

Herramientas de Gestión: La interfaz proporciona:

Un campo de Búsqueda por nombre ("Search students by name...").

Opciones de Ordenamiento (ej. "Sort by: Date").

Opciones de Filtrado por plan (ej. "Plan: All", "Plan: Pro").

Información por Estudiante: Cada tarjeta de estudiante muestra:

Nombre (ej. "Eleanor Vance").

Fecha de registro (ej. "Joined: 24 Aug 2023").

Plan actual con una etiqueta (ej. "PRO", "PREMIUM", "FREE").

5.2. Gestión Individual del Estudiante (Nivel 2)

Acción: El docente selecciona un estudiante específico de la lista.

Resultado: El sistema redirige al docente a la pantalla de perfil y gestión de dicho estudiante.

Interfaz:

Cabecera: Muestra el nombre completo del estudiante (ej. "ELEANOR VANCE").

Sección de Datos: Un contenedor principal muestra información relevante del estudiante.

Módulo de Gestión de Plan: En la parte inferior, se presenta una sección titulada "CAMBIAR PLAN". Esta área proporciona al docente la funcionalidad (ej. un selector) para modificar y asignar un nuevo plan al estudiante.