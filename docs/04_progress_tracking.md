# 4. Seguimiento de Progreso

EnglishPro ofrece a los estudiantes una forma visual y motivadora de seguir su progreso a lo largo de los cursos. Esta funcionalidad es clave para mantener al estudiante comprometido y consciente de su avance.

## Estructura de Datos

El seguimiento del progreso se centraliza en la tabla `Progreso_Usuarios` de la base de datos.

-   **`Progreso_Usuarios`**: Esta tabla almacena un registro único por cada usuario y curso en el que está inscrito.
    -   `id_usuario` (FK): Identifica al estudiante.
    -   `curso_id` (FK): Identifica el curso.
    -   `avance_porcentaje`: El porcentaje general de avance en el curso.
    -   `preguntas_respondidas`: Contador total de preguntas intentadas.
    -   `preguntas_correctas`: Contador de respuestas correctas.
    -   `puntos_totales`: Suma de todos los puntos obtenidos.
    -   `ultima_actividad`: Timestamp de la última interacción para seguimiento de actividad.

Una fila en esta tabla se crea cuando un estudiante inicia un curso por primera vez, y se actualiza cada vez que completa una actividad relevante (como responder una pregunta).

## Diagrama de Flujo: Actualizar Progreso

Este flujo se activa después de que un usuario responde una pregunta en el `QuizScreen`.

```
┌────────────────────┐      ┌──────────────────────────┐      ┌───────────────────────────┐
│ Después de enviar  │----▶│     Trigger o Lógica     │----▶│ Tabla `Progreso_Usuarios` │
│ una respuesta      │      │      de Actualización    │      └───────────────────────────┘
└────────────────────┘      └──────────────────────────┘                ▲
      │                              │                                  │
      │                              │ 1. Se ejecuta un `UPDATE`        │
      │                              │    en la fila correspondiente    │
      │                              │    (usuario, curso)              │
      │                              │                                  │
      │                              │ 2. Incrementa contadores:        │
      │                              │    - preguntas_respondidas++     │
      │                              │    - preguntas_correctas++ (si aplica)│
      │                              │    - puntos_totales += puntos    │
      │                              │                                  │
      │                              │ 3. Recalcula `avance_porcentaje` │
      │                              │                                  │
```
**Nota**: La actualización puede ser manejada por un **trigger** en la base de datos (`AFTER INSERT` en `Respuestas_Usuario`) o directamente en la lógica de la aplicación después de que una respuesta es enviada. La documentación de arquitectura (`01_ARQUITECTURA.md`) sugiere que esto podría ser un trigger.

## Componentes Clave

### 1. `ProgressDashboardScreen` (`progress_dashboard_screen.dart`)

-   **Responsabilidad**: Mostrar al estudiante un resumen visual de su progreso en todos los cursos.
-   **Visualización de Datos**:
    -   Utiliza el paquete `fl_chart` para renderizar gráficos (ej. gráficos de barras o circulares) que muestran el `avance_porcentaje` por cada curso.
    -   Presenta estadísticas clave como el total de puntos, preguntas correctas, y el tiempo de estudio acumulado.
-   **Lógica de Carga**:
    -   Al iniciar, realiza una consulta a la tabla `Progreso_Usuarios` para obtener todos los registros de progreso asociados al `id_usuario` actual.
    -   Une la consulta con la tabla `Cursos` para obtener los nombres de los cursos.

```dart
// En ProgressDashboardScreen

Future<void> _loadProgressData() async {
  final userId = SupabaseConfig.client.auth.currentUser!.id;

  // 1. Consulta para obtener el progreso del usuario
  final data = await SupabaseConfig.client
      .from('Progreso_Usuarios')
      .select('*, Cursos(Nombre_Curso)') // Join con la tabla Cursos
      .eq('ID_Usuario', userId);

  // 2. Mapeo a modelos y actualización del estado
  setState(() {
    _progressList = (data as List).map((e) => Progress.fromMap(e)).toList();
    _isLoading = false;
  });
}
```

### 2. `ProgressModel` (`progress_model.dart`)

-   **Responsabilidad**: Modela un registro de la tabla `Progreso_Usuarios`, facilitando el manejo de los datos en la UI.
-   Contiene un factory `fromMap` para parsear la respuesta de Supabase, incluyendo los datos anidados del curso.

## Visualización del Progreso

La librería `fl_chart` es fundamental para esta sección, ya que permite crear visualizaciones de datos ricas e interactivas que mejoran la experiencia del usuario.

-   **Gráfico de Barras**: Podría usarse para comparar el progreso entre los diferentes cursos.
-   **Gráfico Circular (Pie Chart)**: Ideal para mostrar la proporción de respuestas correctas vs. incorrectas.
-   **Gráfico de Líneas**: Útil para mostrar la acumulación de puntos o el progreso a lo largo del tiempo.

El `ProgressDashboardScreen` utiliza los datos del `_progressList` para construir y configurar estos gráficos, proporcionando una vista clara y atractiva del rendimiento del estudiante.

---
**Siguiente**: [5. Panel del Docente](./05_teacher_panel.md)
