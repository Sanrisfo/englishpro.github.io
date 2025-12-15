import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Proveedor de estado para la autenticación y la sesión del usuario.
///
/// Esta clase utiliza `ChangeNotifier` para gestionar el estado global de la
/// sesión del usuario en la aplicación, incluyendo el objeto [User] y el token de
/// autenticación. Notifica a sus "listeners" (widgets que lo escuchan) cada
/// vez que el estado de autenticación cambia (ej. al iniciar sesión, cerrar sesión
/// o actualizar el perfil).
///
/// ### Cómo usar:
///
/// 1.  **Proveer la instancia:**
///     Se debe proporcionar una instancia de `AuthProvider` en la parte superior del
///     árbol de widgets, típicamente en `main.dart`, usando `ChangeNotifierProvider`.
///
///     ```dart
///     ChangeNotifierProvider(
///       create: (_) => AuthProvider(),
///       child: const MyApp(),
///     );
///     ```
///
/// 2.  **Consumir el estado:**
///     Dentro de los widgets, se puede acceder al estado del proveedor de dos maneras:
///     - `context.watch<AuthProvider>()`: Escucha los cambios y reconstruye el widget
///       cuando `notifyListeners()` es llamado.
///     - `context.read<AuthProvider>()`: Obtiene el estado actual sin suscribirse
///       a los cambios, ideal para ser usado dentro de funciones como `onPressed`.
///
///     ```dart
///     // Para reconstruir el widget cuando el estado cambia:
///     final isAuth = context.watch<AuthProvider>().isAuthenticated;
///
///     // Para leer el estado una sola vez:
///     final user = context.read<AuthProvider>().user;
///     ```
class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;

  /// El objeto [User] del usuario actualmente autenticado.
  ///
  /// Es `null` si no hay una sesión activa.
  User? get user => _user;

  /// El token de acceso asociado a la sesión actual (ej. de Supabase).
  ///
  /// Es `null` si no hay una sesión activa.
  String? get token => _token;

  /// Devuelve `true` si existe una sesión válida en memoria (tanto el usuario
  /// como el token no son nulos).
  bool get isAuthenticated => _user != null && _token != null;

  /// Establece el usuario y el token de la sesión actual y notifica a los listeners.
  ///
  /// Este método debe ser llamado después de un inicio de sesión o registro exitoso.
  ///
  /// @param user El objeto [User] que representa al usuario autenticado.
  /// @param token El token de acceso de la sesión.
  void setUser(User user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  /// Limpia la sesión del usuario en memoria, estableciendo `_user` y `_token` a `null`.
  ///
  /// Este método debe ser llamado al cerrar la sesión. Notifica a los listeners
  /// para que la UI se reconstruya y refleje el estado de "no autenticado".
  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }

  /// Actualiza los datos del usuario en memoria con un nuevo objeto [User].
  ///
  /// Es útil cuando el perfil del usuario ha sido modificado y se necesita
  /// que la UI refleje los cambios sin requerir un nuevo inicio de sesión.
  ///
  /// @param updatedUser El objeto [User] con los datos actualizados.
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
