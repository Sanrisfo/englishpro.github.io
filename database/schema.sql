-- EnglishPro Database Schema
-- PostgreSQL 15+
-- Total: 16 tablas

-- ============================================
-- 1. TABLA: Planes
-- ============================================
CREATE TABLE IF NOT EXISTS Planes (
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

-- ============================================
-- 2. TABLA: Usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS Usuarios (
    ID_Usuario SERIAL PRIMARY KEY,
    Nombre_Completo VARCHAR(150) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Password_Hash VARCHAR(255) NOT NULL,
    Profesion VARCHAR(100),
    ID_Plan INT NOT NULL DEFAULT 1,
    Es_Docente BOOLEAN DEFAULT FALSE,
    Rol VARCHAR(50) NOT NULL DEFAULT 'Estudiante' CHECK (Rol IN ('Estudiante', 'Docente', 'Admin')),
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Ultimo_Acceso TIMESTAMP,
    Firebase_UID VARCHAR(128) UNIQUE,
    Email_Verificado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_Plan) REFERENCES Planes(ID_Plan) ON DELETE SET DEFAULT
);

-- ============================================
-- 3. TABLA: Docentes
-- ============================================
CREATE TABLE IF NOT EXISTS Docentes (
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

-- ============================================
-- 4. TABLA: Cursos
-- ============================================
CREATE TABLE IF NOT EXISTS Cursos (
    ID_Curso SERIAL PRIMARY KEY,
    Nombre_Curso VARCHAR(100) NOT NULL UNIQUE,
    Descripcion TEXT,
    Tipo_Curso VARCHAR(50) NOT NULL CHECK (Tipo_Curso IN ('Examen', 'Inmersivo')),
    Estilo_Progreso VARCHAR(50) NOT NULL CHECK (Estilo_Progreso IN ('Porcentaje', 'Modular')),
    URL_Imagen VARCHAR(500),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Activo BOOLEAN DEFAULT TRUE
);

-- ============================================
-- 5. TABLA: Habilidades
-- ============================================
CREATE TABLE IF NOT EXISTS Habilidades (
    ID_Habilidad SERIAL PRIMARY KEY,
    ID_Curso INT NOT NULL,
    Nombre_Habilidad VARCHAR(50) NOT NULL CHECK (Nombre_Habilidad IN ('Writing', 'Speaking', 'Listening', 'Reading')),
    Descripcion TEXT,
    Orden INT DEFAULT 1,
    FOREIGN KEY (ID_Curso) REFERENCES Cursos(ID_Curso) ON DELETE CASCADE,
    UNIQUE (ID_Curso, Nombre_Habilidad)
);

-- ============================================
-- 6. TABLA: Materiales_Estudio
-- ============================================
CREATE TABLE IF NOT EXISTS Materiales_Estudio (
    ID_Material SERIAL PRIMARY KEY,
    ID_Habilidad INT NOT NULL,
    Titulo VARCHAR(200) NOT NULL,
    Tipo_Material VARCHAR(50) NOT NULL CHECK (Tipo_Material IN ('PDF', 'Video', 'Audio', 'Texto', 'Imagen')),
    URL_Recurso VARCHAR(500),
    Contenido_Texto TEXT,
    Duracion_Minutos INT,
    Orden INT DEFAULT 1,
    Nivel_Acceso VARCHAR(50) DEFAULT 'Freemium' CHECK (Nivel_Acceso IN ('Freemium', 'Basico', 'Pro', 'Premium')),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Creado_Por INT,
    FOREIGN KEY (ID_Habilidad) REFERENCES Habilidades(ID_Habilidad) ON DELETE CASCADE,
    FOREIGN KEY (Creado_Por) REFERENCES Docentes(ID_Docente) ON DELETE SET NULL
);

-- ============================================
-- 7. TABLA: Cuestionarios
-- ============================================
CREATE TABLE IF NOT EXISTS Cuestionarios (
    ID_Cuestionario SERIAL PRIMARY KEY,
    ID_Habilidad INT NOT NULL,
    Titulo VARCHAR(200) NOT NULL,
    Descripcion TEXT,
    Tiempo_Limite_Minutos INT,
    Nivel_Dificultad VARCHAR(50) CHECK (Nivel_Dificultad IN ('Basico', 'Intermedio', 'Avanzado')),
    Tipo_Evaluacion VARCHAR(50) CHECK (Tipo_Evaluacion IN ('Practica', 'Simulacro', 'Examen')),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Creado_Por INT,
    Activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ID_Habilidad) REFERENCES Habilidades(ID_Habilidad) ON DELETE CASCADE,
    FOREIGN KEY (Creado_Por) REFERENCES Docentes(ID_Docente) ON DELETE SET NULL
);

