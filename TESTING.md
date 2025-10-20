# EnglishPro - Testing Guide

## Endpoints Testing

Este documento contiene ejemplos de cómo probar todos los endpoints de la API de EnglishPro.

**Base URL:** `http://localhost:8080`

---

## 1. Authentication Endpoints

### 1.1 Register User
```bash
POST /api/auth/register
Content-Type: application/json

{
  "nombre_completo": "Juan Pérez",
  "email": "juan@example.com",
  "password": "password123",
  "profesion": "Ingeniero"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": { ... },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 1.2 Login User
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "juan@example.com",
  "password": "password123"
}
```

### 1.3 Get Current User
```bash
GET /api/auth/me
Authorization: Bearer <token>
```

---

## 2. Courses Endpoints

### 2.1 Get All Courses
```bash
GET /api/courses
```

### 2.2 Get Course by ID
```bash
GET /api/courses/1
```

### 2.3 Create Course (Admin)
```bash
POST /api/courses
Content-Type: application/json

{
  "nombre_curso": "Advanced TOEFL",
  "descripcion": "Advanced level TOEFL preparation",
  "tipo_curso": "Examen",
  "estilo_progreso": "Porcentaje"
}
```

---

## 3. Skills Endpoints

### 3.1 Get All Skills
```bash
GET /api/skills
```

### 3.2 Get Skills by Course
```bash
GET /api/skills/course/1
```

### 3.3 Get Skill by ID
```bash
GET /api/skills/1
```

---

## 4. Materials Endpoints

### 4.1 Get All Materials
```bash
GET /api/materials
```

### 4.2 Get Materials by Skill
```bash
GET /api/materials/skill/1
```

### 4.3 Get Material by ID
```bash
GET /api/materials/1
```

---

## 5. Questions Endpoints

### 5.1 Get Questions by Skill
```bash
GET /api/questions/skill/1
```

### 5.2 Get Question by ID
```bash
GET /api/questions/1
```

### 5.3 Submit Answer
```bash
POST /api/answers
Content-Type: application/json

{
  "usuario_id": 1,
  "pregunta_id": 1,
  "opcion_seleccionada_id": 2
}
```

---

## 6. Quizzes Endpoints

### 6.1 Get Quizzes by Skill
```bash
GET /api/quizzes/skill/1
```

### 6.2 Get Quiz by ID (with questions)
```bash
GET /api/quizzes/1
```

### 6.3 Create Quiz Attempt
```bash
POST /api/attempts
Content-Type: application/json

{
  "usuario_id": 1,
  "cuestionario_id": 1,
  "fecha_inicio": "2024-01-15T10:00:00Z",
  "estado": "En Progreso"
}
```

### 6.4 Update Quiz Attempt
```bash
PUT /api/attempts/1
Content-Type: application/json

{
  "fecha_fin": "2024-01-15T10:30:00Z",
  "puntos_obtenidos": 85,
  "porcentaje": 85.5,
  "estado": "Completado"
}
```

### 6.5 Get Best Attempt
```bash
GET /api/users/1/quizzes/1/best
```

---

## 7. Progress Endpoints

### 7.1 Get User Progress
```bash
GET /api/progress/user/1
```

### 7.2 Update Progress After Quiz
```bash
POST /api/progress/user/1/course/1/update
Content-Type: application/json

{
  "questionsAnswered": 10,
  "correctAnswers": 8,
  "pointsEarned": 80
}
```

---

## 8. Stats Endpoints

### 8.1 Get User Stats
```bash
GET /api/stats/user/1
```

---

## 9. Plan Validation Endpoints

### 9.1 Get User Plan Info
```bash
GET /api/plan-validation/user/1
```

### 9.2 Validate Quiz Limits
```bash
GET /api/plan-validation/user/1/validate-quiz
```

### 9.3 Validate Course Access
```bash
GET /api/plan-validation/user/1/course/1/access
```

### 9.4 Update User Plan
```bash
PUT /api/plan-validation/user/1/plan
Content-Type: application/json

{
  "plan": "Pro"
}
```

---

## 10. Payments Endpoints

### 10.1 Create Payment Intent
```bash
POST /api/payments/create-intent
Content-Type: application/json

{
  "usuario_id": 1,
  "plan_id": 3,
  "monto": 19.99
}
```

### 10.2 Confirm Payment
```bash
POST /api/payments/confirm/1
Content-Type: application/json

{
  "payment_intent_id": "pi_mock_123456"
}
```

### 10.3 Get Payment by ID
```bash
GET /api/payments/1
```

### 10.4 Get User Payments
```bash
GET /api/payments/user/1
```

### 10.5 Get User Subscriptions
```bash
GET /api/payments/subscriptions/user/1
```

### 10.6 Get Active Subscription
```bash
GET /api/payments/subscriptions/user/1/active
```

