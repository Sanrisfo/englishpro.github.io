# 📚 EnglishPro API Documentation

## Base URL
```
http://localhost:8080
```

## Health Check

### GET `/health`
Verifica el estado del servidor.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-10-07T23:17:54.003646"
}
```

---

## Courses (Cursos)

### GET `/api/courses`
Obtiene todos los cursos disponibles.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "TOEFL",
      "descripcion": "Preparación para el Test of English as a Foreign Language",
      "tipo_curso": "Examen",
      "estilo_progreso": "Porcentaje",
      "url_imagen": null,
      "fecha_creacion": "2025-10-07T03:02:54.886631Z",
      "activo": true
    }
  ],
  "count": 4
}
```

### GET `/api/courses/:id`
Obtiene un curso específico por ID.

**Parameters:**
- `id` (integer): ID del curso

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nombre": "TOEFL",
    "descripcion": "Preparación para el Test of English as a Foreign Language",
    "tipo_curso": "Examen",
    "estilo_progreso": "Porcentaje",
    "url_imagen": null,
    "fecha_creacion": "2025-10-07T03:02:54.886631Z",
    "activo": true
  }
}
```

### POST `/api/courses`
Crea un nuevo curso.

**Request Body:**
```json
{
  "nombre": "Advanced English",
  "descripcion": "Curso avanzado de inglés",
  "tipo_curso": "Inmersivo",
  "estilo_progreso": "Modular"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Course created successfully",
  "data": {
    "id": 5,
    "nombre": "Advanced English",
    ...
  }
}
```

### PUT `/api/courses/:id`
Actualiza un curso existente.

**Parameters:**
- `id` (integer): ID del curso

**Request Body:**
```json
{
  "nombre": "TOEFL Updated",
  "descripcion": "Nueva descripción"
}
```

### DELETE `/api/courses/:id`
Elimina un curso (soft delete - marca como inactivo).

**Parameters:**
- `id` (integer): ID del curso

---

## Skills (Habilidades)

### GET `/api/skills`
Obtiene todas las habilidades.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "curso_id": 1,
      "nombre": "Writing",
      "descripcion": "Escritura académica para TOEFL",
      "icon_url": null,
      "orden": 1
    }
  ],
  "count": 16
}
```

### GET `/api/skills/:id`
Obtiene una habilidad específica por ID.

**Parameters:**
- `id` (integer): ID de la habilidad

### GET `/api/skills/course/:courseId`
Obtiene todas las habilidades de un curso específico.

**Parameters:**
- `courseId` (integer): ID del curso

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "curso_id": 1,
      "nombre": "Writing",
      "descripcion": "Escritura académica para TOEFL",
      "icon_url": null,
      "orden": 1
    },
    {
      "id": 2,
      "curso_id": 1,
      "nombre": "Speaking",
      "descripcion": "Expresión oral para TOEFL",
      "icon_url": null,
      "orden": 2
    }
  ],
  "count": 4
}
```

### POST `/api/skills`
Crea una nueva habilidad.

**Request Body:**
```json
{
  "curso_id": 1,
  "nombre": "Grammar",
  "descripcion": "Gramática avanzada",
  "orden": 5
}
```

### PUT `/api/skills/:id`
Actualiza una habilidad existente.

**Parameters:**
- `id` (integer): ID de la habilidad

### DELETE `/api/skills/:id`
Elimina una habilidad.

**Parameters:**
- `id` (integer): ID de la habilidad

---

## Materials (Materiales)

### GET `/api/materials`
Obtiene todos los materiales.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "habilidad_id": 1,
      "titulo": "Introduction to TOEFL Reading",
      "tipo_material": "Texto",
      "url_recurso": null,
      "contenido_texto": "El TOEFL Reading consiste en...",
      "duracion_minutos": null,
      "orden": 1,
      "nivel_acceso": "Freemium",
      "fecha_creacion": "2025-10-07T22:13:51.596611Z",
      "creado_por": null
    }
  ],
  "count": 5
}
```

### GET `/api/materials/:id`
Obtiene un material específico por ID.

