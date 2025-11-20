# 🗄️ BASE DE DATOS - EnglishPro

**Esquema completo de PostgreSQL, relaciones y queries importantes**

---

## 📊 Resumen

- **DBMS**: PostgreSQL 15
- **Host**: Supabase Cloud
- **Total tablas**: 16
- **Estado**: ✅ Schema ejecutado, RLS deshabilitado, triggers configurados

**⚠️ IMPORTANTE - Convención de nombres:**
- En este documento, los nombres de tablas y columnas se muestran en **PascalCase** (ej: `ID_Usuario`, `Nombre_Plan`) para mayor legibilidad
- En **Supabase**, todos los nombres reales son **minúsculas** (ej: `id_usuario`, `nombre_plan`, `usuarios`, `docentes`)
- Al escribir queries o código, usa siempre **minúsculas**: `SELECT id_usuario FROM usuarios`

---

## 🏗️ Diagrama ER (Entity-Relationship)

```
┌─────────────┐
│   Planes    │
│             │
│ ID_Plan (PK)│◄─────┐
│ Nombre_Plan │      │
│ Precio      │      │ FK
│ Límites...  │      │
└─────────────┘      │
                     │
                     │
┌─────────────────────┼──────────────────┐
│                     │                  │
│  ┌────────────────┐ │ ┌──────────────┐ │
│  │   Usuarios     │ │ │   Pagos      │ │
│  │                │ │ │              │ │
│  │ ID_Usuario(PK)─┼─┘ │ ID_Pago (PK) │ │
│  │ Email          │   │ ID_Usuario   │─┘
│  │ Password_Hash  │   │ ID_Plan      │
│  │ ID_Plan (FK)   │   │ Monto        │
│  │ Rol            │   │ Stripe_ID    │
│  │ Es_Docente     │   └──────────────┘
│  └────────┬───────┘
│           │
│     ┌─────┴─────┬──────────────┬──────────────┐
│     │           │              │              │
│  ┌──▼───────┐  ┌▼────────────┐ ┌▼────────────┐ ┌──────────────┐
│  │ Docentes │  │ Respuestas_ │ │  Progreso_  │ │ Beneficios_  │
│  │          │  │  Usuario    │ │  Usuarios   │ │  Usuario     │
│  └──┬───────┘  └─────────────┘ └─────────────┘ └──────────────┘
│     │
│     │ FK (Creado_Por)
│     │
│  ┌──▼──────────────────────────────────┐
│  │                                      │
│  ▼                                      ▼
│  Materiales_Estudio              Cuestionarios
│  Preguntas
│
│
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│   Cursos    │◄─────│ Habilidades  │◄─────│  Materiales  │
│             │      │              │      │  Preguntas   │
│ ID_Curso(PK)│      │ ID_Habilidad │      │  Cuestionario│
│ Nombre      │      │ ID_Curso(FK) │      └──────────────┘
│ Tipo_Curso  │      │ Nombre       │
│ Estilo      │      │ (Writing,    │
└─────────────┘      │  Speaking,   │
                     │  Listening,  │
                     │  Reading)    │
                     └──────────────┘

┌─────────────┐      ┌──────────────────┐      ┌──────────────┐
│  Preguntas  │◄─────│ Cuestionario_    │─────▶│Cuestionarios │
│             │      │ Preguntas (N:M)  │      │              │
│ ID_Pregunta │      └──────────────────┘      └──────────────┘
│ Texto       │
│ Tipo        │
│ URLs...     │
└──────┬──────┘
       │
       ↓
┌──────────────────┐
│ Opciones_       │
│ Respuesta       │
│                 │
│ ID_Pregunta(FK) │
│ Texto_Opcion    │
│ Es_Correcta     │
└─────────────────┘
```

---

## Tablas de base de datos (Schema actualizado):

### 1. USUARIOS, ROLES Y PLANES

Tabla: planes
id_plan: integer, PK (Auto-increment)
nombre_plan: varchar, UNIQUE
precio: numeric
limite_preguntas_por_habilidad: integer
acceso_sesiones_vivo: boolean (Default: false)
cantidad_sesiones_vivo: integer (Default: 0)
acceso_simulacros: boolean (Default: false)
cantidad_simulacros: integer (Default: 0)
descripcion: text
fecha_creacion: timestamp (Default: now)

Tabla: usuarios
id_usuario: integer, PK (Auto-increment)
nombre_completo: varchar
email: varchar, UNIQUE
password_hash: varchar
profesion: varchar
id_plan: integer (FK -> planes.id_plan, Default: 1)
es_docente: boolean (Default: false)
rol: varchar (Check: 'Estudiante', 'Docente', 'Admin', Default: 'Estudiante')
fecha_registro: timestamp (Default: now)
ultimo_acceso: timestamp
supabase_uid: uuid, UNIQUE
email_verificado: boolean (Default: false)

Tabla: docentes
id_docente: integer, PK (Auto-increment)
id_usuario: integer, UNIQUE (FK -> usuarios.id_usuario)
especialidad: varchar
certificaciones: text
anos_experiencia: integer
calificacion_promedio: numeric (Default: 0.00)
total_retroalimentaciones: integer (Default: 0)
fecha_registro_docente: timestamp (Default: now)

