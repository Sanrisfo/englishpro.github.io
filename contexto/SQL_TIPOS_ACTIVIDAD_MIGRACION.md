# Migración: Insertar "Tipos de Actividad" entre Habilidades y Actividades

Este documento describe la migración en Supabase para añadir un nivel intermedio de "Tipos de Actividad" entre `habilidades` y las "actividades" que hoy consumen los estudiantes. En el esquema actual, los cuestionarios (actividades evaluativas) cuelgan directamente de `habilidades`. La migración crea `tipos_actividad`, migra `cuestionarios` para que apunten a este nuevo nivel y realiza un backfill seguro.

- Base real en Supabase: nombres en minúsculas (`habilidades`, `cuestionarios`, ...), aunque la documentación use PascalCase.
- Referencias: contexto/02_BASE_DE_DATOS.md:260 (Cursos), 300 (Habilidades), 410 (Cuestionarios).

---

## Objetivos

- Crear `tipos_actividad` con relación 1:N desde `habilidades`.
- Modificar `cuestionarios` para referenciar `tipos_actividad` en lugar de `habilidades`.
- Backfill automático creando un tipo por defecto ("General") por cada habilidad y re-enlazando todos los cuestionarios existentes.
- Añadir índices y restricciones.
- Incluir base para RLS cuando se active.

---

## Diagrama Lógico (nuevo)

```
Cursos ──┬── Habilidades ──┬── Tipos_Actividad ──┬── Cuestionarios
         │                  │                     └── (antes: dependían de Habilidades)
         │                  └── (CRUD por docentes)
         └── (4 habilidades por curso)
```

---

## SQL de Migración (Supabase)

Ejecutar completo en el SQL Editor de Supabase.

```sql
BEGIN;

-- 1) Crear tabla TIPOS DE ACTIVIDAD
CREATE TABLE IF NOT EXISTS public.tipos_actividad (
  id            SERIAL PRIMARY KEY,
  id_habilidad  INT NOT NULL,
  nombre        VARCHAR(80) NOT NULL,
  descripcion   TEXT,
  orden         INT DEFAULT 1,
  activo        BOOLEAN DEFAULT TRUE,
  CONSTRAINT tipos_actividad_habilidad_fkey
    FOREIGN KEY (id_habilidad) REFERENCES public.habilidades(id_habilidad) ON DELETE CASCADE,
  CONSTRAINT tipos_actividad_unq UNIQUE (id_habilidad, nombre)
);

CREATE INDEX IF NOT EXISTS tipos_actividad_habilidad_idx
  ON public.tipos_actividad(id_habilidad);

-- 2) Agregar FK en CUESTIONARIOS hacia TIPOS DE ACTIVIDAD (columna nueva)
ALTER TABLE public.cuestionarios
  ADD COLUMN IF NOT EXISTS id_tipo_actividad INT;

ALTER TABLE public.cuestionarios
  ADD CONSTRAINT IF NOT EXISTS cuestionarios_tipo_actividad_fkey
  FOREIGN KEY (id_tipo_actividad) REFERENCES public.tipos_actividad(id) ON DELETE CASCADE;

-- 3) Backfill: crear un tipo “General” por cada habilidad y reasignar cuestionarios
INSERT INTO public.tipos_actividad (id_habilidad, nombre, descripcion, orden, activo)
SELECT h.id_habilidad, 'General', 'Auto-creado por migración', 1, TRUE
FROM public.habilidades h
ON CONFLICT (id_habilidad, nombre) DO NOTHING;

UPDATE public.cuestionarios c
SET id_tipo_actividad = t.id
FROM public.tipos_actividad t
WHERE t.id_habilidad = c.id_habilidad
  AND t.nombre = 'General'
  AND c.id_tipo_actividad IS NULL;

-- 4) Hacer NOT NULL y agregar índice
ALTER TABLE public.cuestionarios
  ALTER COLUMN id_tipo_actividad SET NOT NULL;

CREATE INDEX IF NOT EXISTS cuestionarios_tipo_actividad_idx
  ON public.cuestionarios(id_tipo_actividad);

-- 5) Quitar el vínculo directo a HABILIDADES en CUESTIONARIOS
DO $$
DECLARE
  fk_name text;
BEGIN
  SELECT conname INTO fk_name
  FROM pg_constraint
  WHERE conrelid = 'public.cuestionarios'::regclass
    AND contype = 'f'
    AND confrelid = 'public.habilidades'::regclass;

  IF fk_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.cuestionarios DROP CONSTRAINT %I', fk_name);
  END IF;
END$$;

ALTER TABLE public.cuestionarios
  DROP COLUMN IF EXISTS id_habilidad;

COMMIT;
```

