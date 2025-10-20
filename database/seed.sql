-- EnglishPro - Seed Data
-- Datos de prueba para desarrollo y testing
-- PostgreSQL 15+

-- ============================================
-- 1. PLANES
-- ============================================
INSERT INTO Planes (Nombre_Plan, Precio, Limite_Preguntas_Por_Habilidad, Acceso_Sesiones_Vivo, Cantidad_Sesiones_Vivo, Acceso_Simulacros, Cantidad_Simulacros, Descripcion)
VALUES
    ('Freemium', 0.00, 1, FALSE, 0, FALSE, 0, 'Plan gratuito con acceso limitado'),
    ('Básico', 9.99, 3, FALSE, 0, FALSE, 0, 'Plan básico con más preguntas'),
    ('Pro', 19.99, 5, FALSE, 0, FALSE, 0, 'Plan profesional con retroalimentación manual'),
    ('Premium', 39.99, 5, TRUE, 5, TRUE, 2, 'Plan premium con todos los beneficios')
ON CONFLICT (Nombre_Plan) DO NOTHING;

-- ============================================
-- 2. CURSOS
-- ============================================
INSERT INTO Cursos (Nombre_Curso, Descripcion, Tipo_Curso, Estilo_Progreso, URL_Imagen, Activo)
VALUES
    ('TOEFL', 'Test of English as a Foreign Language - Preparación completa para el examen oficial', 'Examen', 'Porcentaje', NULL, TRUE),
    ('IELTS', 'International English Language Testing System - Preparación académica y general', 'Examen', 'Porcentaje', NULL, TRUE),
    ('Business English', 'Inglés profesional para el mundo corporativo y de negocios', 'Inmersivo', 'Modular', NULL, TRUE),
    ('English in Action', 'Inglés práctico para situaciones cotidianas y viajes', 'Inmersivo', 'Modular', NULL, TRUE)
ON CONFLICT (Nombre_Curso) DO NOTHING;

-- ============================================
-- 3. HABILIDADES (Skills)
-- ============================================

-- Skills para TOEFL (ID_Curso = 1)
INSERT INTO Habilidades (ID_Curso, Nombre_Habilidad, Descripcion, Orden)
VALUES
    (1, 'Reading', 'Comprensión de lectura académica con pasajes largos', 1),
    (1, 'Listening', 'Comprensión auditiva de conferencias y conversaciones universitarias', 2),
    (1, 'Speaking', 'Expresión oral en contextos académicos', 3),
    (1, 'Writing', 'Escritura académica de ensayos y respuestas integradas', 4),

-- Skills para IELTS (ID_Curso = 2)
    (2, 'Reading', 'Comprensión de textos académicos y generales', 1),
    (2, 'Listening', 'Comprensión auditiva con diversos acentos británicos', 2),
    (2, 'Speaking', 'Entrevista oral con examiner sobre temas variados', 3),
    (2, 'Writing', 'Task 1 (descripción de gráficos) y Task 2 (ensayo argumentativo)', 4)
ON CONFLICT (ID_Curso, Nombre_Habilidad) DO NOTHING;

-- ============================================
-- 4. MATERIALES DE ESTUDIO
-- ============================================

-- Materiales para TOEFL Reading (ID_Habilidad = 1)
INSERT INTO Materiales_Estudio (ID_Habilidad, Titulo, Tipo_Material, Contenido_Texto, URL_Recurso, Orden, Nivel_Acceso)
VALUES
    (1, 'Introduction to TOEFL Reading', 'Texto',
     'El TOEFL Reading consiste en 3-4 pasajes académicos de aproximadamente 700 palabras cada uno. Tendrás 54-72 minutos para completar 30-40 preguntas...',
     NULL, 1, 'Freemium'),
    (1, 'Reading Strategies', 'PDF',
     NULL, 'assets/pdfs/hola_papus.pdf', 2, 'Freemium'),
    (1, 'Sample Reading Passage', 'Texto',
     'The Industrial Revolution marked a major turning point in human history. Beginning in Britain in the late 18th century...',
     NULL, 3, 'Freemium');

-- Materiales para TOEFL Listening (ID_Habilidad = 2)
INSERT INTO Materiales_Estudio (ID_Habilidad, Titulo, Tipo_Material, Contenido_Texto, URL_Recurso, Orden, Nivel_Acceso)
VALUES
    (2, 'Listening Practice 1', 'Audio',
     NULL, 'assets/audio/pato_donald.mp3', 1, 'Freemium'),
    (2, 'Note-Taking Tips', 'Texto',
     'Tomar notas es crucial en el TOEFL Listening. Usa abreviaciones, símbolos y organiza información jerárquicamente...',
     NULL, 2, 'Freemium');

-- ============================================
-- 5. USUARIOS DE PRUEBA
-- ============================================
INSERT INTO Usuarios (Nombre_Completo, Email, Password_Hash, Profesion, ID_Plan, Es_Docente, Firebase_UID, Email_Verificado)
VALUES
    ('Test Student', 'student@englishpro.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Estudiante', 1, FALSE, 'test_student_uid', TRUE),
    ('Test Teacher', 'teacher@englishpro.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Docente', 4, TRUE, 'test_teacher_uid', TRUE),
    ('Premium User', 'premium@englishpro.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Profesional', 4, FALSE, 'test_premium_uid', TRUE)
ON CONFLICT (Email) DO NOTHING;

-- ============================================
-- 6. PROGRESO DE PRUEBA
-- ============================================
INSERT INTO Progreso_Usuarios (ID_Usuario, ID_Curso, Avance_Porcentaje, Modulos_Completados, Ultima_Actividad)
VALUES
    (1, 1, 15.5, NULL, CURRENT_TIMESTAMP),
    (1, 3, NULL, 2, CURRENT_TIMESTAMP),
    (3, 1, 85.0, NULL, CURRENT_TIMESTAMP),
    (3, 2, 72.3, NULL, CURRENT_TIMESTAMP)
ON CONFLICT (ID_Usuario, ID_Curso) DO NOTHING;

-- ============================================
-- Verificación de datos insertados
-- ============================================
SELECT 'Planes insertados: ' || COUNT(*) FROM Planes;
SELECT 'Cursos insertados: ' || COUNT(*) FROM Cursos;
SELECT 'Habilidades insertadas: ' || COUNT(*) FROM Habilidades;
SELECT 'Materiales insertados: ' || COUNT(*) FROM Materiales_Estudio;
SELECT 'Usuarios insertados: ' || COUNT(*) FROM Usuarios;
SELECT 'Progreso insertado: ' || COUNT(*) FROM Progreso_Usuarios;
