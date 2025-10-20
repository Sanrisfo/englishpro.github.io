# Guía de Instalación - EnglishPro

## Requisitos

**Solo necesitas instalar Docker Desktop:**

- [Docker Desktop para Windows](https://www.docker.com/products/docker-desktop)
- [Docker Desktop para macOS](https://www.docker.com/products/docker-desktop)
- [Docker para Linux](https://docs.docker.com/engine/install/)

**Eso es todo.** No necesitas instalar Flutter, Dart, PostgreSQL ni nada más.

---

## Instalación en 3 Pasos

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd EnglishProApp
```

### 2. Configurar Firebase (Obligatorio)

#### Opción A: Usar un proyecto Firebase existente del equipo

Si alguien del equipo ya creó el proyecto Firebase, pídele:
1. El archivo `google-services.json`
2. Las credenciales para el archivo `.env`

Luego:
```bash
# Copiar google-services.json a la carpeta correcta
# Windows (PowerShell)
Copy-Item ruta\al\google-services.json app\android\app\google-services.json

# Linux/macOS
cp ruta/al/google-services.json app/android/app/google-services.json

# Copiar y editar .env
# Windows
Copy-Item .env.example .env

# Linux/macOS
cp .env.example .env
```

Edita `.env` y completa las credenciales de Firebase que te dieron.

#### Opción B: Crear tu propio proyecto Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Crea un nuevo proyecto llamado "EnglishPro-Dev" (o el nombre que quieras)
3. Habilita **Authentication** (Email/Password)
4. Habilita **Storage** (modo de prueba)
5. En configuración del proyecto, agrega una app Android:
   - Package name: `com.englishpro.app`
   - Descarga `google-services.json`
   - Copia el archivo a `app/android/app/google-services.json`
6. Copia `.env.example` a `.env` y completa las credenciales de Firebase

### 3. Iniciar la Aplicación

```bash
# Windows (PowerShell)
.\start.ps1

# Linux/macOS
./start.sh
```

**¡Eso es todo!** El script hará automáticamente:
- ✅ Construir las imágenes Docker (primera vez toma 5-10 min)
- ✅ Iniciar PostgreSQL con las 16 tablas
- ✅ Cargar datos de prueba
- ✅ Iniciar el backend API
- ✅ Iniciar Flutter en modo web

---

## Acceder a la Aplicación

Una vez que el script termine, abre tu navegador en:

**http://localhost:5000**

### Usuarios de Prueba

Puedes iniciar sesión con estos usuarios:

| Email | Password | Rol | Plan |
|-------|----------|-----|------|
| `student@englishpro.com` | `password` | Estudiante | Freemium |
| `teacher@englishpro.com` | `password` | Docente | Premium |
| `premium@englishpro.com` | `password` | Estudiante | Premium |

**Nota:** También puedes registrar tu propia cuenta usando el botón "Registrarse" en la app.

---

## Comandos Útiles

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs solo del backend
docker-compose logs -f backend

# Ver logs solo de Flutter
docker-compose logs -f flutter_web

# Detener todos los servicios
docker-compose down

# Reiniciar un servicio específico
docker-compose restart backend

# Ver servicios corriendo
docker ps

# Reconstruir imágenes (si cambiaste código)
docker-compose build
docker-compose up -d
```

---

## Estructura de Servicios

Cuando ejecutes `start.sh` o `start.ps1`, se levantarán 3 contenedores:

1. **englishpro_db** (PostgreSQL)
   - Puerto: 5432
   - Contiene las 16 tablas con datos de prueba

2. **englishpro_backend** (API Dart)
   - Puerto: 8080
   - API REST del backend

3. **englishpro_flutter_web** (Flutter Web)
   - Puerto: 5000
   - La aplicación corriendo en el navegador

---

## Solución de Problemas

### Error: "Docker no está instalado"
- Descarga e instala Docker Desktop desde https://www.docker.com/get-started
- Reinicia tu computadora después de instalar

### Error: "No Firebase App has been created"
- Verifica que `app/android/app/google-services.json` existe
- Verifica que el archivo `.env` tiene las credenciales correctas de Firebase
- Los valores NO deben ser los de ejemplo (`your-firebase-project-id`, etc)

### Los contenedores no inician
```bash
# Ver qué salió mal
docker-compose logs

# Eliminar todo y empezar de nuevo
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### La app no carga en el navegador
- Espera 1-2 minutos después de ejecutar el script
- Verifica que el contenedor está corriendo: `docker ps | grep flutter_web`
- Ver logs: `docker-compose logs flutter_web`

### Cambié código pero no se refleja
```bash
# Reconstruir imágenes
docker-compose build
docker-compose up -d
```

---

## Para Desarrollo

Si quieres modificar código y ver cambios en tiempo real:

### Backend (Hot Reload Automático)
```bash
# El backend ya tiene hot reload activado
# Simplemente edita archivos en backend/lib/ y se recargará automáticamente
```

### Flutter (Reconstruir)
```bash
# Opción 1: Reconstruir el contenedor
docker-compose build flutter_web
docker-compose up -d flutter_web

# Opción 2: Ejecutar Flutter localmente (requiere instalar Flutter)
cd app
flutter run -d chrome
```

---

## Próximos Pasos

1. ✅ Abre http://localhost:5000 en tu navegador
2. ✅ Inicia sesión con un usuario de prueba
3. ✅ Explora los 4 cursos disponibles (TOEFL, IELTS, Business, Action)
4. ✅ Prueba hacer un cuestionario
5. ✅ Revisa la documentación completa en [README.md](README.md)

---

## Ayuda

Si tienes problemas que no están cubiertos aquí:

1. Revisa los logs: `docker-compose logs -f`
2. Consulta con el equipo de desarrollo
3. Lee el README.md para más detalles del proyecto

---

**Desarrollado por el equipo EnglishPro - UNMSM FISI 2024**