Tabla: beneficios_usuario
id_beneficio: integer, PK (Auto-increment)
id_usuario: integer, UNIQUE (FK -> usuarios.id_usuario)
sesiones_vivo_restantes: integer (Default: 0)
simulacros_restantes: integer (Default: 0)
fecha_actualizacion: timestamp (Default: now)

### 2. ESTRUCTURA ACADÉMICA (CURSOS)

Tabla: cursos
id: integer, PK (Auto-increment)
nombre_curso: varchar, UNIQUE
descripcion: text
tipo_curso: varchar (Check: 'Examen', 'Inmersivo')
estilo_progreso: varchar (Check: 'Porcentaje', 'Modular')
url_imagen: varchar
fecha_creacion: timestamp (Default: now)
activo: boolean (Default: true)

Tabla: habilidades
id_habilidad: integer, PK (Auto-increment)
curso_id: integer (FK -> cursos.id)
nombre_habilidad: varchar (Check: 'Writing', 'Speaking', 'Listening', 'Reading')
descripcion: text
orden: integer (Default: 1)

Tabla: modulos
id_modulo: integer, PK (Auto-increment)
id_habilidad: integer (FK -> habilidades.id_habilidad)
nombre_modulo: varchar
descripcion: text
orden: integer (Default: 1)
activo: boolean (Default: true)
fecha_creacion: timestamp (Default: now)

Tabla: tipos_actividad
id: integer, PK (Auto-increment)
id_habilidad: integer (FK -> habilidades.id_habilidad)
nombre: varchar
descripcion: text
orden: integer (Default: 1)
activo: boolean (Default: true)

### 3. CONTENIDO Y MATERIALES

Tabla: materiales_estudio
id_material: integer, PK (Auto-increment)
id_habilidad: integer (FK -> habilidades.id_habilidad)
id_modulo: integer (FK -> modulos.id_modulo)
id_cuestionario: integer (FK -> cuestionarios.id_cuestionario)
titulo: varchar
tipo_material: varchar (Check: 'PDF', 'Video', 'Audio', 'Texto', 'Imagen')
url_recurso: varchar
contenido_texto: text
duracion_minutos: integer
orden: integer (Default: 1)
nivel_acceso: varchar (Check: 'Freemium', 'Basico', 'Pro', 'Premium', Default: 'Freemium')
fecha_creacion: timestamp (Default: now)
creado_por: integer (FK -> docentes.id_docente)

### 4. EVALUACIONES Y CUESTIONARIOS

Tabla: preguntas
id_pregunta: integer, PK (Auto-increment)
id_habilidad: integer (FK -> habilidades.id_habilidad)
texto_pregunta: text
tipo_pregunta: varchar (Check: 'Multiple Choice', 'Texto Abierto', 'Audio Grabacion')
url_audio: varchar
url_video: varchar
url_imagen: varchar
puntos: integer (Default: 1)
nivel_dificultad: varchar (Check: 'Basico', 'Intermedio', 'Avanzado')
nivel_acceso: varchar (Check: 'Freemium', 'Basico', 'Pro', 'Premium', Default: 'Freemium')
fecha_creacion: timestamp (Default: now)
creado_por: integer (FK -> docentes.id_docente)
explicacion: text

Tabla: opciones_respuesta
id_opcion: integer, PK (Auto-increment)
id_pregunta: integer (FK -> preguntas.id_pregunta)
texto_opcion: text
es_correcta: boolean (Default: false)
orden: integer (Default: 1)

Tabla: cuestionarios
id_cuestionario: integer, PK (Auto-increment)
id_modulo: integer (FK -> modulos.id_modulo)
id_tipo_actividad: integer (FK -> tipos_actividad.id)
titulo: varchar
descripcion: text
tiempo_limite_minutos: integer
nivel_dificultad: varchar (Check: 'Basico', 'Intermedio', 'Avanzado')
tipo_evaluacion: varchar (Check: 'Practica', 'Simulacro', 'Examen')
fecha_creacion: timestamp (Default: now)
creado_por: integer (FK -> docentes.id_docente)
activo: boolean (Default: true)

Tabla: cuestionario_preguntas
id_cuestionario: integer (FK -> cuestionarios.id_cuestionario)
id_pregunta: integer (FK -> preguntas.id_pregunta)
orden: integer (Default: 1)
PRIMARY KEY compuesta: (id_cuestionario, id_pregunta)

### 5. PROGRESO Y RETROALIMENTACIÓN

Tabla: respuestas_usuario
id_respuesta: integer, PK (Auto-increment)
id_usuario: integer (FK -> usuarios.id_usuario)
id_pregunta: integer (FK -> preguntas.id_pregunta)
id_cuestionario: integer (FK -> cuestionarios.id_cuestionario)
id_opcion_seleccionada: integer (FK -> opciones_respuesta.id_opcion)
texto_ensayo: text
url_grabacion: varchar
es_correcta: boolean
puntos_obtenidos: integer (Default: 0)
fecha_respuesta: timestamp (Default: now)
requiere_revision: boolean (Default: false)
respuesta_texto: text
respuesta_audio_url: text

Tabla: retroalimentacion_docente
id_retroalimentacion: integer, PK (Auto-increment)
id_respuesta: integer (FK -> respuestas_usuario.id_respuesta)
id_docente: integer (FK -> docentes.id_docente)
comentario: text
calificacion: integer (Check: 0-100)
puntos_asignados: integer
fecha_retroalimentacion: timestamp (Default: now)

