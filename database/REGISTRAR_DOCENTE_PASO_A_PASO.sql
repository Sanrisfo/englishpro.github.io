-- ============================================
-- REGISTRAR DOCENTE - PASO A PASO
-- ============================================
-- Sigue estos pasos en orden para registrarte como docente
-- ============================================

-- PASO 1: Ver todos los usuarios registrados
-- Ejecuta esto primero para identificar tu usuario
-- ============================================
SELECT
    id_usuario,
    nombre_completo,
    email,
    es_docente,
    rol,
    fecha_registro
FROM usuarios
ORDER BY fecha_registro DESC
LIMIT 10;

-- ============================================
-- PASO 2: Buscar tu usuario específico por email
-- Reemplaza 'TU_EMAIL@EJEMPLO.COM' con tu email real
-- ============================================
SELECT
    id_usuario,
    nombre_completo,
    email,
    es_docente,
    rol
FROM usuarios
WHERE email = 'TU_EMAIL@EJEMPLO.COM';

-- Si no aparece nada, verifica el email o busca por nombre:
-- SELECT * FROM usuarios WHERE nombre_completo ILIKE '%tu_nombre%';

-- ============================================
-- PASO 3: Ver los docentes actuales
-- Para verificar si ya estás registrado
-- ============================================
SELECT
    d.id_docente,
    d.id_usuario,
    u.nombre_completo,
    u.email,
    d.especialidad
FROM docentes d
JOIN usuarios u ON d.id_usuario = u.id_usuario;

-- ============================================
-- PASO 4: Registrar como docente
-- Reemplaza 'TU_EMAIL@EJEMPLO.COM' con tu email
-- ============================================

-- 4a. Marcar usuario como docente
UPDATE usuarios
SET
    es_docente = TRUE,
    rol = 'Docente'
WHERE email = 'TU_EMAIL@EJEMPLO.COM';

-- 4b. Crear perfil de docente
INSERT INTO docentes (id_usuario, especialidad, certificaciones, anos_experiencia)
SELECT
    id_usuario,
    'Inglés General' as especialidad,
    'Certificación TESOL' as certificaciones,
    5 as anos_experiencia
FROM usuarios
WHERE email = 'TU_EMAIL@EJEMPLO.COM'
ON CONFLICT (id_usuario) DO UPDATE SET
    especialidad = EXCLUDED.especialidad,
    certificaciones = EXCLUDED.certificaciones,
    anos_experiencia = EXCLUDED.anos_experiencia;

-- ============================================
-- PASO 5: Verificar que se creó correctamente
-- Reemplaza 'TU_EMAIL@EJEMPLO.COM' con tu email
-- ============================================
SELECT
    u.id_usuario,
    u.nombre_completo,
    u.email,
    u.es_docente,
    u.rol,
    d.id_docente,
    d.especialidad,
    d.certificaciones,
    d.anos_experiencia,
    d.calificacion_promedio,
    d.total_retroalimentaciones
FROM usuarios u
LEFT JOIN docentes d ON u.id_usuario = d.id_usuario
WHERE u.email = 'TU_EMAIL@EJEMPLO.COM';

-- ============================================
-- EJEMPLO COMPLETO
-- ============================================
-- Si tu email es "profesor@gmail.com", ejecuta:
/*

-- Ver tu usuario
SELECT id_usuario, nombre_completo, email, es_docente, rol
FROM usuarios
WHERE email = 'profesor@gmail.com';

-- Marcar como docente
UPDATE usuarios
SET es_docente = TRUE, rol = 'Docente'
WHERE email = 'profesor@gmail.com';

-- Crear perfil docente
INSERT INTO docentes (id_usuario, especialidad, certificaciones, anos_experiencia)
SELECT id_usuario, 'Inglés General', 'Certificación TESOL', 5
FROM usuarios
WHERE email = 'profesor@gmail.com'
ON CONFLICT (id_usuario) DO UPDATE SET
    especialidad = EXCLUDED.especialidad,
    certificaciones = EXCLUDED.certificaciones,
    anos_experiencia = EXCLUDED.anos_experiencia;

-- Verificar
SELECT u.*, d.*
FROM usuarios u
LEFT JOIN docentes d ON u.id_usuario = d.id_usuario
WHERE u.email = 'profesor@gmail.com';

*/

-- ============================================
-- TROUBLESHOOTING
-- ============================================

-- Si el INSERT falla por "duplicate key", significa que ya existe
-- Puedes actualizar el registro existente:
/*
UPDATE docentes
SET
    especialidad = 'Inglés General',
    certificaciones = 'Certificación TESOL',
    anos_experiencia = 5
WHERE id_usuario = (SELECT id_usuario FROM usuarios WHERE email = 'TU_EMAIL@EJEMPLO.COM');
*/

-- Si aparece "no rows updated", verifica que el email esté correcto:
/*
SELECT email FROM usuarios ORDER BY fecha_registro DESC LIMIT 10;
*/
