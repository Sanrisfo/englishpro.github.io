# 📁 Estructura Limpia del Proyecto

## ✅ Archivos ESENCIALES (Para que funcione)

```
EnglishPro/
├── 📂 app/                          # 🔴 CRÍTICO - Aplicación Flutter
│   ├── .env                         # Credenciales Supabase (NO en Git)
│   ├── pubspec.yaml                 # Dependencias
│   ├── lib/                         # Código Dart
│   │   ├── main.dart                # Entry point
│   │   ├── config/
│   │   │   └── supabase_config.dart
│   │   ├── services/
│   │   │   ├── supabase_auth_service.dart
│   │   │   └── supabase_storage_service.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   └── teacher_dashboard_screen.dart
│   │   ├── models/
│   │   │   └── user.dart
│   │   └── providers/
│   │       └── auth_provider.dart
│   └── android/ ios/ web/           # Configuración plataformas
│
├── 📂 database/                     # Scripts SQL
│   ├── schema.sql                   # Estructura DB (ya ejecutado)
│   ├── DISABLE_RLS_TEMPORAL.sql     # Deshabilitar RLS (ya ejecutado)
│   ├── FIX_TRIGGER.sql              # Trigger correcto (ya ejecutado)
│   └── seed.sql                     # Datos de prueba (opcional)
│
├── .env                             # Variables backend (opcional)
├── .gitignore                       # Proteger secretos
└── README.md                        # Documentación principal
```

**Con esto funciona login/register y la app completa.** ✅

---

## 📦 Archivos NO Necesarios (Movidos a No_Necesarios/)

```
No_Necesarios/
├── 📚 Documentación (Guías, tutoriales, fixes)
│   ├── SETUP_PARA_COMPAÑEROS.md
│   ├── ARCHIVOS_ESENCIALES.md
│   ├── SOLUCION_COMPLETA_EQUIPO.md
│   ├── FIX_COMPLETO_RLS.md
│   ├── MIGRACION_SUPABASE.md
│   └── ... (20+ archivos .md)
│
├── 🐳 Docker & Backend (Solo para features avanzadas)
│   ├── backend/                     # Servidor Express
│   ├── docker-compose.yml
│   ├── docker-compose.dev.yml
│   ├── docker-start.sh/.ps1
│   └── check-environment.sh/.ps1
│
└── 🗄️ Database (Scripts ya ejecutados o alternativos)
    ├── supabase_migration.sql       # Migración original (con RLS recursivo)
    └── RLS_CORRECTO.sql             # RLS sin recursión (opcional)
```

---

## 🎯 Comandos Esenciales

### Para Desarrolladores Nuevos

```bash
# 1. Clonar proyecto
git clone <url>
cd EnglishPro

# 2. Crear app/.env con credenciales
cd app
# Crear .env con SUPABASE_URL y SUPABASE_ANON_KEY

# 3. Instalar y ejecutar
flutter pub get
flutter run
```

### Para Desarrollo Diario

```bash
# Actualizar código
git pull

# Ejecutar app
cd app
flutter run
```

---

## 🚫 NO Necesitas

- ❌ Docker Compose
- ❌ Backend Express
- ❌ PostgreSQL local
- ❌ Ejecutar SQL en Supabase (ya ejecutado)
- ❌ Variables de entorno del backend

---

## ✅ SÍ Necesitas

- ✅ `app/.env` con credenciales Supabase
- ✅ Flutter instalado
- ✅ Celular/emulador para probar
- ✅ Conexión a internet (para Supabase)

---

## 📊 Archivos por Tamaño/Importancia

### 🔴 CRÍTICO (Sin esto NO funciona)
- `app/lib/main.dart`
- `app/lib/config/supabase_config.dart`
- `app/lib/services/supabase_auth_service.dart`
- `app/lib/screens/login_screen.dart`
- `app/lib/screens/register_screen.dart`
- `app/lib/models/user.dart`
- `app/.env`
- `app/pubspec.yaml`

### 🟡 IMPORTANTE (Funcionalidad completa)
- `app/lib/screens/home_screen.dart`
- `app/lib/screens/teacher_dashboard_screen.dart`
- `app/lib/providers/auth_provider.dart`
- `app/lib/services/supabase_storage_service.dart`
- Otros modelos y widgets

### 🟢 OPCIONAL (Para features avanzadas)
- `No_Necesarios/backend/` - Backend Express
- `No_Necesarios/docker-compose.yml` - Docker
- Scripts de Docker

### ⚪ DOCUMENTACIÓN (No afecta código)
- `No_Necesarios/*.md` - Todas las guías

---

## 🔄 Cuándo Usar No_Necesarios/

### 1. Nuevo desarrollador se une
→ Ver `No_Necesarios/SETUP_PARA_COMPAÑEROS.md`

### 2. Necesitas backend para IA/Pagos/Emails
→ Restaurar `No_Necesarios/backend/`
→ Restaurar `No_Necesarios/docker-compose.yml`

### 3. Quieres habilitar RLS para seguridad
→ Ver `No_Necesarios/database/RLS_CORRECTO.sql`

### 4. Debugging/Troubleshooting
→ Ver `No_Necesarios/FIX_COMPLETO_RLS.md`
→ Ver `No_Necesarios/SOLUCION_COMPLETA_EQUIPO.md`

---

## 📈 Próximos Pasos

**Fase 1 (Actual):** ✅
- Login/Register funciona
- Supabase conectado
- Sin Docker, sin backend

**Fase 2 (Futuro):**
- Cuando necesites backend, restaura de `No_Necesarios/`
- Instala Docker
- Implementa features avanzadas (IA, pagos, etc.)

---

## 🆘 Troubleshooting

### "No encuentro supabase_config.dart"
→ Está en `app/lib/config/supabase_config.dart`

### "Missing Supabase credentials"
→ Crear `app/.env` con credenciales

### "¿Dónde está el backend?"
→ En `No_Necesarios/backend/` (no se necesita ahora)

### "¿Dónde está docker-compose.yml?"
→ En `No_Necesarios/docker-compose.yml` (no se necesita ahora)

---

## ✅ Resumen

**Proyecto limpio y organizado:**
- Solo archivos esenciales en raíz
- Documentación en `No_Necesarios/`
- Backend opcional en `No_Necesarios/`
- Fácil de entender para nuevos desarrolladores

**Tiempo de setup para nuevo dev: 5 minutos** ⚡