Tabla: progreso_usuarios
id_progreso: integer, PK (Auto-increment)
id_usuario: integer (FK -> usuarios.id_usuario)
curso_id: integer (FK -> cursos.id)
avance_porcentaje: numeric (Check: 0-100, Default: 0.00)
modulos_completados: integer (Default: 0)
preguntas_respondidas: integer (Default: 0)
preguntas_correctas: integer (Default: 0)
puntos_totales: integer (Default: 0)
ultima_actividad: timestamp (Default: now)
fecha_inicio: timestamp (Default: now)

### 6. FINANZAS Y SISTEMA

Tabla: pagos
id_pago: integer, PK (Auto-increment)
id_usuario: integer (FK -> usuarios.id_usuario)
id_plan: integer (FK -> planes.id_plan)
monto: numeric
metodo_pago: varchar
estado_pago: varchar (Check: 'Pendiente', 'Completado', 'Fallido', 'Reembolsado')
id_transaccion_stripe: varchar, UNIQUE
fecha_pago: timestamp (Default: now)
fecha_inicio_vigencia: timestamp
fecha_fin_vigencia: timestamp

Tabla: notificaciones
id_notificacion: integer, PK (Auto-increment)
id_usuario: integer (FK -> usuarios.id_usuario)
titulo: varchar
mensaje: text
tipo: varchar (Check: 'Info', 'Retroalimentacion', 'Pago', 'Sistema')
leida: boolean (Default: false)
fecha_creacion: timestamp (Default: now)


## 📋 16 Tablas Explicadas

### 1. Planes

**Propósito:** Definir planes de suscripción (Freemium, Básico, Pro, Premium)

```sql
CREATE TABLE Planes (
    ID_Plan SERIAL PRIMARY KEY,
    Nombre_Plan VARCHAR(50) NOT NULL UNIQUE,
    Precio DECIMAL(10, 2) NOT NULL,
    Limite_Preguntas_Por_Habilidad INT NOT NULL,
    Acceso_Sesiones_Vivo BOOLEAN DEFAULT FALSE,
    Cantidad_Sesiones_Vivo INT DEFAULT 0,
    Acceso_Simulacros BOOLEAN DEFAULT FALSE,
    Cantidad_Simulacros INT DEFAULT 0,
    Descripcion TEXT,
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Datos iniciales:**

| ID_Plan | Nombre_Plan | Precio | Límite_Preguntas | Sesiones | Simulacros |
|---------|-------------|--------|------------------|----------|------------|
| 1 | Freemium | $0.00 | 1 | 0 | 0 |
| 2 | Basico | $9.99 | 3 | 0 | 0 |
| 3 | Pro | $19.99 | 5 | 0 | 0 |
| 4 | Premium | $39.99 | 5 | 5 | 2 |

**Queries comunes:**

```sql
-- Obtener todos los planes
SELECT * FROM Planes ORDER BY Precio;

-- Plan de un usuario
SELECT p.* FROM Planes p
JOIN Usuarios u ON u.ID_Plan = p.ID_Plan
WHERE u.ID_Usuario = 123;
```

**Usado en:**
- `app/lib/screens/subscription_plans_screen.dart:45`
- `app/lib/models/plan_model.dart:10`

---

### 2. Usuarios

**Propósito:** Almacenar estudiantes y docentes

```sql
CREATE TABLE Usuarios (
    ID_Usuario SERIAL PRIMARY KEY,
    Nombre_Completo VARCHAR(150) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Password_Hash VARCHAR(255) NOT NULL,
    Profesion VARCHAR(100),
    ID_Plan INT NOT NULL DEFAULT 1,
    Es_Docente BOOLEAN DEFAULT FALSE,
    Rol VARCHAR(50) NOT NULL DEFAULT 'Estudiante'
        CHECK (Rol IN ('Estudiante', 'Docente', 'Admin')),
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Ultimo_Acceso TIMESTAMP,
    Firebase_UID VARCHAR(128) UNIQUE,
    Email_Verificado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_Plan) REFERENCES Planes(ID_Plan)
);
```

**Índices:**

```sql
CREATE INDEX idx_usuarios_email ON Usuarios(Email);
CREATE INDEX idx_usuarios_firebase_uid ON Usuarios(Firebase_UID);
```

**Queries comunes:**

```sql
-- Obtener usuario por email
SELECT * FROM Usuarios WHERE Email = 'user@example.com';

-- Obtener usuario por Firebase UID (Supabase auth)
SELECT * FROM Usuarios WHERE Firebase_UID = 'auth-uuid-123';

-- Listar todos los docentes
SELECT * FROM Usuarios WHERE Es_Docente = TRUE;