### 10.7 Cancel Subscription
```bash
POST /api/payments/subscriptions/1/cancel
```

---

## 11. Feedback Endpoints

### 11.1 Create Feedback
```bash
POST /api/feedback
Content-Type: application/json

{
  "usuario_id": 1,
  "pregunta_id": 5,
  "tipo_respuesta": "Writing",
  "respuesta_texto": "My essay response here...",
  "estado": "Pendiente"
}
```

### 11.2 Get Feedback by ID
```bash
GET /api/feedback/1
```

### 11.3 Get Feedbacks by User
```bash
GET /api/feedback/user/1
```

### 11.4 Get Pending Feedbacks
```bash
GET /api/feedback/pending/all
```

### 11.5 Get Feedbacks by Teacher
```bash
GET /api/feedback/teacher/1
```

### 11.6 Grade Feedback
```bash
POST /api/feedback/1/grade
Content-Type: application/json

{
  "teacher_id": 1,
  "puntuacion": 85.5,
  "comentarios": "Excelente trabajo, pero puedes mejorar la gramática."
}
```

### 11.7 Get User Feedback Stats
```bash
GET /api/feedback/user/1/stats
```

---

## 12. Teachers Endpoints

### 12.1 Create Teacher
```bash
POST /api/teachers
Content-Type: application/json

{
  "usuario_id": 2,
  "especialidad": "TOEFL Preparation",
  "certificaciones": "TESOL, CELTA",
  "anios_experiencia": 5,
  "activo": true
}
```

### 12.2 Get Teacher by ID
```bash
GET /api/teachers/1
```

### 12.3 Get Teacher by User ID
```bash
GET /api/teachers/user/2
```

### 12.4 Get All Teachers
```bash
GET /api/teachers
```

### 12.5 Get Active Teachers Only
```bash
GET /api/teachers?activo=true
```

### 12.6 Get Teacher Stats
```bash
GET /api/teachers/1/stats
```

### 12.7 Update Teacher
```bash
PUT /api/teachers/1
Content-Type: application/json

{
  "especialidad": "IELTS and TOEFL Preparation",
  "anios_experiencia": 6
}
```

### 12.8 Deactivate Teacher
```bash
POST /api/teachers/1/deactivate
```

### 12.9 Activate Teacher
```bash
POST /api/teachers/1/activate
```

---

## 13. Notifications Endpoints

### 13.1 Create Notification
```bash
POST /api/notifications
Content-Type: application/json

{
  "id_usuario": 1,
  "titulo": "Nueva retroalimentación disponible",
  "mensaje": "Tu ensayo ha sido calificado por un docente",
  "tipo": "Retroalimentacion"
}
```

### 13.2 Get All Notifications for User
```bash
GET /api/notifications/1
```

### 13.3 Get Unread Notifications
```bash
GET /api/notifications/1/unread
```

### 13.4 Get Notification Count
```bash
GET /api/notifications/1/count
```

### 13.5 Mark Notification as Read
```bash
PUT /api/notifications/1/read
```

### 13.6 Mark All Notifications as Read
```bash
PUT /api/notifications/1/read-all
```

### 13.7 Delete Notification
```bash
DELETE /api/notifications/1
```

---

## Testing Workflow

### 1. Setup
```bash
# Start PostgreSQL
docker start englishpro_db

# Start Backend
cd backend && dart run bin/server.dart
```

### 2. Run Tests

#### Flutter Unit Tests
```bash
cd app
flutter test
```

#### Flutter Integration Tests
```bash
cd app
flutter test integration_test/app_test.dart
```

### 3. Manual Testing Checklist

- [ ] User can register successfully
- [ ] User can login successfully
- [ ] User can view courses
- [ ] User can take a quiz
- [ ] User can submit answers
- [ ] User can view progress dashboard
- [ ] User can upgrade plan
- [ ] User can make payment (mock)
- [ ] Teacher can view pending feedbacks
- [ ] Teacher can grade student responses
- [ ] User receives notifications
- [ ] User can mark notifications as read
- [ ] Navigation between screens works
- [ ] Back button works correctly
- [ ] Form validations work properly

### 4. Common Issues

#### Issue: Database connection failed
**Solution:** Make sure PostgreSQL container is running: `docker start englishpro_db`

#### Issue: 401 Unauthorized
**Solution:** Make sure you're sending the JWT token in the Authorization header

#### Issue: 404 Not Found
**Solution:** Verify the endpoint URL is correct and the resource exists

---

## Test Data

### Sample Users
- Email: `juan@example.com`, Password: `password123` (Estudiante)
- Email: `maria@example.com`, Password: `password123` (Docente)

### Sample Quiz IDs
- TOEFL Writing: 1
- IELTS Speaking: 2
- Business English Reading: 3

### Sample Course IDs
- TOEFL: 1
- IELTS: 2
- Business English: 3
- English in Action: 4
