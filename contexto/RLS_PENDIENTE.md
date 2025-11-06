# 🔒 Configuración Pendiente de RLS (Row Level Security)

## ⚠️ ESTADO ACTUAL
El RLS está **DESHABILITADO** en las tablas principales para permitir el desarrollo y testing.

**Comando ejecutado:**
```sql
ALTER TABLE docentes DISABLE ROW LEVEL SECURITY;
```

---

## 📋 ¿Qué es RLS?

Row Level Security (RLS) es una característica de seguridad de PostgreSQL/Supabase que controla qué filas puede ver o modificar cada usuario según políticas definidas.

**Sin RLS:** Cualquier usuario autenticado puede acceder a todos los datos.
**Con RLS:** Solo se accede a los datos permitidos por las políticas configuradas.

---

## 🎯 TAREAS PENDIENTES

### 1. Tabla: `docentes`

#### Políticas recomendadas:

```sql
-- Habilitar RLS
ALTER TABLE docentes ENABLE ROW LEVEL SECURITY;

-- Política 1: Un docente puede ver solo su propio perfil
CREATE POLICY "docente_ver_propio_perfil"
ON docentes FOR SELECT
USING (auth.uid() = id_usuario);

-- Política 2: Un docente puede actualizar solo su propio perfil
CREATE POLICY "docente_actualizar_propio_perfil"
ON docentes FOR UPDATE
USING (auth.uid() = id_usuario);

-- Política 3: Permitir INSERT al registrarse (si aplica)
CREATE POLICY "docente_crear_perfil"
ON docentes FOR INSERT
WITH CHECK (auth.uid() = id_usuario);

-- Política 4: Administradores ven todos los docentes (opcional)
CREATE POLICY "admin_ver_todos_docentes"
ON docentes FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM usuarios
    WHERE id_usuario = auth.uid()
    AND rol = 'administrador'
  )
);
```

---

### 2. Tabla: `estudiantes`

#### Políticas recomendadas:

```sql
-- Habilitar RLS
ALTER TABLE estudiantes ENABLE ROW LEVEL SECURITY;

-- Política 1: Un estudiante puede ver solo su propio perfil
CREATE POLICY "estudiante_ver_propio_perfil"
ON estudiantes FOR SELECT
USING (auth.uid() = id_usuario);

-- Política 2: Un estudiante puede actualizar solo su propio perfil
CREATE POLICY "estudiante_actualizar_propio_perfil"
ON estudiantes FOR UPDATE
USING (auth.uid() = id_usuario);

-- Política 3: Los docentes pueden ver a sus estudiantes matriculados
CREATE POLICY "docente_ver_sus_estudiantes"
ON estudiantes FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM matriculas m
    JOIN cursos c ON m.id_curso = c.id_curso
    WHERE m.id_estudiante = estudiantes.id_estudiante
    AND c.id_docente = (
      SELECT id_docente FROM docentes WHERE id_usuario = auth.uid()
    )
  )
);
```

---

### 3. Tabla: `cursos`

#### Políticas recomendadas:

```sql
-- Habilitar RLS
ALTER TABLE cursos ENABLE ROW LEVEL SECURITY;

-- Política 1: Un docente puede ver solo sus propios cursos
CREATE POLICY "docente_ver_propios_cursos"
ON cursos FOR SELECT
USING (
  id_docente = (
    SELECT id_docente FROM docentes WHERE id_usuario = auth.uid()
  )
);

-- Política 2: Un docente puede crear cursos
CREATE POLICY "docente_crear_cursos"
ON cursos FOR INSERT
WITH CHECK (
  id_docente = (
    SELECT id_docente FROM docentes WHERE id_usuario = auth.uid()
  )
);

-- Política 3: Un docente puede actualizar solo sus propios cursos
CREATE POLICY "docente_actualizar_propios_cursos"
ON cursos FOR UPDATE
USING (
  id_docente = (
    SELECT id_docente FROM docentes WHERE id_usuario = auth.uid()
  )
);

-- Política 4: Los estudiantes pueden ver los cursos en los que están matriculados
CREATE POLICY "estudiante_ver_cursos_matriculados"
ON cursos FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM matriculas m
    WHERE m.id_curso = cursos.id_curso
    AND m.id_estudiante = (
      SELECT id_estudiante FROM estudiantes WHERE id_usuario = auth.uid()
    )
  )
);
```