-- Contar usuarios por plan
SELECT p.Nombre_Plan, COUNT(*) as total
FROM Usuarios u
JOIN Planes p ON u.ID_Plan = p.ID_Plan
GROUP BY p.Nombre_Plan;
```

**Triggers:**

```sql
-- Crear beneficios automáticamente al registrar usuario
CREATE TRIGGER create_user_benefits
AFTER INSERT ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION crear_beneficios_usuario();
```

Ver `database/FIX_TRIGGER.sql:10`

**Usado en:**
- `app/lib/models/user.dart:15` (compatible Supabase)
- `app/lib/models/user_model.dart:10` (legacy)
- `app/lib/services/supabase_auth_service.dart:30`

---

### 3. Docentes

**Propósito:** Información adicional de docentes

```sql
CREATE TABLE Docentes (
    ID_Docente SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL UNIQUE,
    Especialidad VARCHAR(100),
    Certificaciones TEXT,
    Anos_Experiencia INT,
    Calificacion_Promedio DECIMAL(3, 2) DEFAULT 0.00,
    Total_Retroalimentaciones INT DEFAULT 0,
    Fecha_Registro_Docente TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE
);
```

**Relación:** 1:1 con Usuarios (solo si Es_Docente = TRUE)

**Queries comunes:**

```sql
-- Obtener info completa de un docente
SELECT u.Nombre_Completo, u.Email, d.*
FROM Docentes d
JOIN Usuarios u ON d.ID_Usuario = u.ID_Usuario
WHERE d.ID_Docente = 5;

-- Top docentes por calificación
SELECT u.Nombre_Completo, d.Calificacion_Promedio, d.Total_Retroalimentaciones
FROM Docentes d
JOIN Usuarios u ON d.ID_Usuario = u.ID_Usuario
ORDER BY d.Calificacion_Promedio DESC
LIMIT 10;
```

**Usado en:**
- `app/lib/screens/teacher_dashboard_screen.dart:25`
- `app/lib/screens/manual_grading_screen.dart:40`

---

### 4. Cursos

**Propósito:** 4 módulos educativos (TOEFL, IELTS, Business, Action)

```sql
CREATE TABLE Cursos (
    ID_Curso SERIAL PRIMARY KEY,
    Nombre_Curso VARCHAR(100) NOT NULL UNIQUE,
    Descripcion TEXT,
    Tipo_Curso VARCHAR(50) NOT NULL
        CHECK (Tipo_Curso IN ('Examen', 'Inmersivo')),
    Estilo_Progreso VARCHAR(50) NOT NULL
        CHECK (Estilo_Progreso IN ('Porcentaje', 'Modular')),
    URL_Imagen VARCHAR(500),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Activo BOOLEAN DEFAULT TRUE
);
```

**Datos iniciales:**

| ID_Curso | Nombre_Curso | Tipo_Curso | Estilo_Progreso |
|----------|--------------|------------|-----------------|
| 1 | TOEFL | Examen | Porcentaje |
| 2 | IELTS | Examen | Porcentaje |
| 3 | Business English | Inmersivo | Modular |
| 4 | English in Action | Inmersivo | Modular |

**Queries comunes:**

```sql
-- Listar cursos activos
SELECT * FROM Cursos WHERE Activo = TRUE;

-- Cursos con sus habilidades
SELECT c.Nombre_Curso, h.Nombre_Habilidad
FROM Cursos c
JOIN Habilidades h ON c.ID_Curso = h.ID_Curso
ORDER BY c.ID_Curso, h.Orden;
```

**Usado en:**
- `app/lib/screens/home_screen.dart:60` - Listar cursos
- `app/lib/screens/courses_list_screen.dart:30`
- `app/lib/models/course_model.dart:15`

---

### 5. Habilidades

**Propósito:** 4 habilidades por curso (Writing, Speaking, Listening, Reading)

```sql
CREATE TABLE Habilidades (
    ID_Habilidad SERIAL PRIMARY KEY,
    ID_Curso INT NOT NULL,
    Nombre_Habilidad VARCHAR(50) NOT NULL
        CHECK (Nombre_Habilidad IN ('Writing', 'Speaking', 'Listening', 'Reading')),
    Descripcion TEXT,
    Orden INT DEFAULT 1,
    FOREIGN KEY (ID_Curso) REFERENCES Cursos(ID_Curso) ON DELETE CASCADE,
    UNIQUE (ID_Curso, Nombre_Habilidad)
);
```

**Total filas:** 16 (4 cursos × 4 habilidades)

**Datos iniciales:**

| ID_Habilidad | ID_Curso | Nombre_Habilidad | Descripción |
|--------------|----------|------------------|-------------|
| 1 | 1 | Writing | Escritura académica para TOEFL |
| 2 | 1 | Speaking | Expresión oral para TOEFL |
| 3 | 1 | Listening | Comprensión auditiva para TOEFL |
| 4 | 1 | Reading | Comprensión lectora para TOEFL |
| ... | ... | ... | ... |

**Queries comunes:**

```sql
-- Habilidades de un curso
SELECT * FROM Habilidades
WHERE ID_Curso = 1
ORDER BY Orden;