-- ============================================
-- 8. TABLA: Preguntas
-- ============================================
CREATE TABLE IF NOT EXISTS Preguntas (
    ID_Pregunta SERIAL PRIMARY KEY,
    ID_Habilidad INT NOT NULL,
    Texto_Pregunta TEXT NOT NULL,
    Tipo_Pregunta VARCHAR(50) NOT NULL CHECK (Tipo_Pregunta IN ('Multiple Choice', 'Texto Abierto', 'Audio Grabacion')),
    URL_Audio VARCHAR(500),
    URL_Video VARCHAR(500),
    URL_Imagen VARCHAR(500),
    Puntos INT DEFAULT 1,
    Nivel_Dificultad VARCHAR(50) CHECK (Nivel_Dificultad IN ('Basico', 'Intermedio', 'Avanzado')),
    Nivel_Acceso VARCHAR(50) DEFAULT 'Freemium' CHECK (Nivel_Acceso IN ('Freemium', 'Basico', 'Pro', 'Premium')),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Creado_Por INT,
    FOREIGN KEY (ID_Habilidad) REFERENCES Habilidades(ID_Habilidad) ON DELETE CASCADE,
    FOREIGN KEY (Creado_Por) REFERENCES Docentes(ID_Docente) ON DELETE SET NULL
);

-- ============================================
-- 9. TABLA: Cuestionario_Preguntas
-- ============================================
CREATE TABLE IF NOT EXISTS Cuestionario_Preguntas (
    ID_Cuestionario INT NOT NULL,
    ID_Pregunta INT NOT NULL,
    Orden INT DEFAULT 1,
    PRIMARY KEY (ID_Cuestionario, ID_Pregunta),
    FOREIGN KEY (ID_Cuestionario) REFERENCES Cuestionarios(ID_Cuestionario) ON DELETE CASCADE,
    FOREIGN KEY (ID_Pregunta) REFERENCES Preguntas(ID_Pregunta) ON DELETE CASCADE
);

-- ============================================
-- 10. TABLA: Opciones_Respuesta
-- ============================================
CREATE TABLE IF NOT EXISTS Opciones_Respuesta (
    ID_Opcion SERIAL PRIMARY KEY,
    ID_Pregunta INT NOT NULL,
    Texto_Opcion TEXT NOT NULL,
    Es_Correcta BOOLEAN DEFAULT FALSE,
    Orden INT DEFAULT 1,
    FOREIGN KEY (ID_Pregunta) REFERENCES Preguntas(ID_Pregunta) ON DELETE CASCADE
);