---

### 4. Tabla: `matriculas`

#### Políticas recomendadas:

```sql
-- Habilitar RLS
ALTER TABLE matriculas ENABLE ROW LEVEL SECURITY;

-- Política 1: Un estudiante puede ver sus propias matrículas
CREATE POLICY "estudiante_ver_propias_matriculas"
ON matriculas FOR SELECT
USING (
  id_estudiante = (
    SELECT id_estudiante FROM estudiantes WHERE id_usuario = auth.uid()
  )
);

-- Política 2: Un docente puede ver las matrículas de sus cursos
CREATE POLICY "docente_ver_matriculas_sus_cursos"
ON matriculas FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM cursos c
    WHERE c.id_curso = matriculas.id_curso
    AND c.id_docente = (
      SELECT id_docente FROM docentes WHERE id_usuario = auth.uid()
    )
  )
);

-- Política 3: Un estudiante puede matricularse (INSERT)
CREATE POLICY "estudiante_crear_matricula"
ON matriculas FOR INSERT
WITH CHECK (
  id_estudiante = (
    SELECT id_estudiante FROM estudiantes WHERE id_usuario = auth.uid()
  )
);
```

---

## 🔍 COMANDOS DE VERIFICACIÓN

### Ver estado actual del RLS:
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('docentes', 'estudiantes', 'cursos', 'matriculas');
```

### Ver todas las políticas actuales:
```sql
SELECT tablename, policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename IN ('docentes', 'estudiantes', 'cursos', 'matriculas');
```

### Eliminar una política si es necesario:
```sql
DROP POLICY IF EXISTS "nombre_de_la_politica" ON nombre_tabla;
```

---

## 📝 NOTAS IMPORTANTES

1. **Testing:** Antes de habilitar RLS en producción, prueba exhaustivamente con diferentes roles de usuario.

2. **auth.uid():** Esta función devuelve el UUID del usuario autenticado en Supabase. Asegúrate de que coincida con los valores en `id_usuario`.

3. **Performance:** Las políticas complejas pueden afectar el rendimiento. Considera agregar índices en las columnas usadas en las políticas.

4. **Orden de implementación:**
   - Primero configura las políticas en un ambiente de desarrollo
   - Prueba cada política individualmente
   - Verifica que no bloquees accesos legítimos
   - Luego aplica en producción

5. **Roles adicionales:** Si tienes roles como "administrador" o "coordinador", necesitarás políticas adicionales para esos casos.

---

## ✅ CHECKLIST ANTES DE HABILITAR RLS

- [ ] Verificar que `auth.uid()` funciona correctamente en tu aplicación
- [ ] Crear todas las políticas necesarias
- [ ] Probar cada política con diferentes usuarios
- [ ] Verificar que los docentes solo ven sus datos
- [ ] Verificar que los estudiantes solo ven sus datos
- [ ] Probar operaciones de INSERT, UPDATE, DELETE
- [ ] Documentar cualquier caso especial o excepción
- [ ] Hacer backup de la base de datos antes de habilitar RLS en producción

---

## 🚀 CUÁNDO IMPLEMENTAR

Se recomienda implementar RLS **ANTES** de:
- Subir la aplicación a producción
- Agregar datos reales de usuarios
- Hacer el lanzamiento público

Se puede posponer durante:
- Desarrollo local
- Testing de funcionalidades
- Debugging de la aplicación

---

**Fecha de creación:** 2025-11-04
**Estado:** PENDIENTE DE IMPLEMENTACIÓN
**Prioridad:** ALTA (antes de producción)
