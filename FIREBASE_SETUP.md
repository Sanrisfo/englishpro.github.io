# 🔥 Firebase Setup Guide

## Paso 1: Crear Proyecto en Firebase Console

1. Ir a https://console.firebase.google.com
2. Clic en "Agregar proyecto" / "Add project"
3. Nombre: `englishpro-dev` (o tu preferencia)
4. Desactivar Google Analytics (opcional)
5. Clic en "Crear proyecto"

## Paso 2: Habilitar Firebase Authentication

1. En el menú lateral, ir a **Build → Authentication**
2. Clic en "Get Started" / "Comenzar"
3. Ir a la pestaña **"Sign-in method"**
4. Habilitar **"Email/Password"**
   - Email/Password: **Enabled ✅**
   - Email link (passwordless sign-in): **Disabled**
5. Clic en "Save" / "Guardar"

## Paso 3: Habilitar Firebase Storage

1. En el menú lateral, ir a **Build → Storage**
2. Clic en "Get Started" / "Comenzar"
3. **Reglas de seguridad** - Seleccionar:
   ```
   Start in production mode
   ```
4. Seleccionar ubicación: **us-central1** (o la más cercana)
5. Clic en "Done" / "Listo"

### Configurar Reglas de Storage (importante)

En la pestaña **"Rules"**, reemplazar con:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Audio files for Speaking (authenticated users)
    match /audio/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Video materials (public read, docentes write)
    match /videos/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // PDF materials (public read, docentes write)
    match /pdfs/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Images (public read, docentes write)
    match /images/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Paso 4: Agregar App Android

1. En la página principal del proyecto, clic en el ícono **Android**
2. Registrar app:
   - **Android package name**: `com.englishpro.englishpro_app`
   - **App nickname**: `EnglishPro`
   - **SHA-1**: (opcional por ahora, dejar vacío)
3. Clic en "Register app" / "Registrar app"

## Paso 5: Descargar google-services.json

1. Descargar el archivo `google-services.json`
2. Colocarlo en: `app/android/app/google-services.json`

## Paso 6: Obtener Credenciales para .env

1. En la página principal del proyecto, ir a **⚙️ Configuración del proyecto**
2. En la pestaña **"General"**, copiar:
   - **Project ID**: `tu-project-id`
   - **Web API Key**: (aparece en "Tus apps" → Web app)

### Crear Web App (si no existe)

1. En Configuración del proyecto, ir a "Tus apps"
2. Clic en el ícono **</>** (Web)
3. Nickname: `EnglishPro Web`
4. **NO** marcar Firebase Hosting
5. Clic en "Registrar app"
6. Copiar las credenciales que aparecen

## Paso 7: Actualizar .env

Copiar los valores a `.env` y `app/.env`:

```env
FIREBASE_PROJECT_ID=tu-project-id
FIREBASE_API_KEY=AIzaSy...
FIREBASE_AUTH_DOMAIN=tu-project-id.firebaseapp.com
FIREBASE_STORAGE_BUCKET=tu-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:android:abc123def456
```

## Paso 8: Verificar Límites del Plan Spark (Gratis)

### Firebase Authentication
- ✅ 10,000 verificaciones/mes
- ✅ 3,000 verificaciones de teléfono/mes

### Firebase Storage
- ✅ 5 GB de almacenamiento
- ✅ 1 GB/día de transferencia de bajada
- ✅ 20,000 operaciones de escritura/día
- ✅ 50,000 operaciones de lectura/día

## ✅ Checklist Final

- [ ] Proyecto Firebase creado
- [ ] Authentication habilitada (Email/Password)
- [ ] Storage habilitado con reglas configuradas
- [ ] App Android registrada
- [ ] `google-services.json` descargado y colocado en `app/android/app/`
- [ ] Credenciales copiadas a `.env`
- [ ] Web app creada para obtener credenciales completas

## 🔗 Links Útiles

- Firebase Console: https://console.firebase.google.com
- Documentación Auth: https://firebase.google.com/docs/auth
- Documentación Storage: https://firebase.google.com/docs/storage
