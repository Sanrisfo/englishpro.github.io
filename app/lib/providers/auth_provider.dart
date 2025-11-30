import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Proveedor de autenticación y sesión de usuario.
///
/// Expone el usuario autenticado, el token de sesión y utilidades para
/// establecer/cerrar sesión y actualizar los datos del usuario.
class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;

  /// Usuario autenticado actualmente (o `null` si no hay sesión activa).
  User? get user => _user;

  /// Token de acceso (por ejemplo, access token de Supabase).
  String? get token => _token;

  /// Indica si existe una sesión válida en memoria.
  bool get isAuthenticated => _user != null && _token != null;

  /// Establece el usuario autenticado y su token asociado y notifica cambios.
  void setUser(User user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  /// Limpia la sesión en memoria (usuario y token) y notifica cambios.
  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }

  /// Actualiza el usuario en memoria y notifica a los listeners.
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