-- Materiales de una habilidad
SELECT m.* FROM Materiales_Estudio m
WHERE m.ID_Habilidad = 5
ORDER BY m.Orden;
```

**Usado en:**
- `app/lib/models/skill_model.dart:15`
- `app/lib/screens/courses/toefl_screen.dart:45`

---

### 6. Materiales_Estudio

**Propósito:** PDFs, videos, audios, textos para estudiar

```sql
CREATE TABLE Materiales_Estudio (
    ID_Material SERIAL PRIMARY KEY,
    ID_Habilidad INT NOT NULL,
    Titulo VARCHAR(200) NOT NULL,
    Tipo_Material VARCHAR(50) NOT NULL
        CHECK (Tipo_Material IN ('PDF', 'Video', 'Audio', 'Texto', 'Imagen')),
    URL_Recurso VARCHAR(500),
    Contenido_Texto TEXT,
    Duracion_Minutos INT,
    Orden INT DEFAULT 1,
    Nivel_Acceso VARCHAR(50) DEFAULT 'Freemium'
        CHECK (Nivel_Acceso IN ('Freemium', 'Basico', 'Pro', 'Premium')),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Creado_Por INT,
    FOREIGN KEY (ID_Habilidad) REFERENCES Habilidades(ID_Habilidad) ON DELETE CASCADE,
    FOREIGN KEY (Creado_Por) REFERENCES Docentes(ID_Docente) ON DELETE SET NULL
);
```

**Índice:**

```sql
CREATE INDEX idx_materiales_habilidad ON Materiales_Estudio(ID_Habilidad);
```

**Queries comunes:**

```sql
-- Materiales de una habilidad (según plan del usuario)
SELECT m.* FROM Materiales_Estudio m
WHERE m.ID_Habilidad = 3
AND (
    m.Nivel_Acceso = 'Freemium'
    OR m.Nivel_Acceso IN (
        SELECT p.Nombre_Plan FROM Usuarios u
        JOIN Planes p ON u.ID_Plan = p.ID_Plan
        WHERE u.ID_Usuario = 123
    )
)
ORDER BY m.Orden;

-- Materiales por tipo
SELECT Tipo_Material, COUNT(*) as total
FROM Materiales_Estudio
GROUP BY Tipo_Material;
```

**Usado en:**
- `app/lib/models/material_model.dart:20`
- `app/lib/widgets/pdf_viewer_widget.dart:15`
- `app/lib/widgets/video_player_widget.dart:15`
- `app/lib/services/supabase_storage_service.dart:45`

---

### 7. Cuestionarios

**Propósito:** Evaluaciones (práctica, simulacro, examen)

```sql
CREATE TABLE Cuestionarios (
    ID_Cuestionario SERIAL PRIMARY KEY,
    ID_Habilidad INT NOT NULL,
    Titulo VARCHAR(200) NOT NULL,
    Descripcion TEXT,
    Tiempo_Limite_Minutos INT,
    Nivel_Dificultad VARCHAR(50)
        CHECK (Nivel_Dificultad IN ('Basico', 'Intermedio', 'Avanzado')),
    Tipo_Evaluacion VARCHAR(50)
        CHECK (Tipo_Evaluacion IN ('Practica', 'Simulacro', 'Examen')),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Creado_Por INT,
    Activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ID_Habilidad) REFERENCES Habilidades(ID_Habilidad) ON DELETE CASCADE,
    FOREIGN KEY (Creado_Por) REFERENCES Docentes(ID_Docente) ON DELETE SET NULL
);
```

**Queries comunes:**

```sql
-- Cuestionarios de una habilidad
SELECT * FROM Cuestionarios
WHERE ID_Habilidad = 7 AND Activo = TRUE;

-- Preguntas de un cuestionario
SELECT p.* FROM Preguntas p
JOIN Cuestionario_Preguntas cp ON p.ID_Pregunta = cp.ID_Pregunta
WHERE cp.ID_Cuestionario = 10
ORDER BY cp.Orden;
```

**Usado en:**
- `app/lib/screens/quiz_screen.dart:30`

---

### 8. Preguntas

**Propósito:** Preguntas para cuestionarios (Multiple Choice, Texto Abierto, Audio)

```sql
CREATE TABLE Preguntas (
    ID_Pregunta SERIAL PRIMARY KEY,
    ID_Habilidad INT NOT NULL,
    Texto_Pregunta TEXT NOT NULL,
    Tipo_Pregunta VARCHAR(50) NOT NULL
        CHECK (Tipo_Pregunta IN ('Multiple Choice', 'Texto Abierto', 'Audio Grabacion')),
    URL_Audio VARCHAR(500),
    URL_Video VARCHAR(500),
    URL_Imagen VARCHAR(500),
    Puntos INT DEFAULT 1,
    Nivel_Dificultad VARCHAR(50)
        CHECK (Nivel_Dificultad IN ('Basico', 'Intermedio', 'Avanzado')),
    Nivel_Acceso VARCHAR(50) DEFAULT 'Freemium',
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Creado_Por INT,
    FOREIGN KEY (ID_Habilidad) REFERENCES Habilidades(ID_Habilidad) ON DELETE CASCADE,
    FOREIGN KEY (Creado_Por) REFERENCES Docentes(ID_Docente) ON DELETE SET NULL
);
```

**Índice:**

```sql
CREATE INDEX idx_preguntas_habilidad ON Preguntas(ID_Habilidad);
```

**Queries comunes:**

```sql
-- Preguntas de una habilidad (según plan)
SELECT p.* FROM Preguntas p
WHERE p.ID_Habilidad = 5
AND p.Nivel_Acceso <= (
    SELECT pl.Nombre_Plan FROM Usuarios u
    JOIN Planes pl ON u.ID_Plan = pl.ID_Plan
    WHERE u.ID_Usuario = 123
)
LIMIT (
    SELECT pl.Limite_Preguntas_Por_Habilidad FROM Usuarios u
    JOIN Planes pl ON u.ID_Plan = pl.ID_Plan
    WHERE u.ID_Usuario = 123
);
```

**Usado en:**
- `app/lib/models/question_model.dart:25`
- `app/lib/screens/quiz_screen.dart:80`

---

### 9. Cuestionario_Preguntas

**Propósito:** Relación N:M entre Cuestionarios y Preguntas

```sql
CREATE TABLE Cuestionario_Preguntas (
    ID_Cuestionario INT NOT NULL,
    ID_Pregunta INT NOT NULL,
    Orden INT DEFAULT 1,
    PRIMARY KEY (ID_Cuestionario, ID_Pregunta),
    FOREIGN KEY (ID_Cuestionario) REFERENCES Cuestionarios(ID_Cuestionario) ON DELETE CASCADE,
    FOREIGN KEY (ID_Pregunta) REFERENCES Preguntas(ID_Pregunta) ON DELETE CASCADE
);
```

**Uso:** Un cuestionario puede tener muchas preguntas, y una pregunta puede estar en varios cuestionarios.

---

### 10. Opciones_Respuesta

**Propósito:** Opciones para preguntas de tipo "Multiple Choice"

```sql
CREATE TABLE Opciones_Respuesta (
    ID_Opcion SERIAL PRIMARY KEY,
    ID_Pregunta INT NOT NULL,
    Texto_Opcion TEXT NOT NULL,
    Es_Correcta BOOLEAN DEFAULT FALSE,
    Orden INT DEFAULT 1,
    FOREIGN KEY (ID_Pregunta) REFERENCES Preguntas(ID_Pregunta) ON DELETE CASCADE
);
```

**Queries comunes:**

```sql
-- Opciones de una pregunta
SELECT * FROM Opciones_Respuesta
WHERE ID_Pregunta = 25
ORDER BY Orden;