**Parameters:**
- `id` (integer): ID del material

### GET `/api/materials/skill/:skillId`
Obtiene todos los materiales de una habilidad específica.

**Parameters:**
- `skillId` (integer): ID de la habilidad

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "habilidad_id": 1,
      "titulo": "Introduction to TOEFL Reading",
      "tipo_material": "Texto",
      "url_recurso": null,
      "contenido_texto": "El TOEFL Reading consiste en...",
      "duracion_minutos": null,
      "orden": 1,
      "nivel_acceso": "Freemium",
      "fecha_creacion": "2025-10-07T22:13:51.596611Z",
      "creado_por": null
    }
  ],
  "count": 3
}
```

### POST `/api/materials`
Crea un nuevo material.

**Request Body:**
```json
{
  "habilidad_id": 1,
  "titulo": "Advanced Reading Strategies",
  "tipo_material": "PDF",
  "url_recurso": "assets/pdfs/advanced.pdf",
  "orden": 4,
  "nivel_acceso": "Pro"
}
```

### PUT `/api/materials/:id`
Actualiza un material existente.

**Parameters:**
- `id` (integer): ID del material

### DELETE `/api/materials/:id`
Elimina un material.

**Parameters:**
- `id` (integer): ID del material

---

## Data Structure

### Course
```typescript
{
  id: number
  nombre: string
  descripcion: string
  tipo_curso: "Examen" | "Inmersivo"
  estilo_progreso: "Porcentaje" | "Modular"
  url_imagen: string | null
  fecha_creacion: string (ISO 8601)
  activo: boolean
}
```

### Skill
```typescript
{
  id: number
  curso_id: number
  nombre: "Reading" | "Writing" | "Listening" | "Speaking"
  descripcion: string
  icon_url: string | null
  orden: number
}
```

### Material
```typescript
{
  id: number
  habilidad_id: number
  titulo: string
  tipo_material: "Texto" | "PDF" | "Video" | "Audio" | "Imagen"
  url_recurso: string | null
  contenido_texto: string | null
  duracion_minutos: number | null
  orden: number
  nivel_acceso: "Freemium" | "Básico" | "Pro" | "Premium"
  fecha_creacion: string (ISO 8601)
  creado_por: number | null
}
```

---

## Error Responses

### 404 Not Found
```json
{
  "success": false,
  "message": "Course not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Error message description"
}
```

---

## Questions (Preguntas)

### GET `/api/questions/skill/:skillId`
Obtiene todas las preguntas de una habilidad específica.

**Parameters:**
- `skillId` (integer): ID de la habilidad

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "habilidad_id": 1,
      "texto_pregunta": "What is the main idea of the passage?",
      "tipo_pregunta": "Multiple Choice",
      "audio_url": null,
      "video_url": null,
      "imagen_url": null,
      "nivel_dificultad": "Medium",
      "puntaje": 10,
      "tiempo_limite_segundos": 60,
      "nivel_acceso": "Freemium"
    }
  ],
  "count": 5
}
```

### GET `/api/questions/:id`
Obtiene una pregunta específica con sus opciones de respuesta.

**Parameters:**
- `id` (integer): ID de la pregunta

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "habilidad_id": 1,
    "texto_pregunta": "What is the main idea?",
    "tipo_pregunta": "Multiple Choice",
    "puntaje": 10,
    "options": [
      {
        "id": 1,
        "pregunta_id": 1,
        "texto_opcion": "Option A",
        "es_correcta": true,
        "explicacion": "This is the correct answer because..."
      }
    ]
  }
}
```

### POST `/api/answers`
Envía la respuesta de un usuario a una pregunta.

**Request Body:**
```json
{
  "usuario_id": 1,
  "pregunta_id": 1,
  "opcion_seleccionada_id": 1,
  "respuesta_texto": null,
  "audio_url": null
}
```

**Response:**
```json
{
  "success": true,
  "message": "User answer created successfully",
  "data": {
    "id": 1,
    "usuario_id": 1,
    "pregunta_id": 1,
    "opcion_seleccionada_id": 1,
    "es_correcta": true,
    "puntos_obtenidos": 10,
    "fecha_respuesta": "2025-10-08T17:00:00.000Z"
  }
}
```

---

## Quizzes (Cuestionarios)

### GET `/api/quizzes/skill/:skillId`
Obtiene todos los cuestionarios de una habilidad específica.

**Parameters:**
- `skillId` (integer): ID de la habilidad

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "habilidad_id": 1,
      "nombre": "TOEFL Reading Quiz 1",
      "descripcion": "Practice quiz for TOEFL Reading",
      "nivel_dificultad": "Medium",
      "tiempo_limite_minutos": 30,
      "puntaje_minimo_aprobacion": 70,
      "nivel_acceso": "Freemium"
    }
  ],
  "count": 3
}
```

