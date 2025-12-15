# 5. Panel del Docente

EnglishPro incluye un panel de control especializado para usuarios con el rol de "Docente". Este panel es fundamental para el modelo de aprendizaje de la aplicación, ya que centraliza las tareas de revisión, calificación y retroalimentación de las respuestas de los estudiantes.

## Funcionalidades Principales

El panel del docente está diseñado para facilitar las siguientes tareas:

1.  **Revisión de Respuestas Pendientes**: Ver una lista de todas las respuestas de los estudiantes que requieren calificación manual (preguntas de texto abierto y de grabación de audio).
2.  **Calificación Manual**: Asignar una calificación y proporcionar comentarios detallados (feedback) a una respuesta específica.
3.  **Gestión de Contenido**: Subir y administrar materiales de estudio.
4.  **Visualización de Estadísticas**: Monitorear el rendimiento general de los estudiantes.

## Diagrama de Flujo: Calificación Manual

Este es el flujo de trabajo típico para un docente que califica una respuesta.

```
┌──────────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────────┐
│ TeacherDashboardScreen   │----▶│  PendingReviewsScreen   │----▶│   ManualGradingScreen      │
└──────────────────────────┘      └─────────────────────────┘      └────────────────────────────┘
      │                             │                                  │
      │ 1. Docente ve el número     │                                  │
      │    de revisiones pendientes │                                  │
      │                             │ 2. Docente navega para ver │
      │                             │    la lista detallada de     │
      │                             │    respuestas pendientes     │
      │                             │                                  │ 3. Selecciona una respuesta
      │                             │                                  │    para calificar. La pantalla
      │                             │                                  │    muestra la pregunta y la
      │                             │                                  │    respuesta del estudiante.
      │                             │                                  │
      │                             │                                  │ 4. Docente ingresa un comentario
      │                             │                                  │    y una calificación.
      │                             │                                  │
      │                             │                                  │ 5. Llama a un servicio para
      │                             │                                  │    guardar el feedback.
      │                             │                                  │
      │                             │          ┌───────────────────┐   │
      │                             │          │ DB (Supabase)     │◀--┘
      │                             │          └───────────────────┘
      │                             │                 │
      │                             │                 │ 6. Se inserta una nueva fila en
      │                             │                 │    `Retroalimentacion_Docente`.
      │                             │                 │
      │                             │                 │ 7. Se actualiza la fila en
      │                             │                 │    `Respuestas_Usuario` para marcarla
      │                             │                 │    como revisada.
      │                             │                 │
```

## Componentes Clave

### 1. `TeacherDashboardScreen` (`teacher_dashboard_screen.dart`)

-   **Responsabilidad**: Actuar como el punto de entrada principal para los docentes.
-   **Información Mostrada**:
    -   Estadísticas clave: número de respuestas pendientes, total de respuestas calificadas, calificación promedio.
    -   Accesos directos a las secciones principales: "Revisión Manual", "Mis Cursos", "Lista de Estudiantes".
-   **Lógica**:
    -   Utiliza un `SupabaseTeacherService` para obtener las estadísticas y los datos del docente.
    -   Muestra los datos en widgets de resumen y proporciona navegación a las pantallas de detalle.

### 2. `PendingReviewsScreen` (`pending_reviews_screen.dart`)

-   **Responsabilidad**: Mostrar una lista de todas las respuestas que tienen el flag `requiere_revision` activado y que aún no han sido calificadas.
-   **Lógica**:
    -   Realiza una consulta a la tabla `Respuestas_Usuario` para obtener las respuestas pendientes.
    -   Muestra información clave de cada respuesta (nombre del estudiante, pregunta, fecha de envío).
    -   Al seleccionar una respuesta, navega al `ManualGradingScreen`.

```sql
-- Consulta para obtener revisiones pendientes
SELECT
  r.id_respuesta,
  r.texto_ensayo,
  r.url_grabacion,
  u.nombre_completo as nombre_estudiante,
  p.texto_pregunta
FROM Respuestas_Usuario r
JOIN Usuarios u ON r.id_usuario = u.id_usuario
JOIN Preguntas p ON r.id_pregunta = p.id_pregunta
WHERE r.requiere_revision = TRUE AND NOT EXISTS (
  SELECT 1 FROM Retroalimentacion_Docente f WHERE f.id_respuesta = r.id_respuesta
);
```

### 3. `ManualGradingScreen` (`manual_grading_screen.dart`)

-   **Responsabilidad**: Proporcionar la interfaz para que un docente califique una respuesta específica.
-   **UI**:
    -   Muestra la pregunta original.
    -   Muestra la respuesta del estudiante (ya sea un texto de ensayo o un reproductor de audio para la grabación).
    -   Incluye un `TextField` para que el docente escriba sus comentarios (`feedback`).
    -   Incluye un campo para ingresar una calificación numérica.
-   **Lógica de Envío**:
    -   Al presionar "Enviar Retroalimentación", se crea un nuevo registro en la tabla `Retroalimentacion_Docente`.
    -   Este registro asocia la respuesta del estudiante, el docente, el comentario y la calificación.
    -   Opcionalmente, se puede actualizar la respuesta original en `Respuestas_Usuario` para marcarla como calificada y asignarle los puntos correspondientes.

### 4. `SupabaseTeacherService`

-   **Responsabilidad**: Centralizar todas las consultas a la base de datos relacionadas con el rol de docente.
-   **Métodos**:
    -   `getTeacherStats()`: Obtiene estadísticas agregadas (total de revisiones, promedio, etc.).
    -   `getPendingFeedbacks()`: Ejecuta la consulta para obtener la lista de respuestas pendientes.
    -   `submitFeedback()`: Inserta la retroalimentación en la base de datos.

### 5. Notificaciones al Estudiante

-   Una vez que un docente envía su retroalimentación, idealmente se debería crear una notificación para el estudiante.
-   Esto se puede lograr con un **trigger** en la base de datos (`AFTER INSERT` en `Retroalimentacion_Docente`) que cree una nueva fila en la tabla `Notificaciones` para el estudiante correspondiente.
-   El estudiante recibirá esta notificación en su `NotificationsScreen`.

---

Esta documentación proporciona una visión general de las funcionalidades más importantes de EnglishPro. Para obtener más detalles, consulte el código fuente y la documentación de contexto.