---

## Verificación

```sql
-- 1) Que existan tipos por habilidad
SELECT h.id_habilidad, h.nombre_habilidad, COUNT(t.*) AS total_tipos
FROM public.habilidades h
LEFT JOIN public.tipos_actividad t ON t.id_habilidad = h.id_habilidad
GROUP BY 1,2
ORDER BY 1;

-- 2) Que los cuestionarios ya apunten a tipos_actividad
SELECT c.id_cuestionario, c.titulo, t.id AS tipo_id, t.nombre AS tipo_nombre, h.id_habilidad, h.nombre_habilidad
FROM public.cuestionarios c
JOIN public.tipos_actividad t ON t.id = c.id_tipo_actividad
JOIN public.habilidades h ON h.id_habilidad = t.id_habilidad
ORDER BY c.id_cuestionario
LIMIT 50;
```

---

## RLS (opcional para cuando lo actives)

Actualmente RLS está deshabilitado (ver `contexto/RLS_PENDIENTE.md`). Cuando lo habilites, base mínima para lectura autenticada:

```sql
ALTER TABLE public.tipos_actividad ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tipos_actividad_select ON public.tipos_actividad;
CREATE POLICY tipos_actividad_select
ON public.tipos_actividad
FOR SELECT
USING (true);
```

Ejemplo de restricción por rol (ajustar a tu modelo `usuarios`/`docentes`):

```sql
-- CREATE POLICY tipos_actividad_admin_crud
-- ON public.tipos_actividad
-- FOR ALL
-- TO authenticated
-- USING (
--   EXISTS (
--     SELECT 1 FROM public.usuarios u WHERE u.id_usuario = auth.uid() AND u.rol = 'Admin'
--   )
-- )
-- WITH CHECK (
--   EXISTS (
--     SELECT 1 FROM public.usuarios u WHERE u.id_usuario = auth.uid() AND u.rol = 'Admin'
--   )
-- );
```

---

## Si tus “Actividades” no son `cuestionarios`

Si tu navegación usa otra tabla como “actividades” (por ejemplo, `materiales_estudio` o `preguntas`), aplica el mismo patrón:

1) Añade `id_tipo_actividad INT NOT NULL` con FK a `tipos_actividad(id)`.
2) Crea tipos por defecto (“General”) por habilidad y backfill.
3) Agrega índice en `id_tipo_actividad`.
4) Elimina `id_habilidad` y su FK.

Puedo adaptar el SQL 1:1 si confirmas el nombre exacto de tu tabla de actividades.

---

## Impacto en la App (alto nivel)

- Nueva pantalla de gestión para docentes: CRUD de `tipos_actividad` por `habilidad`.
- Navegación estudiantes: Curso → Habilidad → Tipo de Actividad → Cuestionarios.
- Servicios/queries: ahora filtrar cuestionarios por `id_tipo_actividad` y listar tipos por `id_habilidad`.


---

## Complemento: Preguntas v2 - Seeds de ejemplo (1 por tipo)

Requisitos previos:
- Haber ejecutado la migración de “Preguntas v2” (enum `question_type`, tablas `matching_*`, `completion_*`, `record_audio_config`, `write_text_config`, `tipo_actividad_pregunta_permitida` y triggers/funciones asociados).
- Haber ejecutado esta migración de `tipos_actividad` (esta misma página) para que existan tipos por `habilidad`.

Este bloque crea 5 Tipos de Actividad de ejemplo (uno por tipo de pregunta permitido), 5 cuestionarios y 5 preguntas (MC, Matching, Completion, Record Audio, Write Text) con los datos mínimos para validar que los triggers y restricciones funcionan end-to-end. Usa la primera `habilidad` y un `módulo` asociado (si no existe módulo, crea uno de seed).

