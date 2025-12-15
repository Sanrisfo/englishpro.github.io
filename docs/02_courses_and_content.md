# 2. Cursos y Contenido

Una vez que el usuario ha iniciado sesión, la funcionalidad principal de EnglishPro es el acceso a los cursos y sus materiales de estudio. Esta sección describe cómo se estructura y se presenta el contenido educativo.

## Estructura de Datos

El contenido está organizado jerárquicamente en la base de datos de Supabase:

1.  **`Cursos`**: La categoría más alta. Hay cuatro cursos principales (TOEFL, IELTS, Business English, English in Action).
2.  **`Habilidades`**: Cada curso se divide en cuatro habilidades (Writing, Speaking, Listening, Reading).
3.  **`Materiales_Estudio`**: Cada habilidad contiene una lista de materiales de estudio, que pueden ser de tipo PDF, Video, Audio o Texto.

```
Cursos (Tabla)
  ├─ TOEFL (Fila)
  │   ├─ Habilidades (Tabla)
  │   │   ├─ Writing (Fila)
  │   │   │   ├─ Materiales_Estudio (Tabla)
  │   │   │   │   ├─ "Introducción al Writing Académico.pdf" (Fila)
  │   │   │   │   └─ "Análisis de Ensayo.mp4" (Fila)
  │   │   └─ Speaking (Fila)
  │   │       └─ ...
  │   └─ ...
  └─ IELTS (Fila)
      └─ ...
```

## Diagrama de Flujo: Listar Cursos

Este es el flujo para mostrar la lista de cursos disponibles en la pantalla de inicio.

```
┌─────────────┐      ┌──────────────────────────┐      ┌─────────────────┐
│ HomeScreen  │----▶│     Supabase Client      │----▶│  Tabla `Cursos` │
└─────────────┘      └──────────────────────────┘      └─────────────────┘
      │                        │                             │
      │ 1. initState() llama a │                             │
      │    _loadCourses()      │                             │
      │                        │ 2. Ejecuta la consulta:     │
      │                        │    .from('Cursos').select() │
      │                        │                             │ 3. Retorna la lista
      │                        │                             │    de cursos
      │                        │ 4. Recibe los datos         │
      │                        │    (List<Map>)               │
      │                        │                             │
      │ 5. Convierte los datos │                             │
      │    a List<Course>      │                             │
      │    y actualiza el      │                             │
      │    estado (setState)   │                             │
      │                        │                             │
      │ 6. La UI se reconstruye│                             │
      │    con la lista de     │                             │
      │    cursos              │                             │
      │                        │                             │
```

## Componentes Clave

### 1. `HomeScreen` (`home_screen.dart`)

-   **Responsabilidad**: Es la primera pantalla que ve el usuario después de iniciar sesión. Muestra la lista de los cuatro cursos principales.
-   **Lógica**: En su `initState`, llama a un método para cargar los cursos directamente desde Supabase. Utiliza un `ListView.builder` para renderizar la lista de cursos obtenidos.

```dart
// En HomeScreen

Future<void> _loadCourses() async {
  final supabase = SupabaseConfig.client;

  // 1. Consulta directa a la tabla `Cursos`
  final data = await supabase
      .from('Cursos')
      .select()
      .eq('Activo', true);

  // 2. Mapeo a modelos y actualización del estado
  setState(() {
    _courses = (data as List).map((e) => Course.fromMap(e)).toList();
    _isLoading = false;
  });
}
```

### 2. `CourseModel` (`course_model.dart`)

-   **Responsabilidad**: Representar una fila de la tabla `Cursos` como un objeto Dart. Incluye un factory constructor `fromMap` para facilitar la conversión desde el JSON que retorna Supabase.

### 3. Pantallas de Habilidades y Materiales

-   Al seleccionar un curso, el usuario navega a una pantalla específica para ese curso (ej. `toefl_screen.dart`).
-   Estas pantallas a su vez cargan y muestran las **habilidades** (Skills) asociadas a ese curso.
-   Al seleccionar una habilidad, se navega a otra pantalla que finalmente lista los **materiales de estudio** (`Materiales_Estudio`).

## Acceso a Materiales Multimedia

Los materiales de estudio como PDFs, videos y audios se manejan con widgets especializados que se encargan de renderizar el contenido.

-   **`SupabaseStorageService`**: Este servicio se utiliza para obtener las URLs públicas de los archivos almacenados en Supabase Storage.
-   **Widgets Reutilizables**:
    -   `PdfViewerWidget`: Utiliza el paquete `flutter_pdfview` para mostrar documentos PDF directamente desde una URL.
    -   `VideoPlayerWidget`: Usa `video_player` y `chewie` para proporcionar un reproductor de video con controles.
    -   `AudioRecorderWidget`: Permite grabar y reproducir audio, interactuando con `record` y `audioplayers`.

El `URL_Recurso` de la tabla `Materiales_Estudio` contiene la dirección del archivo en Supabase Storage, que es utilizada por estos widgets para cargar el contenido.

## Control de Acceso por Plan

La base de datos está diseñada para soportar un control de acceso granular basado en el plan de suscripción del usuario.

-   La tabla `Materiales_Estudio` tiene una columna `Nivel_Acceso` (`Freemium`, `Basico`, `Pro`, `Premium`).
-   Las consultas para obtener materiales deben filtrar los resultados basándose en el plan del usuario actual para asegurar que solo vean el contenido al que tienen derecho.

```sql
-- Ejemplo de consulta para obtener materiales según el plan del usuario
SELECT m.* FROM Materiales_Estudio m
WHERE m.ID_Habilidad = 3
AND (
    m.Nivel_Acceso = 'Freemium'
    OR m.Nivel_Acceso IN (
        -- Subconsulta para obtener el plan del usuario actual
        SELECT p.Nombre_Plan FROM Usuarios u
        JOIN Planes p ON u.ID_Plan = p.ID_Plan
        WHERE u.ID_Usuario = :current_user_id
    )
);
```

---

**Siguiente**: [3. Sistema de Cuestionarios](./03_quiz_and_assessment.md)
