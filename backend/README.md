# EnglishPro Backend API

Backend REST API for EnglishPro - Educational English Learning Platform

## 🚀 Stack Tecnológico

- **Framework**: Shelf (Dart)
- **Database**: PostgreSQL 15+
- **Authentication**: Firebase Auth + JWT
- **ORM**: Native PostgreSQL Driver

---

## 📡 API Endpoints

### Base URL
```
http://localhost:8080
```

### Health Check
```http
GET /health
```
**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-10-07T17:44:14.264873"
}
```

---

## 📚 Courses Endpoints

### Get All Courses
```http
GET /api/courses
```
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
    },
    {
      "id": 2,
      "nombre": "IELTS",
      "descripcion": "Preparación para el International English Language Testing System",
      "tipo_curso": "Examen",
      "estilo_progreso": "Porcentaje",
      "url_imagen": null,
      "fecha_creacion": "2025-10-07T03:02:54.886631Z",
      "activo": true
    },
    {
      "id": 3,
      "nombre": "Business English",
      "descripcion": "Inglés corporativo y profesional estilo Rosetta Stone",
      "tipo_curso": "Inmersivo",
      "estilo_progreso": "Modular",
      "url_imagen": null,
      "fecha_creacion": "2025-10-07T03:02:54.886631Z",
      "activo": true
    }
  ],
  "count": 3
}
```

### Get Course by ID
```http
GET /api/courses/{id}
```

### Create Course
```http
POST /api/courses
Content-Type: application/json

{
  "nombre": "New Course",
  "descripcion": "Course description",
  "tipo_curso": "Examen",
  "estilo_progreso": "Porcentaje",
  "url_imagen": null,
  "activo": true
}
```

### Update Course
```http
PUT /api/courses/{id}
```

### Delete Course
```http
DELETE /api/courses/{id}
```

---

## 🎯 Skills Endpoints

### Get All Skills
```http
GET /api/skills
```

### Get Skills by Course ID
```http
GET /api/skills/course/{courseId}
```

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

### Get Skill by ID
```http
GET /api/skills/{id}
```

### Create Skill
```http
POST /api/skills
Content-Type: application/json

{
  "curso_id": 1,
  "nombre": "Reading",
  "descripcion": "Comprensión lectora",
  "orden": 1
}
```

### Update Skill
```http
PUT /api/skills/{id}
```

### Delete Skill
```http
DELETE /api/skills/{id}
```

---

## 📖 Materials Endpoints

### Get All Materials
```http
GET /api/materials
```
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
      "contenido_texto": "El TOEFL Reading consiste en 3-4 pasajes académicos...",
      "duracion_minutos": null,
      "orden": 1,
      "nivel_acceso": "Freemium",
      "fecha_creacion": "2025-10-07T22:13:51.596611Z",
      "creado_por": null
    }
  ],
  "count": 1
}
```

### Get Materials by Skill ID
```http
GET /api/materials/skill/{skillId}
```

### Get Material by ID
```http
GET /api/materials/{id}
```

### Create Material
```http
POST /api/materials
Content-Type: application/json

{
  "habilidad_id": 1,
  "titulo": "Introduction to TOEFL",
  "tipo_material": "Texto",
  "contenido_texto": "Content here...",
  "url_recurso": null,
  "duracion_minutos": null,
  "orden": 1,
  "nivel_acceso": "Freemium",
  "creado_por": null
}
```

### Update Material
```http
PUT /api/materials/{id}
```

### Delete Material
```http
DELETE /api/materials/{id}
```

---

## 🔐 Authentication Endpoints

```http
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh
```

---

## 🗄️ Database

### Connection
- Host: localhost
- Port: 5432
- Database: englishpro_db
- User: admin

### Tables
- Planes
- Usuarios
- Docentes
- Cursos
- Habilidades
- Materiales_Estudio
- Cuestionarios
- Preguntas
- And more... (16 tables total)

---

## 🚦 Running the Server

### Development
```bash
cd backend
dart run bin/server.dart
```

### With Docker
```bash
docker-compose up -d
```

---

## 📝 Environment Variables

Create a `.env` file in the backend directory:

```env
PORT=8080
DB_HOST=localhost
DB_PORT=5432
DB_NAME=englishpro_db
DB_USER=admin
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
```

---

## ✅ Status

- ✅ Health endpoint
- ✅ Courses CRUD
- ✅ Skills CRUD (100% functional)
- ✅ Materials CRUD
- ✅ Auth endpoints
- ✅ Database connection
- ✅ Error handling
- ✅ CORS enabled

---

## 🔜 Next Steps

- Add request validation
- Add authentication middleware
- Add rate limiting
- Add caching
- Add tests

---

## 📚 Documentation

For more details, see:
- `database/schema.sql` - Database schema
- `database/seed.sql` - Seed data
- `Agents.md` - Full project documentation
