# 1. Autenticación de Usuarios

El sistema de autenticación de EnglishPro se gestiona a través de **Supabase Auth**, lo que permite un manejo seguro y escalable de las sesiones de usuario. El flujo se integra directamente desde la aplicación Flutter hacia los servicios de Supabase en la nube.

##  diagrama de Flujo

```
┌─────────────┐      ┌───────────────────────────┐      ┌──────────────────┐
│ App Flutter │----▶│    Supabase Auth Service    │----▶│  Supabase Cloud  │
└─────────────┘      └───────────────────────────┘      └──────────────────┘
      │                        │                              │
      │ 1. Usuario ingresa     │                              │
      │    credenciales        │                              │
      │                        │ 2. Llama a signIn() o signUp()│
      │                        │                              │ 3. Valida contra
      │                        │                              │    la base de datos
      │                        │                              │
      │                        │ 4. Retorna sesión o error    │
      │                        │                              │
      │ 5. Actualiza el estado │                              │
      │    y navega al Home    │                              │
      │                        │                              │
```

## Componentes Clave

### 1. Pantallas de UI (`login_screen.dart` y `register_screen.dart`)

-   **Responsabilidad**: Capturar la entrada del usuario (email, contraseña, etc.).
-   **Interacción**: Utilizan un `AuthProvider` para delegar la lógica de autenticación y reaccionan a los cambios de estado (cargando, error, éxito).

### 2. `AuthProvider` (`auth_provider.dart`)

-   **Responsabilidad**: Manejar el estado de la autenticación en toda la aplicación (`isLoading`, `isAuthenticated`, `user`).
-   **Patrón**: `ChangeNotifier` (Provider). Notifica a los widgets cuando el estado de autenticación cambia.
-   **Lógica**: Llama a los métodos del `SupabaseAuthService` y actualiza su propio estado con el resultado.

### 3. `SupabaseAuthService` (`supabase_auth_service.dart`)

-   **Responsabilidad**: Abstraer toda la comunicación con Supabase Auth. Contiene la lógica para registrar, iniciar sesión y cerrar sesión.
-   **Métodos Principales**:
    -   `signUp()`: Crea un nuevo usuario en Supabase Auth y luego inserta un registro en la tabla `usuarios` de la base de datos.
    -   `signIn()`: Valida las credenciales del usuario con Supabase Auth y, si tiene éxito, recupera los datos del usuario de la tabla `usuarios`.
    -   `signOut()`: Cierra la sesión del usuario en el cliente de Supabase.

### 4. Supabase Auth (Nube)

-   **Responsabilidad**: Gestionar de forma segura las credenciales de los usuarios, generar y validar tokens JWT y aplicar políticas de seguridad.

## Flujo de Registro (`signUp`)

1.  El usuario completa el formulario en `register_screen.dart` y presiona "Registrar".
2.  La UI llama al método `register()` del `AuthProvider`.
3.  `AuthProvider` llama a `signUp()` en `SupabaseAuthService`.
4.  `SupabaseAuthService` primero crea el usuario en **Supabase Auth** (`supabase.auth.signUp`).
5.  Si tiene éxito, inserta los datos del perfil del nuevo usuario en la tabla `usuarios` de la base de datos.
6.  Un **trigger de base de datos** (`create_user_benefits`) se activa automáticamente para crear una entrada en la tabla `beneficios_usuario` para este nuevo usuario.
7.  La respuesta (éxito o error) se propaga de vuelta a la UI.
8.  Si el registro es exitoso, `AuthProvider` intenta iniciar sesión automáticamente para crear una sesión activa.

```dart
// En SupabaseAuthService

Future<Map<String, dynamic>> signUp({ ... }) async {
  // 1. Crear usuario en Supabase Auth
  final authResponse = await supabase.auth.signUp(...);

  // 2. Insertar en tabla `usuarios`
  await supabase.from('usuarios').insert({
    'nombre_completo': nombreCompleto,
    'email': email,
    'supabase_uid': authResponse.user!.id,
    // ... otros campos
  });

  return ...;
}
```

## Flujo de Inicio de Sesión (`signIn`)

1.  El usuario ingresa su email y contraseña en `login_screen.dart` y presiona "Login".
2.  La UI llama al método `login()` del `AuthProvider`.
3.  `AuthProvider` llama a `signIn()` en `SupabaseAuthService`.
4.  `SupabaseAuthService` valida las credenciales usando `supabase.auth.signInWithPassword()`.
5.  Si la autenticación es exitosa, el servicio realiza una consulta a la tabla `usuarios` para obtener el perfil completo del usuario.
6.  El objeto `User` se crea a partir de los datos de la base de datos y se almacena en el `AuthProvider`.
7.  `AuthProvider` notifica a sus listeners, y la UI navega al `HomeScreen`.

```dart
// En SupabaseAuthService

Future<Map<String, dynamic>> signIn({ ... }) async {
  // 1. Autenticar con Supabase Auth
  final response = await supabase.auth.signInWithPassword(...);

  // 2. Obtener datos de la tabla `usuarios`
  final userData = await supabase
      .from('usuarios')
      .select()
      .eq('supabase_uid', response.user!.id)
      .single();

  // 3. Crear y retornar el objeto User
  return {
    'success': true,
    'user': User.fromMap(userData),
  };
}
```

## Manejo de la Sesión

Supabase Flutter SDK maneja la persistencia de la sesión automáticamente. Una vez que un usuario inicia sesión, su token JWT se almacena de forma segura en el dispositivo. En inicios posteriores de la aplicación, el `SplashScreen` puede verificar si existe una sesión activa y redirigir al usuario directamente al `HomeScreen` sin necesidad de volver a iniciar sesión.

---

**Siguiente**: [2. Cursos y Contenido](./02_courses_and_content.md)
