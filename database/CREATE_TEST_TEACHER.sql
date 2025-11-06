-- ============================================
-- Script para crear un docente de prueba
-- ============================================
--
-- INSTRUCCIONES:
-- 1. Reemplaza 'TU_EMAIL_AQUI' con el email del usuario que quieres convertir en docente
-- 2. Ejecuta este script en el SQL Editor de Supabase
-- 3. El usuario podrá acceder al panel docente
--
-- ============================================

-- Paso 1: Buscar el ID del usuario por email
-- (Ejecuta esto primero para ver el id_usuario)
SELECT id_usuario, nombre_completo, email, es_docente, rol
FROM usuarios
WHERE email = 'TU_EMAIL_AQUI';

-- Paso 2: Actualizar el usuario para marcarlo como docente
-- (Reemplaza 'TU_EMAIL_AQUI' con tu email)
UPDATE usuarios
SET es_docente = TRUE,
    rol = 'Docente'
WHERE email = 'TU_EMAIL_AQUI';

-- Paso 3: Insertar registro en la tabla docentes
-- (Reemplaza 'TU_EMAIL_AQUI' con tu email)
INSERT INTO docentes (id_usuario, especialidad, certificaciones, anos_experiencia)
SELECT
    id_usuario,
    'Inglés General' as especialidad,
    'Certificación TESOL' as certificaciones,
    5 as anos_experiencia
FROM usuarios
WHERE email = 'TU_EMAIL_AQUI'
ON CONFLICT (id_usuario) DO NOTHING;

-- Paso 4: Verificar que se creó correctamente
SELECT
    d.id_docente,
    d.id_usuario,
    u.nombre_completo,
    u.email,
    d.especialidad,
    d.certificaciones,
    d.anos_experiencia,
    d.calificacion_promedio,
    d.total_retroalimentaciones
FROM docentes d
JOIN usuarios u ON d.id_usuario = u.id_usuario
WHERE u.email = 'TU_EMAIL_AQUI';

-- ============================================
-- Ejemplo de uso rápido:
-- ============================================
-- Si tu email es "profesor@example.com", ejecuta:
--
-- UPDATE usuarios SET es_docente = TRUE, rol = 'Docente' WHERE email = 'profesor@example.com';
--
-- INSERT INTO docentes (id_usuario, especialidad, certificaciones, anos_experiencia)
-- SELECT id_usuario, 'Inglés General', 'Certificación TESOL', 5
-- FROM usuarios WHERE email = 'profesor@example.com'
-- ON CONFLICT (id_usuario) DO NOTHING;
--
-- ============================================
