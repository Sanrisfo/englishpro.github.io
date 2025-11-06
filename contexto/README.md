# 📚 CONTEXTO COMPLETO - EnglishPro

**Documentación consolidada para trabajo rápido y contextualizado**

---

## 🎯 Propósito

Esta carpeta contiene **toda la información necesaria** para trabajar eficientemente en el proyecto EnglishPro sin tener que buscar en múltiples archivos dispersos.

**ROI:** Ahorra horas de exploración y debugging

---

## 📖 Orden de Lectura Recomendado

### Para Nuevos Desarrolladores:

1. **`00_INICIO_RAPIDO.md`** (5 min)
   - Resumen ejecutivo del proyecto
   - Setup en 5 minutos
   - Stack tecnológico
   - Qué hace la aplicación

2. **`01_ARQUITECTURA.md`** (5 min)
   - Diagrama del sistema
   - Flujos de datos
   - Decisiones técnicas
   - Patrones de diseño

3. **`02_BASE_DE_DATOS.md`** (5 min)
   - 16 tablas explicadas
   - Relaciones y constraints
   - Triggers y RLS
   - Queries comunes

4. **`03_APP_FLUTTER.md`** (5 min)
   - Estructura de carpetas
   - Servicios y modelos
   - Pantallas principales
   - Widgets reutilizables

5. **`04_ESTADO_Y_PROXIMOS_PASOS.md`** (3 min)
   - Qué funciona ahora
   - Qué falta implementar
   - Roadmap recomendado
   - Prioridades

---

## 📋 Resumen Ultra-Rápido (1 minuto)

### Qué es EnglishPro

App móvil educativa para estudiantes de inglés (TOEFL, IELTS, Business, English in Action) con 4 habilidades (Writing, Speaking, Listening, Reading) y 4 planes de suscripción.

### Stack

- **Frontend:** Flutter 3.35.4 + Dart 3.9.2+
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Backend opcional:** Dart (Docker) - para pagos/IA
- **Estado:** Provider
- **Control versiones:** FVM + Git

### Estado Actual

✅ **Funciona:** Login, cursos, quiz, progreso, panel docente
🟡 **Falta:** RLS, testing, pagos Stripe, simulacros completos
📅 **Lanzamiento:** 3-4 semanas

### Setup Rápido

```bash
git clone <url>
cd EnglishPro
fvm install 3.35.4
cd app && fvm flutter pub get
fvm flutter run
```

---

## 🗂️ Contenido Detallado

### 00_INICIO_RAPIDO.md

**Qué contiene:**
- Descripción del proyecto
- 4 módulos educativos
- 4 planes de suscripción
- Stack tecnológico completo
- Estructura de carpetas
- Setup en 5 pasos
- Credenciales y accesos
- Troubleshooting común

**Cuándo leerlo:**
- Primer día en el proyecto
- Onboarding de nuevos devs
- Recordar setup rápido

---

### 01_ARQUITECTURA.md

**Qué contiene:**
- Diagrama general del sistema
- Arquitectura Fase 1 (actual) vs Fase 2 (futuro)
- Stack tecnológico detallado
- Arquitectura de carpetas
- Flujos de datos principales (Auth, Quiz, Upload)
- Decisiones técnicas y alternativas descartadas
- Patrones de diseño (Service Layer, Provider, Repository)
- Control de versiones (FVM, Docker)
- Escalabilidad

**Cuándo leerlo:**
- Para entender cómo funciona el sistema
- Antes de agregar nuevas features
- Al hacer refactoring
- Para entender decisiones técnicas

---

### 02_BASE_DE_DATOS.md

**Qué contiene:**
- Diagrama ER de 16 tablas
- Explicación detallada de cada tabla
- Relaciones y foreign keys
- Índices optimizados
- Triggers (create_user_benefits)
- RLS (deshabilitado temporalmente + cómo habilitarlo)
- Queries útiles por tabla
- Queries de estadísticas
- Archivos SQL del proyecto
- Troubleshooting de DB

**Cuándo leerlo:**
- Para entender el esquema de datos
- Al escribir queries complejas
- Cuando hay errores de DB
- Para optimizar consultas
- Antes de agregar nuevas tablas

---

### 03_APP_FLUTTER.md

**Qué contiene:**
- Estructura completa de carpetas
- Entry point (main.dart)
- Configuración (Supabase)
- 8 Modelos explicados con código
- 4 Servicios (Auth, Storage, API)
- Providers (AuthProvider)
- 13+ Pantallas principales
- Widgets reutilizables (Audio, Video, PDF)
- 22+ Dependencias
- Flujos importantes (Login, Quiz)
- Patrones y buenas prácticas
- Debugging común

**Cuándo leerlo:**
- Para entender el código Flutter
- Al crear nuevas pantallas
- Al agregar nuevos servicios
- Para debugging de UI
- Antes de modificar modelos

---

### 04_ESTADO_Y_PROXIMOS_PASOS.md

