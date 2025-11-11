# Migración Supabase – Normalización de Cursos + RLS y Índices

Este documento reúne los pasos y SQL para:
- Normalizar claves de `cursos` y referencias en tablas relacionadas
- Alinear nombres de columnas con el código (`id` y `curso_id`)
- Agregar índices útiles
- Configurar RLS mínima para producción (con notas para desarrollo)

Sigue el orden. Todos los objetos están en minúsculas (schema `public`).

---

## 1) Pre‑checks (ver tu esquema actual)

Ejecuta estas consultas para confirmar tu estado actual.

```sql
-- Columnas actuales
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'cursos';

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'habilidades';

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'progreso_usuarios';

-- FKs que referencian cursos
SELECT tc.table_name, kcu.column_name, ccu.table_name AS ref_table, ccu.column_name AS ref_column, tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' AND ccu.table_name = 'cursos';

-- Políticas que puedan referenciar cursos.id_curso
SELECT tablename, policyname, qual, with_check
FROM pg_policies
WHERE tablename IN ('cursos','habilidades','progreso_usuarios');
```

---

## 2) Migración – Normalizar claves de Cursos

Objetivo:
- `cursos.id_curso` → `cursos.id` (PK)
- `habilidades.id_curso` → `habilidades.curso_id` (FK a `cursos.id`)
- `progreso_usuarios.id_curso` → `progreso_usuarios.curso_id` (FK a `cursos.id`)

Ejecuta el bloque completo:

```sql
BEGIN;

-- 1) cursos: renombrar PK id_curso -> id
ALTER TABLE public.cursos
  RENAME COLUMN id_curso TO id;

-- 2) habilidades: renombrar FK id_curso -> curso_id
ALTER TABLE public.habilidades
  RENAME COLUMN id_curso TO curso_id;

-- 2.1) Drop/recreate FK habilidades.curso_id -> cursos.id
DO $$
DECLARE
  fk_name text;
BEGIN
  SELECT conname INTO fk_name
  FROM pg_constraint
  WHERE conrelid = 'public.habilidades'::regclass
    AND confrelid = 'public.cursos'::regclass
    AND contype = 'f';

  IF fk_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.habilidades DROP CONSTRAINT %I', fk_name);
  END IF;

  EXECUTE $fku$
    ALTER TABLE public.habilidades
    ADD CONSTRAINT habilidades_curso_id_fkey
    FOREIGN KEY (curso_id) REFERENCES public.cursos(id) ON DELETE CASCADE
  $fku$;
END$$;

CREATE INDEX IF NOT EXISTS habilidades_curso_id_idx ON public.habilidades(curso_id);

-- 3) progreso_usuarios: renombrar FK id_curso -> curso_id
ALTER TABLE public.progreso_usuarios
  RENAME COLUMN id_curso TO curso_id;

-- 3.1) Drop/recreate FK progreso_usuarios.curso_id -> cursos.id
DO $$
DECLARE
  fk_name text;
BEGIN
  SELECT conname INTO fk_name
  FROM pg_constraint
  WHERE conrelid = 'public.progreso_usuarios'::regclass
    AND confrelid = 'public.cursos'::regclass
    AND contype = 'f';

  IF fk_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.progreso_usuarios DROP CONSTRAINT %I', fk_name);
  END IF;

  EXECUTE $fku$
    ALTER TABLE public.progreso_usuarios
    ADD CONSTRAINT progreso_usuarios_curso_id_fkey
    FOREIGN KEY (curso_id) REFERENCES public.cursos(id) ON DELETE CASCADE
  $fku$;
END$$;

CREATE INDEX IF NOT EXISTS progreso_curso_id_idx ON public.progreso_usuarios(curso_id);

COMMIT;
```

Validación:

```sql
-- Confirma columnas renombradas
SELECT column_name FROM information_schema.columns WHERE table_name='cursos';
SELECT column_name FROM information_schema.columns WHERE table_name='habilidades';
SELECT column_name FROM information_schema.columns WHERE table_name='progreso_usuarios';

-- Confirma FKs activos a cursos(id)
SELECT tc.table_name, kcu.column_name, ccu.table_name AS ref_table, ccu.column_name AS ref_column, tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type='FOREIGN KEY' AND tc.table_name IN ('habilidades','progreso_usuarios');
```