-- ============================================
-- 11. TABLA: Respuestas_Usuario
-- ============================================
CREATE TABLE IF NOT EXISTS Respuestas_Usuario (
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

-- ============================================
-- 12. TABLA: Retroalimentacion_Docente
-- ============================================
CREATE TABLE IF NOT EXISTS Retroalimentacion_Docente (
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

-- ============================================
-- 13. TABLA: Progreso_Usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS Progreso_Usuarios (
    ID_Progreso SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    ID_Curso INT NOT NULL,
    Avance_Porcentaje DECIMAL(5, 2) DEFAULT 0.00 CHECK (Avance_Porcentaje >= 0 AND Avance_Porcentaje <= 100),
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

-- ============================================
-- 14. TABLA: Pagos
-- ============================================
CREATE TABLE IF NOT EXISTS Pagos (
    ID_Pago SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    ID_Plan INT NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    Metodo_Pago VARCHAR(50) NOT NULL,
    Estado_Pago VARCHAR(50) NOT NULL CHECK (Estado_Pago IN ('Pendiente', 'Completado', 'Fallido', 'Reembolsado')),
    ID_Transaccion_Stripe VARCHAR(255) UNIQUE,
    Fecha_Pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Fecha_Inicio_Vigencia TIMESTAMP,
    Fecha_Fin_Vigencia TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE,
    FOREIGN KEY (ID_Plan) REFERENCES Planes(ID_Plan) ON DELETE SET NULL
);

-- ============================================
-- 15. TABLA: Beneficios_Usuario
-- ============================================
CREATE TABLE IF NOT EXISTS Beneficios_Usuario (
    ID_Beneficio SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    Sesiones_Vivo_Restantes INT DEFAULT 0,
    Simulacros_Restantes INT DEFAULT 0,
    Fecha_Actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE,
    UNIQUE (ID_Usuario)
);

-- ============================================
-- 16. TABLA: Notificaciones
-- ============================================
CREATE TABLE IF NOT EXISTS Notificaciones (
    ID_Notificacion SERIAL PRIMARY KEY,
    ID_Usuario INT NOT NULL,
    Titulo VARCHAR(200) NOT NULL,
    Mensaje TEXT NOT NULL,
    Tipo VARCHAR(50) CHECK (Tipo IN ('Info', 'Retroalimentacion', 'Pago', 'Sistema')),
    Leida BOOLEAN DEFAULT FALSE,
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE
);

-- ============================================
-- INDICES para optimización
-- ============================================
CREATE INDEX idx_usuarios_email ON Usuarios(Email);
CREATE INDEX idx_usuarios_firebase_uid ON Usuarios(Firebase_UID);
CREATE INDEX idx_respuestas_usuario ON Respuestas_Usuario(ID_Usuario, ID_Pregunta);
CREATE INDEX idx_progreso_usuario_curso ON Progreso_Usuarios(ID_Usuario, ID_Curso);
CREATE INDEX idx_pagos_usuario ON Pagos(ID_Usuario);
CREATE INDEX idx_notificaciones_usuario ON Notificaciones(ID_Usuario, Leida);
CREATE INDEX idx_materiales_habilidad ON Materiales_Estudio(ID_Habilidad);
CREATE INDEX idx_preguntas_habilidad ON Preguntas(ID_Habilidad);

-- ============================================
-- DATOS INICIALES: Planes
-- ============================================
INSERT INTO Planes (Nombre_Plan, Precio, Limite_Preguntas_Por_Habilidad, Acceso_Sesiones_Vivo, Cantidad_Sesiones_Vivo, Acceso_Simulacros, Cantidad_Simulacros, Descripcion)
VALUES
    ('Freemium', 0.00, 1, FALSE, 0, FALSE, 0, 'Plan gratuito con acceso limitado'),
    ('Basico', 9.99, 3, FALSE, 0, FALSE, 0, 'Plan básico con más preguntas'),
    ('Pro', 19.99, 5, FALSE, 0, FALSE, 0, 'Plan profesional con retroalimentación docente'),
    ('Premium', 39.99, 5, TRUE, 5, TRUE, 2, 'Plan premium con sesiones en vivo y simulacros');

-- ============================================
-- DATOS INICIALES: Cursos
-- ============================================
INSERT INTO Cursos (Nombre_Curso, Descripcion, Tipo_Curso, Estilo_Progreso)
VALUES
    ('TOEFL', 'Preparación para el Test of English as a Foreign Language', 'Examen', 'Porcentaje'),
    ('IELTS', 'Preparación para el International English Language Testing System', 'Examen', 'Porcentaje'),
    ('Business English', 'Inglés corporativo y profesional estilo Rosetta Stone', 'Inmersivo', 'Modular'),
    ('English in Action', 'Inglés para situaciones cotidianas estilo Rosetta Stone', 'Inmersivo', 'Modular');

-- ============================================
-- DATOS INICIALES: Habilidades (4 por curso)
-- ============================================
INSERT INTO Habilidades (ID_Curso, Nombre_Habilidad, Descripcion, Orden)
VALUES
    -- TOEFL
    (1, 'Writing', 'Escritura académica para TOEFL', 1),
    (1, 'Speaking', 'Expresión oral para TOEFL', 2),
    (1, 'Listening', 'Comprensión auditiva para TOEFL', 3),
    (1, 'Reading', 'Comprensión lectora para TOEFL', 4),
    -- IELTS
    (2, 'Writing', 'Escritura académica para IELTS', 1),
    (2, 'Speaking', 'Expresión oral para IELTS', 2),
    (2, 'Listening', 'Comprensión auditiva para IELTS', 3),
    (2, 'Reading', 'Comprensión lectora para IELTS', 4),
    -- Business English
    (3, 'Writing', 'Redacción de emails y documentos corporativos', 1),
    (3, 'Speaking', 'Presentaciones y reuniones de negocios', 2),
    (3, 'Listening', 'Comprensión en contextos profesionales', 3),
    (3, 'Reading', 'Lectura de documentos de negocios', 4),
    -- English in Action
    (4, 'Writing', 'Escritura práctica para el día a día', 1),
    (4, 'Speaking', 'Conversación en situaciones cotidianas', 2),
    (4, 'Listening', 'Comprensión en contextos reales', 3),
    (4, 'Reading', 'Lectura de materiales cotidianos', 4);