-- Respuesta correcta
SELECT * FROM Opciones_Respuesta
WHERE ID_Pregunta = 25 AND Es_Correcta = TRUE;
```

**Usado en:**
- `app/lib/models/question_model.dart:45` (dentro de Question)

---

### 11. Respuestas_Usuario

**Propósito:** Respuestas de estudiantes a preguntas

```sql
CREATE TABLE Respuestas_Usuario (
    ID_Respuesta SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    ID_Pregunta INT NOT NULL,
    ID_Opcion_Seleccionada INT,
    Texto_Ensayo TEXT,
    URL_Grabacion VARCHAR(500),
    Es_Correcta BOOLEAN,
    Puntos_Obtenidos INT DEFAULT 0,
    Fecha_Respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Requiere_Revision BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE,
    FOREIGN KEY (ID_Pregunta) REFERENCES Preguntas(ID_Pregunta) ON DELETE CASCADE,
    FOREIGN KEY (ID_Opcion_Seleccionada) REFERENCES Opciones_Respuesta(ID_Opcion) ON DELETE SET NULL
);
```

**Índice:**

```sql
CREATE INDEX idx_respuestas_usuario ON Respuestas_Usuario(ID_Usuario, ID_Pregunta);
```

**Queries comunes:**

```sql
-- Respuestas de un usuario
SELECT r.*, p.Texto_Pregunta
FROM Respuestas_Usuario r
JOIN Preguntas p ON r.ID_Pregunta = p.ID_Pregunta
WHERE r.ID_Usuario = 123
ORDER BY r.Fecha_Respuesta DESC;

-- Respuestas que requieren revisión docente
SELECT r.*, u.Nombre_Completo, p.Texto_Pregunta
FROM Respuestas_Usuario r
JOIN Usuarios u ON r.ID_Usuario = u.ID_Usuario
JOIN Preguntas p ON r.ID_Pregunta = p.ID_Pregunta
WHERE r.Requiere_Revision = TRUE
ORDER BY r.Fecha_Respuesta;
```

**Usado en:**
- `app/lib/screens/quiz_screen.dart:150` - Submit respuesta
- `app/lib/screens/manual_grading_screen.dart:60` - Revisar

---

### 12. Retroalimentacion_Docente

**Propósito:** Feedback manual de docentes a respuestas de estudiantes

```sql
CREATE TABLE Retroalimentacion_Docente (
    ID_Retroalimentacion SERIAL PRIMARY KEY,
    ID_Respuesta INT NOT NULL,
    ID_Docente INT NOT NULL,
    Comentario TEXT NOT NULL,
    Calificacion INT CHECK (Calificacion >= 0 AND Calificacion <= 100),
    Puntos_Asignados INT,
    Fecha_Retroalimentacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Respuesta) REFERENCES Respuestas_Usuario(ID_Respuesta) ON DELETE CASCADE,
    FOREIGN KEY (ID_Docente) REFERENCES Docentes(ID_Docente) ON DELETE CASCADE
);
```

**Queries comunes:**

```sql
-- Feedback para un estudiante
SELECT rf.*, d.Especialidad, u.Nombre_Completo as Docente_Nombre
FROM Retroalimentacion_Docente rf
JOIN Docentes d ON rf.ID_Docente = d.ID_Docente
JOIN Usuarios u ON d.ID_Usuario = u.ID_Usuario
JOIN Respuestas_Usuario r ON rf.ID_Respuesta = r.ID_Respuesta
WHERE r.ID_Usuario = 123
ORDER BY rf.Fecha_Retroalimentacion DESC;
```

**Usado en:**
- `app/lib/screens/manual_grading_screen.dart:100` - Crear feedback
- Planes Pro y Premium solamente

---

### 13. Progreso_Usuarios

**Propósito:** Seguimiento de progreso por curso

```sql
CREATE TABLE Progreso_Usuarios (
    ID_Progreso SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    ID_Curso INT NOT NULL,
    Avance_Porcentaje DECIMAL(5, 2) DEFAULT 0.00
        CHECK (Avance_Porcentaje >= 0 AND Avance_Porcentaje <= 100),
    Modulos_Completados INT DEFAULT 0,
    Preguntas_Respondidas INT DEFAULT 0,
    Preguntas_Correctas INT DEFAULT 0,
    Puntos_Totales INT DEFAULT 0,
    Ultima_Actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Fecha_Inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE,
    FOREIGN KEY (ID_Curso) REFERENCES Cursos(ID_Curso) ON DELETE CASCADE,
    UNIQUE (ID_Usuario, ID_Curso)
);
```

**Índice:**

```sql
CREATE INDEX idx_progreso_usuario_curso ON Progreso_Usuarios(ID_Usuario, ID_Curso);
```

**Queries comunes:**

```sql
-- Progreso de un usuario en todos los cursos
SELECT c.Nombre_Curso, p.Avance_Porcentaje, p.Puntos_Totales
FROM Progreso_Usuarios p
JOIN Cursos c ON p.ID_Curso = c.ID_Curso
WHERE p.ID_Usuario = 123;