**Qué contiene:**
- Estado actual del proyecto (Octubre 2024)
- 12 funcionalidades completadas ✅
- 3 funcionalidades parciales 🟡
- 10 funcionalidades NO implementadas ❌
- Roadmap de 5 sprints (25 días)
- Prioridades por stakeholder
- Riesgos y mitigaciones
- Métricas de éxito
- Setup para nuevos devs
- Resumen ejecutivo

**Cuándo leerlo:**
- Para saber qué funciona y qué no
- Al planificar sprints
- Para priorizar tareas
- Al hacer estimaciones
- Para reportes de progreso

---

## 🎯 Casos de Uso

### Caso 1: Nuevo desarrollador se une al equipo

**Orden de lectura:**
1. `00_INICIO_RAPIDO.md` - Entender el proyecto
2. `01_ARQUITECTURA.md` - Entender la arquitectura
3. `03_APP_FLUTTER.md` - Código Flutter
4. Ejecutar `fvm flutter run`
5. `04_ESTADO_Y_PROXIMOS_PASOS.md` - Qué hacer ahora


---

### Caso 2: Necesitas agregar una nueva pantalla

**Orden de lectura:**
1. `03_APP_FLUTTER.md` - Ver estructura de pantallas existentes
2. `01_ARQUITECTURA.md` - Entender patrones (Service Layer, Provider)
3. `02_BASE_DE_DATOS.md` - Si consultas DB, ver queries


---

### Caso 3: Error en la base de datos

**Orden de lectura:**
1. `02_BASE_DE_DATOS.md` - Troubleshooting de DB
2. `01_ARQUITECTURA.md` - Ver flujos de datos


---

### Caso 4: Planificar próximo sprint

**Orden de lectura:**
1. `04_ESTADO_Y_PROXIMOS_PASOS.md` - Roadmap y prioridades
2. `00_INICIO_RAPIDO.md` - Recordar features principales


---

### Caso 5: Integrar Stripe (pagos)

**Orden de lectura:**
1. `04_ESTADO_Y_PROXIMOS_PASOS.md` - Qué falta implementar
2. `01_ARQUITECTURA.md` - Backend futuro
3. `02_BASE_DE_DATOS.md` - Tabla Pagos
4. `No_Necesarios/backend/` - Código backend


---

## 🔄 Mantener Actualizado

### Cuándo actualizar estos archivos:

1. **Agregar nueva tabla en DB** → Actualizar `02_BASE_DE_DATOS.md`
2. **Agregar nueva pantalla** → Actualizar `03_APP_FLUTTER.md`
3. **Cambiar arquitectura** → Actualizar `01_ARQUITECTURA.md`
4. **Completar feature** → Actualizar `04_ESTADO_Y_PROXIMOS_PASOS.md`
5. **Cambiar setup** → Actualizar `00_INICIO_RAPIDO.md`

**Responsable:** Quien haga el cambio debe actualizar la documentación

---

## 📊 Comparación con Documentación Antigua

### Antes (No_Necesarios/*.md)

- ❌ 28 archivos dispersos
- ❌ Difícil encontrar información
- ❌ Mucha info obsoleta (Firebase, Docker)
- ❌ No hay orden de lectura
- ❌ Duplicación de contenido


---

### Ahora (contexto/*.md)

- ✅ 5 archivos organizados
- ✅ Orden de lectura claro
- ✅ Solo info actualizada (Supabase)
- ✅ Sin duplicación
- ✅ Casos de uso específicos


**Mejora:** 6-9x más rápido 🚀

---

## 🎓 Para el Equipo

### Ventajas de esta documentación:

1. **Onboarding rápido:** Nuevos devs listos en 30 min
2. **Menos preguntas:** Todo está documentado
3. **Menos bugs:** Entender arquitectura antes de codear
4. **Mejor estimaciones:** Conocer estado real del proyecto
5. **Trabajo asíncrono:** No necesitas esperar a otros para contexto

---

## 🆘 Si algo no está claro

1. Leer el archivo correspondiente completo
2. Buscar en `No_Necesarios/` (28 archivos adicionales)
3. Revisar código directamente
4. Preguntar al equipo

---


## ✅ Checklist de Lectura

Para nuevos desarrolladores:

- [ ] Leí `00_INICIO_RAPIDO.md`
- [ ] Leí `01_ARQUITECTURA.md`
- [ ] Leí `02_BASE_DE_DATOS.md`
- [ ] Leí `03_APP_FLUTTER.md`
- [ ] Leí `04_ESTADO_Y_PROXIMOS_PASOS.md`
- [ ] Ejecuté `fvm flutter run` exitosamente
- [ ] Entiendo qué funciona y qué falta
- [ ] Sé dónde buscar cuando tenga dudas

**Si completaste todo ✅ → Estás listo para contribuir** 🚀

---

**¡Comienza por `00_INICIO_RAPIDO.md`!**
