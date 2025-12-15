# 3. Sistema de Cuestionarios y Evaluación

El sistema de evaluación es una de las funcionalidades centrales de EnglishPro. Permite a los estudiantes poner a prueba sus conocimientos a través de cuestionarios interactivos y recibir una calificación por sus respuestas.

## Estructura de Datos

Los cuestionarios están compuestos por varias tablas relacionadas en la base de datos:

1.  **`Cuestionarios`**: Define una evaluación, como un "Examen de Práctica de TOEFL". Contiene el título, descripción y tiempo límite.
2.  **`Preguntas`**: Contiene el texto de una pregunta individual, su tipo (`Multiple Choice`, `Texto Abierto`, `Audio Grabacion`), y los puntos que otorga.
3.  **`Opciones_Respuesta`**: Almacena las posibles respuestas para las preguntas de tipo `Multiple Choice`, indicando cuál es la correcta.
4.  **`Cuestionario_Preguntas`**: Una tabla de unión (N:M) que asocia múltiples preguntas a un cuestionario.
5.  **`Respuestas_Usuario`**: Guarda la respuesta que un estudiante ha enviado para una pregunta específica, incluyendo la opción seleccionada, texto de ensayo o URL de audio.

```
Cuestionarios
  └─ "Práctica TOEFL"
      ├─ Cuestionario_Preguntas
      │   ├─ Pregunta 1 (FK)
      │   └─ Pregunta 2 (FK)
      └─ Preguntas
          ├─ "¿Cuál es la capital de...? (Multiple Choice)"
          │   └─ Opciones_Respuesta
          │       ├─ "Opción A"
          │       ├─ "Opción B (Correcta)"
          │       └─ "Opción C"
          └─ "Escriba un ensayo sobre... (Texto Abierto)"
```

## Diagrama de Flujo: Responder un Cuestionario

```
┌──────────────┐      ┌──────────────────────────┐      ┌──────────────────────────┐
│ QuizScreen   │----▶│     Supabase Client      │----▶│      DB (Supabase)       │
└──────────────┘      └──────────────────────────┘      └──────────────────────────┘
      │                        │                             │
      │ 1. Carga las preguntas │                             │
      │    del cuestionario    │                             │
      │                        │ 2. .from('Preguntas')...    │
      │                        │                             │ 3. Retorna preguntas y
      │                        │                             │    opciones
      │ 4. Muestra la pregunta │                             │
      │    actual              │                             │
      │                        │                             │
      │ 5. Usuario selecciona  │                             │
      │    respuesta y presiona│                             │
      │    "Enviar"            │                             │
      │                        │                             │
      │ 6. Llama a _submitAnswer()│                             │
      │                        │                             │
      │                        │ 7. .from('Respuestas_Usuario')│
      │                        │    .insert({...})            │
      │                        │                             │ 8. Inserta la respuesta
      │                        │                             │    en la tabla
      │                        │                             │
      │ 9. Navega a la         │                             │
      │    siguiente pregunta  │                             │
      │    o a los resultados  │                             │
      │                        │                             │
```

## Componentes Clave

### 1. `QuizScreen` (`quiz_screen.dart`)

-   **Responsabilidad**: Orquestar la experiencia del cuestionario. Es la pantalla principal donde el usuario interactúa con las preguntas.
-   **Lógica**:
    1.  **Carga de Preguntas**: Al iniciar, carga todas las preguntas y sus opciones para un cuestionario o habilidad específica.
    2.  **Gestión de Estado**: Mantiene un registro de la pregunta actual (`currentIndex`).
    3.  **Envío de Respuestas**: Contiene la lógica para guardar la respuesta del usuario en la base de datos a través de una llamada a Supabase.
    4.  **Navegación**: Avanza a la siguiente pregunta o, al finalizar, navega a `QuizResultsScreen`.

```dart
// En QuizScreen

Future<void> _submitAnswer() async {
  // ... lógica para obtener la respuesta seleccionada

  // 1. Crear el mapa de datos para la inserción
  final responseData = {
    'id_usuario': currentUser.id,
    'id_pregunta': currentQuestion.id,
    'id_opcion_seleccionada': selectedOption?.id,
    'texto_ensayo': textResponse, // para preguntas abiertas
    'url_grabacion': audioUrl, // para preguntas de audio
    'es_correcta': isCorrect,
    'puntos_obtenidos': isCorrect ? currentQuestion.puntos : 0,
    'requiere_revision': currentQuestion.tipo_pregunta != 'Multiple Choice',
  };

  // 2. Insertar en la tabla `Respuestas_Usuario`
  await SupabaseConfig.client
      .from('Respuestas_Usuario')
      .insert(responseData);

  // ... avanzar a la siguiente pregunta
}
```

### 2. `QuestionModel` (`question_model.dart`)

-   **Responsabilidad**: Modela una pregunta y su lista anidada de `Option` (opciones de respuesta). Facilita el manejo de los datos en el código Dart.

### 3. Tipos de Preguntas

El sistema soporta tres tipos principales de preguntas, cada una con un manejo de UI y lógica de envío diferente:

-   **`Multiple Choice`**: El usuario selecciona una de varias opciones. La UI muestra `RadioButton`s y la respuesta se guarda con el `id_opcion_seleccionada`. La corrección es automática.
-   **`Texto Abierto`**: El usuario escribe una respuesta en un `TextField`. La respuesta se guarda en el campo `texto_ensayo`. Estas respuestas **requieren revisión manual** por parte de un docente.
-   **`Audio Grabacion`**: El usuario graba su voz usando el `AudioRecorderWidget`. La URL del archivo de audio subido a Supabase Storage se guarda en `url_grabacion`. Estas respuestas también **requieren revisión manual**.

### 4. `QuizResultsScreen` (`quiz_results_screen.dart`)

-   **Responsabilidad**: Mostrar un resumen de los resultados al finalizar un cuestionario.
-   **Información Mostrada**:
    -   Número de respuestas correctas e incorrectas.
    -   Puntaje total obtenido.
    -   Un botón para volver a intentar el cuestionario o regresar al home.

## Revisión Manual

-   Las preguntas que no son `Multiple Choice` activan el flag `requiere_revision` en la tabla `Respuestas_Usuario`.
-   Estas respuestas aparecen en el **Panel del Docente** para que sean calificadas manualmente.

---

**Siguiente**: [4. Seguimiento de Progreso](./04_progress_tracking.md)