---

## 3) Índices recomendados

```sql
BEGIN;

CREATE INDEX IF NOT EXISTS respuestas_usuario_id_usuario_idx ON public.respuestas_usuario(id_usuario);
CREATE INDEX IF NOT EXISTS respuestas_usuario_id_pregunta_idx ON public.respuestas_usuario(id_pregunta);
CREATE INDEX IF NOT EXISTS cuestionario_preguntas_id_cuestionario_idx ON public.cuestionario_preguntas(id_cuestionario);
CREATE INDEX IF NOT EXISTS cuestionario_preguntas_id_pregunta_idx ON public.cuestionario_preguntas(id_pregunta);
CREATE INDEX IF NOT EXISTS opciones_respuesta_id_pregunta_idx ON public.opciones_respuesta(id_pregunta);
CREATE INDEX IF NOT EXISTS retroalimentacion_docente_id_respuesta_idx ON public.retroalimentacion_docente(id_respuesta);
CREATE INDEX IF NOT EXISTS retroalimentacion_docente_id_docente_idx ON public.retroalimentacion_docente(id_docente);
CREATE UNIQUE INDEX IF NOT EXISTS beneficios_usuario_id_usuario_idx ON public.beneficios_usuario(id_usuario);

COMMIT;
```

---

## 4) RLS mínima (producción) y atajos (desarrollo)

### 4.1 Producción – RLS para Preguntas y Tablas Relacionadas

Supuestos:
- `usuarios.supabase_uid` mapea a `auth.uid()`
- `docentes.id_usuario` → `usuarios.id_usuario`
- `preguntas.creado_por` almacena `docentes.id_docente`

```sql
BEGIN;

-- Vista helper para mapear usuario autenticado → docente actual
CREATE OR REPLACE VIEW public.v_docente_actual AS
SELECT d.id_docente
FROM public.usuarios u
JOIN public.docentes d ON d.id_usuario = u.id_usuario
WHERE u.supabase_uid = auth.uid();

-- PREGUNTAS
ALTER TABLE public.preguntas ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS preguntas_select_own ON public.preguntas;
DROP POLICY IF EXISTS preguntas_insert_own ON public.preguntas;
DROP POLICY IF EXISTS preguntas_update_own ON public.preguntas;
DROP POLICY IF EXISTS preguntas_delete_own ON public.preguntas;

CREATE POLICY preguntas_select_own ON public.preguntas
FOR SELECT USING (
  creado_por IS NULL OR creado_por IN (SELECT id_docente FROM public.v_docente_actual)
);

CREATE POLICY preguntas_insert_own ON public.preguntas
FOR INSERT WITH CHECK (
  creado_por IN (SELECT id_docente FROM public.v_docente_actual)
);

CREATE POLICY preguntas_update_own ON public.preguntas
FOR UPDATE USING (
  creado_por IN (SELECT id_docente FROM public.v_docente_actual)
);

CREATE POLICY preguntas_delete_own ON public.preguntas
FOR DELETE USING (
  creado_por IN (SELECT id_docente FROM public.v_docente_actual)
);

-- OPCIONES_RESPUESTA
ALTER TABLE public.opciones_respuesta ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS opciones_resp_rw ON public.opciones_respuesta;

CREATE POLICY opciones_resp_rw ON public.opciones_respuesta
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.preguntas q
    WHERE q.id_pregunta = opciones_respuesta.id_pregunta
      AND q.creado_por IN (SELECT id_docente FROM public.v_docente_actual)
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.preguntas q
    WHERE q.id_pregunta = opciones_respuesta.id_pregunta
      AND q.creado_por IN (SELECT id_docente FROM public.v_docente_actual)
  )
);

-- CUESTIONARIO_PREGUNTAS
ALTER TABLE public.cuestionario_preguntas ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS cuespreg_rw ON public.cuestionario_preguntas;

CREATE POLICY cuespreg_rw ON public.cuestionario_preguntas
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.preguntas q
    WHERE q.id_pregunta = cuestionario_preguntas.id_pregunta
      AND q.creado_por IN (SELECT id_docente FROM public.v_docente_actual)
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.preguntas q
    WHERE q.id_pregunta = cuestionario_preguntas.id_pregunta
      AND q.creado_por IN (SELECT id_docente FROM public.v_docente_actual)
  )
);

COMMIT;
```