-- Actualizar progreso
UPDATE Progreso_Usuarios
SET Preguntas_Respondidas = Preguntas_Respondidas + 1,
    Preguntas_Correctas = Preguntas_Correctas + 1,
    Puntos_Totales = Puntos_Totales + 5,
    Avance_Porcentaje = (Preguntas_Respondidas * 100.0 / 50), -- 50 preguntas total
    Ultima_Actividad = CURRENT_TIMESTAMP
WHERE ID_Usuario = 123 AND ID_Curso = 1;
```

**Usado en:**
- `app/lib/screens/progress_dashboard_screen.dart:40`
- `app/lib/models/progress_model.dart:15`

---

### 14. Pagos

**Propósito:** Historial de transacciones (Stripe)

```sql
CREATE TABLE Pagos (
    ID_Pago SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    ID_Plan INT NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    Metodo_Pago VARCHAR(50) NOT NULL,
    Estado_Pago VARCHAR(50) NOT NULL
        CHECK (Estado_Pago IN ('Pendiente', 'Completado', 'Fallido', 'Reembolsado')),
    ID_Transaccion_Stripe VARCHAR(255) UNIQUE,
    Fecha_Pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Fecha_Inicio_Vigencia TIMESTAMP,
    Fecha_Fin_Vigencia TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE,
    FOREIGN KEY (ID_Plan) REFERENCES Planes(ID_Plan) ON DELETE SET NULL
);
```

**Índice:**

```sql
CREATE INDEX idx_pagos_usuario ON Pagos(ID_Usuario);
```

**Usado en:**
- Backend futuro (Stripe webhook)
- `app/lib/screens/subscription_plans_screen.dart:80` (futuro)

---

### 15. Beneficios_Usuario

**Propósito:** Sesiones y simulacros restantes (Planes Premium)

```sql
CREATE TABLE Beneficios_Usuario (
    ID_Beneficio SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    Sesiones_Vivo_Restantes INT DEFAULT 0,
    Simulacros_Restantes INT DEFAULT 0,
    Fecha_Actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE,
    UNIQUE (ID_Usuario)
);
```

**Creado automáticamente:** Trigger `create_user_benefits` al registrar usuario

**Queries comunes:**

```sql
-- Beneficios de un usuario
SELECT * FROM Beneficios_Usuario WHERE ID_Usuario = 123;

-- Actualizar al tomar sesión en vivo
UPDATE Beneficios_Usuario
SET Sesiones_Vivo_Restantes = Sesiones_Vivo_Restantes - 1,
    Fecha_Actualizacion = CURRENT_TIMESTAMP
WHERE ID_Usuario = 123 AND Sesiones_Vivo_Restantes > 0;
```

**Usado en:**
- Trigger automático: `database/FIX_TRIGGER.sql:25`

---

### 16. Notificaciones

**Propósito:** Sistema de notificaciones (Info, Retroalimentación, Pago, Sistema)

```sql
CREATE TABLE Notificaciones (
    ID_Notificacion SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    Titulo VARCHAR(200) NOT NULL,
    Mensaje TEXT NOT NULL,
    Tipo VARCHAR(50)
        CHECK (Tipo IN ('Info', 'Retroalimentacion', 'Pago', 'Sistema')),
    Leida BOOLEAN DEFAULT FALSE,
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE
);
```

**Índice:**

```sql
CREATE INDEX idx_notificaciones_usuario ON Notificaciones(ID_Usuario, Leida);
```

**Queries comunes:**

```sql
-- Notificaciones no leídas
SELECT * FROM Notificaciones
WHERE ID_Usuario = 123 AND Leida = FALSE
ORDER BY Fecha_Creacion DESC;