```sql
BEGIN;

-- Asegura que existe al menos 1 habilidad y 1 módulo (crea un módulo de seed si falta)
DO $$
DECLARE
  v_hab INT;
  v_mod INT;
BEGIN
  SELECT id_habilidad INTO v_hab FROM public.habilidades ORDER BY id_habilidad LIMIT 1;
  IF v_hab IS NULL THEN
    RAISE EXCEPTION 'No hay registros en public.habilidades. Crea al menos una habilidad antes de sembrar preguntas.';
  END IF;

  SELECT m.id_modulo INTO v_mod
  FROM public.modulos m
  WHERE m.id_habilidad = v_hab
  ORDER BY m.id_modulo
  LIMIT 1;

  IF v_mod IS NULL THEN
    INSERT INTO public.modulos (id_habilidad, nombre_modulo, descripcion, orden, activo)
    VALUES (v_hab, 'Módulo Seed', 'Auto-creado para seeds', 1, TRUE)
    RETURNING id_modulo INTO v_mod;
  END IF;
END $$;

-- Crea 5 Tipos de Actividad (uno por tipo de pregunta)
DO $$
DECLARE
  v_hab INT := (SELECT id_habilidad FROM public.habilidades ORDER BY id_habilidad LIMIT 1);
  v_t_mc INT; v_t_matching INT; v_t_completion INT; v_t_speaking INT; v_t_writing INT;
BEGIN
  INSERT INTO public.tipos_actividad (id_habilidad, nombre, descripcion, orden, activo)
  VALUES (v_hab, 'MC', 'Multiple Choice', 1, TRUE)
  ON CONFLICT (id_habilidad, nombre) DO UPDATE SET nombre = EXCLUDED.nombre
  RETURNING id INTO v_t_mc;

  INSERT INTO public.tipos_actividad (id_habilidad, nombre, descripcion, orden, activo)
  VALUES (v_hab, 'Matching', 'Emparejar A con B', 2, TRUE)
  ON CONFLICT (id_habilidad, nombre) DO UPDATE SET nombre = EXCLUDED.nombre
  RETURNING id INTO v_t_matching;

  INSERT INTO public.tipos_actividad (id_habilidad, nombre, descripcion, orden, activo)
  VALUES (v_hab, 'Completion', 'Completar oraciones', 3, TRUE)
  ON CONFLICT (id_habilidad, nombre) DO UPDATE SET nombre = EXCLUDED.nombre
  RETURNING id INTO v_t_completion;

  INSERT INTO public.tipos_actividad (id_habilidad, nombre, descripcion, orden, activo)
  VALUES (v_hab, 'Speaking', 'Graba tu respuesta', 4, TRUE)
  ON CONFLICT (id_habilidad, nombre) DO UPDATE SET nombre = EXCLUDED.nombre
  RETURNING id INTO v_t_speaking;

  INSERT INTO public.tipos_actividad (id_habilidad, nombre, descripcion, orden, activo)
  VALUES (v_hab, 'Writing', 'Escribe tu respuesta', 5, TRUE)
  ON CONFLICT (id_habilidad, nombre) DO UPDATE SET nombre = EXCLUDED.nombre
  RETURNING id INTO v_t_writing;

  -- Restringe qué tipo de pregunta admite cada Tipo de Actividad
  INSERT INTO public.tipo_actividad_pregunta_permitida (id_tipo_actividad, tipo_pregunta)
  VALUES
    (v_t_mc, 'multiple_choice'),
    (v_t_matching, 'matching'),
    (v_t_completion, 'completion'),
    (v_t_speaking, 'record_audio'),
    (v_t_writing, 'write_text')
  ON CONFLICT DO NOTHING;
END $$;

-- Crea 5 cuestionarios (uno por tipo de actividad)
DO $$
DECLARE
  v_mod INT := (
    SELECT m.id_modulo FROM public.modulos m
    JOIN public.habilidades h ON h.id_habilidad = m.id_habilidad
    ORDER BY m.id_modulo LIMIT 1
  );
  v_t_mc INT := (SELECT id FROM public.tipos_actividad WHERE nombre='MC' ORDER BY id LIMIT 1);
  v_t_matching INT := (SELECT id FROM public.tipos_actividad WHERE nombre='Matching' ORDER BY id LIMIT 1);
  v_t_completion INT := (SELECT id FROM public.tipos_actividad WHERE nombre='Completion' ORDER BY id LIMIT 1);
  v_t_speaking INT := (SELECT id FROM public.tipos_actividad WHERE nombre='Speaking' ORDER BY id LIMIT 1);
  v_t_writing INT := (SELECT id FROM public.tipos_actividad WHERE nombre='Writing' ORDER BY id LIMIT 1);
BEGIN
  INSERT INTO public.cuestionarios (id_modulo, id_tipo_actividad, titulo, descripcion, tiempo_limite_minutos, nivel_dificultad, tipo_evaluacion)
  VALUES
    (v_mod, v_t_mc, 'Seed MC', 'Cuestionario de ejemplo MC', 10, 'Basico', 'Practica'),
    (v_mod, v_t_matching, 'Seed Matching', 'Cuestionario de ejemplo Matching', 10, 'Basico', 'Practica'),
    (v_mod, v_t_completion, 'Seed Completion', 'Cuestionario de ejemplo Completion', 10, 'Basico', 'Practica'),
    (v_mod, v_t_speaking, 'Seed Speaking', 'Cuestionario de ejemplo Speaking', 10, 'Basico', 'Practica'),
    (v_mod, v_t_writing, 'Seed Writing', 'Cuestionario de ejemplo Writing', 10, 'Basico', 'Practica')
  ON CONFLICT DO NOTHING;
END $$;

-- Pregunta 1: Multiple Choice (3 opciones; 1 correcta)
DO $$
DECLARE
  v_hab INT := (SELECT id_habilidad FROM public.habilidades ORDER BY id_habilidad LIMIT 1);
  v_q INT;
  v_c INT := (
    SELECT id_cuestionario FROM public.cuestionarios
    WHERE titulo = 'Seed MC' ORDER BY id_cuestionario LIMIT 1
  );
BEGIN
  INSERT INTO public.preguntas (id_habilidad, texto_pregunta, tipo_pregunta, puntos, nivel_dificultad, nivel_acceso)
  VALUES (v_hab, '¿Cuál de las siguientes es correcta?', 'multiple_choice', 1, 'Basico', 'Freemium')
  RETURNING id_pregunta INTO v_q;

  INSERT INTO public.opciones_respuesta (id_pregunta, texto_opcion, es_correcta, orden)
  VALUES
    (v_q, 'Opción A', TRUE, 1),
    (v_q, 'Opción B', FALSE, 2),
    (v_q, 'Opción C', FALSE, 3);

  INSERT INTO public.cuestionario_preguntas (id_cuestionario, id_pregunta, orden)
  VALUES (v_c, v_q, 1);
END $$;

-- Pregunta 2: Matching (3 enunciados A y 4 respuestas B; 1 distractor)
DO $$
DECLARE
  v_hab INT := (SELECT id_habilidad FROM public.habilidades ORDER BY id_habilidad LIMIT 1);
  v_q INT;
  v_c INT := (SELECT id_cuestionario FROM public.cuestionarios WHERE titulo='Seed Matching' ORDER BY id_cuestionario LIMIT 1);
  a1 INT; a2 INT; a3 INT; a4 INT; -- respuestas columna B
BEGIN
  INSERT INTO public.preguntas (id_habilidad, texto_pregunta, tipo_pregunta, puntos, nivel_dificultad, nivel_acceso)
  VALUES (v_hab, 'Empareja cada enunciado (A) con su respuesta (B).', 'matching', 3, 'Basico', 'Freemium')
  RETURNING id_pregunta INTO v_q;

  -- Respuestas (B): 3 correctas + 1 distractor
  INSERT INTO public.matching_answers (id_pregunta, texto, orden) VALUES
    (v_q, 'Respuesta 1', 1),
    (v_q, 'Respuesta 2', 2),
    (v_q, 'Respuesta 3', 3),
    (v_q, 'Distractor', 4)
  RETURNING id INTO a1, a2, a3, a4;

  -- Enunciados (A) con referencia a la respuesta correcta
  INSERT INTO public.matching_statements (id_pregunta, texto, orden, correct_answer_id) VALUES
    (v_q, 'Enunciado A1', 1, a1),
    (v_q, 'Enunciado A2', 2, a2),
    (v_q, 'Enunciado A3', 3, a3);

  INSERT INTO public.cuestionario_preguntas (id_cuestionario, id_pregunta, orden)
  VALUES (v_c, v_q, 1);
END $$;

-- Pregunta 3: Completion (5 oraciones; 1 gap por oración)
DO $$
DECLARE
  v_hab INT := (SELECT id_habilidad FROM public.habilidades ORDER BY id_habilidad LIMIT 1);
  v_q INT;
  v_c INT := (SELECT id_cuestionario FROM public.cuestionarios WHERE titulo='Seed Completion' ORDER BY id_cuestionario LIMIT 1);
  s1 INT; s2 INT; s3 INT; s4 INT; s5 INT;
BEGIN
  INSERT INTO public.preguntas (id_habilidad, texto_pregunta, tipo_pregunta, puntos, nivel_dificultad, nivel_acceso)
  VALUES (v_hab, 'Completa los espacios en blanco con la palabra exacta.', 'completion', 5, 'Basico', 'Freemium')
  RETURNING id_pregunta INTO v_q;

  -- 5 oraciones con un placeholder {{1}} para el gap
  INSERT INTO public.completion_sentences (id_pregunta, texto_template, orden) VALUES
    (v_q, 'I {{1}} to school.', 1),
    (v_q, 'She {{1}} very well.', 2),
    (v_q, 'They {{1}} soccer.', 3),
    (v_q, 'We {{1}} dinner at 7.', 4),
    (v_q, 'He {{1}} a book.', 5)
  RETURNING id INTO s1, s2, s3, s4, s5;

  -- Un gap por oración
  INSERT INTO public.completion_gaps (sentence_id, gap_index, correct_text) VALUES
    (s1, 1, 'go'),
    (s2, 1, 'sing'),
    (s3, 1, 'play'),
    (s4, 1, 'has'),
    (s5, 1, 'reads');

  INSERT INTO public.cuestionario_preguntas (id_cuestionario, id_pregunta, orden)
  VALUES (v_c, v_q, 1);
END $$;

-- Pregunta 4: Record Audio (tiempos fijos 10s pensar, 45s grabar)
DO $$
DECLARE
  v_hab INT := (SELECT id_habilidad FROM public.habilidades ORDER BY id_habilidad LIMIT 1);
  v_q INT;
  v_c INT := (SELECT id_cuestionario FROM public.cuestionarios WHERE titulo='Seed Speaking' ORDER BY id_cuestionario LIMIT 1);
BEGIN
  INSERT INTO public.preguntas (id_habilidad, texto_pregunta, tipo_pregunta, puntos, nivel_dificultad, nivel_acceso)
  VALUES (v_hab, 'Describe tu ciudad favorita.', 'record_audio', 5, 'Basico', 'Freemium')
  RETURNING id_pregunta INTO v_q;

  INSERT INTO public.record_audio_config (id_pregunta) VALUES (v_q);

  INSERT INTO public.cuestionario_preguntas (id_cuestionario, id_pregunta, orden)
  VALUES (v_c, v_q, 1);
END $$;

-- Pregunta 5: Write Text (límite de palabras configurable)
DO $$
DECLARE
  v_hab INT := (SELECT id_habilidad FROM public.habilidades ORDER BY id_habilidad LIMIT 1);
  v_q INT;
  v_c INT := (SELECT id_cuestionario FROM public.cuestionarios WHERE titulo='Seed Writing' ORDER BY id_cuestionario LIMIT 1);
BEGIN
  INSERT INTO public.preguntas (id_habilidad, texto_pregunta, tipo_pregunta, puntos, nivel_dificultad, nivel_acceso)
  VALUES (v_hab, 'Escribe un párrafo sobre tus metas.', 'write_text', 5, 'Basico', 'Freemium')
  RETURNING id_pregunta INTO v_q;

  INSERT INTO public.write_text_config (id_pregunta, max_words) VALUES (v_q, 120);

  INSERT INTO public.cuestionario_preguntas (id_cuestionario, id_pregunta, orden)
  VALUES (v_c, v_q, 1);
END $$;

COMMIT;
```

Notas:
- Los triggers de validación son DEFERRABLE; todo se valida al COMMIT. No ejecutes cada bloque en transacciones separadas si todavía no se completó el mínimo requerido (por ejemplo, MC exige 3–5 opciones).
- Si tu `cuestionarios` tiene columnas adicionales NOT NULL, agrega valores en los INSERT según tu esquema.
- La restricción de tipos por actividad se valida al insertar en `cuestionario_preguntas`.