### 4.2 Producción – RLS para Respuestas, Retro y Beneficios

```sql
BEGIN;

-- BENEFICIOS (ver propios)
ALTER TABLE public.beneficios_usuario ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS beneficios_select_own ON public.beneficios_usuario;
CREATE POLICY beneficios_select_own ON public.beneficios_usuario
FOR SELECT USING (
  id_usuario IN (SELECT id_usuario FROM public.usuarios WHERE supabase_uid = auth.uid())
);

-- RESPUESTAS USUARIO (ver/insertar propias)
ALTER TABLE public.respuestas_usuario ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS respuestas_select_own ON public.respuestas_usuario;
DROP POLICY IF EXISTS respuestas_insert_own ON public.respuestas_usuario;

CREATE POLICY respuestas_select_own ON public.respuestas_usuario
FOR SELECT USING (
  id_usuario IN (SELECT id_usuario FROM public.usuarios WHERE supabase_uid = auth.uid())
);

CREATE POLICY respuestas_insert_own ON public.respuestas_usuario
FOR INSERT WITH CHECK (
  id_usuario IN (SELECT id_usuario FROM public.usuarios WHERE supabase_uid = auth.uid())
);

-- RETROALIMENTACION DOCENTE (docente ve/crea propia; alumno ve la suya)
ALTER TABLE public.retroalimentacion_docente ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS retro_select_docente ON public.retroalimentacion_docente;
DROP POLICY IF EXISTS retro_insert_docente ON public.retroalimentacion_docente;
DROP POLICY IF EXISTS retro_select_alumno ON public.retroalimentacion_docente;

CREATE POLICY retro_select_docente ON public.retroalimentacion_docente
FOR SELECT USING (
  id_docente IN (
    SELECT d.id_docente FROM public.docentes d
    JOIN public.usuarios u ON u.id_usuario = d.id_usuario
    WHERE u.supabase_uid = auth.uid()
  )
);

CREATE POLICY retro_insert_docente ON public.retroalimentacion_docente
FOR INSERT WITH CHECK (
  id_docente IN (
    SELECT d.id_docente FROM public.docentes d
    JOIN public.usuarios u ON u.id_usuario = d.id_usuario
    WHERE u.supabase_uid = auth.uid()
  )
);

CREATE POLICY retro_select_alumno ON public.retroalimentacion_docente
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.respuestas_usuario r
    JOIN public.usuarios u ON u.id_usuario = r.id_usuario
    WHERE r.id_respuesta = retroalimentacion_docente.id_respuesta
      AND u.supabase_uid = auth.uid()
  )
);

COMMIT;
```

### 4.3 Desarrollo – Atajo (si RLS bloquea flujos)

Puedes deshabilitar temporalmente RLS en estas tablas mientras desarrollas:

```sql
ALTER TABLE public.preguntas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.opciones_respuesta DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cuestionario_preguntas DISABLE ROW LEVEL SECURITY;
```

---

## 5) Post‑checks

1. Verifica IELTS en la app (ya apunta a Supabase y usa `id` para cursos).
2. Verifica que `teacher_courses_screen` muestra cursos (ahora lee `id`).
3. Verifica que `teacher_skills_screen` filtra por `curso_id`.
4. Si la pantalla IELTS no encuentra el curso, confirma que `cursos` tiene una fila con `nombre_curso = 'IELTS'`.

SQL útil:

```sql
SELECT id, nombre_curso FROM public.cursos WHERE LOWER(nombre_curso) = 'ielts';
SELECT id_habilidad, nombre_habilidad, curso_id FROM public.habilidades WHERE curso_id = (SELECT id FROM public.cursos WHERE LOWER(nombre_curso) = 'ielts');
```

---

## 6) Notas finales

- El app ya quedó alineado con `cursos.id` y `habilidades.curso_id`.
- Si tienes más pantallas que lean `cursos` por HTTP (API_URL), conviene migrarlas a Supabase o asegurar que el backend esté activo.
- Si en el futuro quieres normalizar también `nombre_curso → nombre`, puedo darte una migración adicional y ajustar las vistas del docente.