-- Marcar como leída
UPDATE Notificaciones
SET Leida = TRUE
WHERE ID_Notificacion = 456;
```

**Usado en:**
- `app/lib/screens/notifications_screen.dart:30`
- `app/lib/models/notification.dart:10`

---

## 🔧 Triggers Importantes

### 1. create_user_benefits

**Archivo:** `database/FIX_TRIGGER.sql`

```sql
CREATE OR REPLACE FUNCTION crear_beneficios_usuario()
RETURNS TRIGGER AS $$
BEGIN
    -- Crear fila en Beneficios_Usuario automáticamente
    INSERT INTO Beneficios_Usuario (ID_Usuario, Sesiones_Vivo_Restantes, Simulacros_Restantes)
    VALUES (NEW.ID_Usuario, 0, 0);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_user_benefits
AFTER INSERT ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION crear_beneficios_usuario();
```

**Qué hace:**
- Cuando se registra un usuario → automáticamente crea fila en `Beneficios_Usuario`
- Inicializa con 0 sesiones y 0 simulacros
- Al upgradear plan → actualizar beneficios

---

## 🔐 Row Level Security (RLS)

**Estado actual:** DESHABILITADO

```sql
-- database/DISABLE_RLS_TEMPORAL.sql (YA EJECUTADO)
ALTER TABLE Usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE Respuestas_Usuario DISABLE ROW LEVEL SECURITY;
-- ... todas las tablas
```

**Por qué:**
- Trigger recursivo causaba error
- Desarrollo más rápido sin RLS

**Futuro (Producción):**

Ver `No_Necesarios/database/RLS_CORRECTO.sql` para políticas correctas:

```sql
-- Usuarios solo ven sus propios datos
CREATE POLICY "Users can view own data" ON Usuarios
  FOR SELECT USING (auth.uid()::text = Firebase_UID);

-- Usuarios solo actualizan sus propios datos
CREATE POLICY "Users can update own data" ON Usuarios
  FOR UPDATE USING (auth.uid()::text = Firebase_UID);

-- Docentes ven respuestas que deben revisar
CREATE POLICY "Teachers can view answers to grade" ON Respuestas_Usuario
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM Usuarios u
      WHERE u.Firebase_UID = auth.uid()::text
      AND u.Es_Docente = TRUE
    )
  );
```

---

## 📊 Queries Útiles para Desarrollo

### Estadísticas Generales

```sql
-- Total usuarios por plan
SELECT p.Nombre_Plan, COUNT(*) as total
FROM Usuarios u
JOIN Planes p ON u.ID_Plan = p.ID_Plan
GROUP BY p.Nombre_Plan;

-- Preguntas respondidas hoy
SELECT COUNT(*) FROM Respuestas_Usuario
WHERE Fecha_Respuesta >= CURRENT_DATE;

-- Top 10 estudiantes por puntos
SELECT u.Nombre_Completo, SUM(p.Puntos_Totales) as puntos
FROM Usuarios u
JOIN Progreso_Usuarios p ON u.ID_Usuario = p.ID_Usuario
GROUP BY u.ID_Usuario, u.Nombre_Completo
ORDER BY puntos DESC
LIMIT 10;
```

### Testing

```sql
-- Crear usuario de prueba
INSERT INTO Usuarios (Nombre_Completo, Email, Password_Hash, ID_Plan, Rol)
VALUES ('Test User', 'test@example.com', '$2a$10$...', 1, 'Estudiante');

-- Crear progreso inicial
INSERT INTO Progreso_Usuarios (ID_Usuario, ID_Curso)
SELECT 123, ID_Curso FROM Cursos;

-- Simular respuestas
INSERT INTO Respuestas_Usuario (ID_Usuario, ID_Pregunta, ID_Opcion_Seleccionada, Es_Correcta, Puntos_Obtenidos)
VALUES (123, 1, 2, TRUE, 5);
```

---

## 🗂️ Archivos SQL del Proyecto

| Archivo | Propósito | Estado |
|---------|-----------|--------|
| `database/schema.sql` | Crear 16 tablas + datos iniciales | ✅ EJECUTADO |
| `database/DISABLE_RLS_TEMPORAL.sql` | Deshabilitar RLS | ✅ EJECUTADO |
| `database/FIX_TRIGGER.sql` | Trigger correcto beneficios | ✅ EJECUTADO |
| `database/seed.sql` | Datos de prueba (opcional) | 🟡 Opcional |
| `No_Necesarios/database/RLS_CORRECTO.sql` | RLS para producción | 🟢 Futuro |

---

## 🆘 Troubleshooting Base de Datos

### "Could not find table 'usuarios'"

**Causa:** SQL no ejecutado en Supabase

**Solución:**
1. Ir a Supabase Dashboard
2. SQL Editor
3. Ejecutar `database/schema.sql`

---

### "Trigger recursivo"

**Causa:** RLS + trigger consultan misma tabla

**Solución:**
- Ejecutar `database/DISABLE_RLS_TEMPORAL.sql` (ya ejecutado)
- O implementar RLS correcto (producción)

---

### "Unique constraint violation"

**Causa:** Email duplicado

**Solución:**
- Usuarios tienen `Email UNIQUE`
- Verificar antes de insertar

---

## 📚 Siguiente Paso

**Lee `03_APP_FLUTTER.md`** para entender la estructura del código Flutter, servicios y pantallas.