### GET `/api/quizzes/:id`
Obtiene un cuestionario específico con sus preguntas.

**Parameters:**
- `id` (integer): ID del cuestionario

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nombre": "TOEFL Reading Quiz 1",
    "descripcion": "Practice quiz",
    "questions": [
      {
        "id": 1,
        "texto_pregunta": "What is the main idea?",
        "tipo_pregunta": "Multiple Choice",
        "puntaje": 10,
        "opciones": [...]
      }
    ]
  }
}
```

### POST `/api/attempts`
Crea un nuevo intento de cuestionario.

**Request Body:**
```json
{
  "usuario_id": 1,
  "cuestionario_id": 1,
  "fecha_inicio": "2025-10-08T17:00:00.000Z",
  "estado": "En Progreso"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Quiz attempt created successfully",
  "data": {
    "id": 1,
    "usuario_id": 1,
    "cuestionario_id": 1,
    "fecha_inicio": "2025-10-08T17:00:00.000Z",
    "estado": "En Progreso"
  }
}
```

### PUT `/api/attempts/:id`
Actualiza un intento de cuestionario (completarlo).

**Parameters:**
- `id` (integer): ID del intento

**Request Body:**
```json
{
  "fecha_fin": "2025-10-08T17:30:00.000Z",
  "puntos_obtenidos": 85,
  "porcentaje": 85.0,
  "estado": "Completado"
}
```

### GET `/api/users/:userId/quizzes/:quizId/best`
Obtiene el mejor intento de un usuario en un cuestionario específico.

**Parameters:**
- `userId` (integer): ID del usuario
- `quizId` (integer): ID del cuestionario

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "usuario_id": 1,
    "cuestionario_id": 1,
    "puntos_obtenidos": 95,
    "porcentaje": 95.0,
    "fecha_inicio": "2025-10-08T17:00:00.000Z",
    "fecha_fin": "2025-10-08T17:30:00.000Z",
    "estado": "Completado"
  }
}
```

---

## Current Status

✅ **Implemented Endpoints:**
- Courses: GET all, GET by ID, POST, PUT, DELETE
- Skills: GET all, GET by ID, GET by course, POST, PUT, DELETE
- Materials: GET all, GET by ID, GET by skill, POST, PUT, DELETE
- Questions: GET by skill, GET by ID, POST answers
- Quizzes: GET by skill, GET by ID, POST/PUT attempts, GET best attempt
- Answer Options: GET, POST, PUT, DELETE
- User Answers: GET, POST, PUT, DELETE

🔄 **In Development:**
- Authentication endpoints (/api/auth)
- User management (/api/users)
- Progress tracking (/api/progress)

📊 **Test Data Available:**
- 4 Courses (TOEFL, IELTS, Business English, English in Action)
- 16 Skills (4 skills per course: Reading, Writing, Listening, Speaking)
- 5 Materials (sample materials for testing)

---

## Notes

- All timestamps are in ISO 8601 format (UTC)
- Boolean fields: `activo` indicates if a course is active
- Soft delete: DELETE endpoints mark records as inactive instead of removing them
- Nested relationships: Skills belong to Courses, Materials belong to Skills
- Question types: "Multiple Choice", "Open Text", "Audio Response"
- Quiz states: "En Progreso", "Completado", "Abandonado"
