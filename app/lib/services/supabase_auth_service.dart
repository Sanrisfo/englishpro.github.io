import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart' as models;

/// Servicio de Autenticación basado en Supabase para EnglishPro.
///
/// Expone operaciones de alto nivel para registrar, iniciar/cerrar sesión y
/// administrar el estado del usuario contra [SupabaseAuth]. Este servicio
/// también interactúa con la tabla `usuarios` para obtener y actualizar
/// información del perfil del usuario.
///
/// ### Ejemplo de uso:
///
/// ```dart
/// final auth = SupabaseAuthService();
/// final result = await auth.login(email: 'user@mail.com', password: 'secret');
/// if (result['success'] == true) {
///   final user = result['user'] as models.User;
///   // Navegar a la pantalla principal
/// }
/// ```
class SupabaseAuthService {
  final SupabaseClient _supabase;

  /// Crea una instancia del servicio de autenticación.
  ///
  /// Permite inyectar un `SupabaseClient` personalizado para facilitar
  /// las pruebas. Si no se proporciona un cliente, utiliza la instancia
  /// global de Supabase.
  SupabaseAuthService({SupabaseClient? client}) : _supabase = client ?? supabase;


  /// Registra un nuevo usuario en Supabase Auth y en la tabla `usuarios`.
  ///
  /// El proceso consiste en:
  /// 1. Crear el usuario en `SupabaseAuth` con email y contraseña.
  /// 2. Los datos adicionales (`nombre_completo`, `profesion`) se pasan a `data`.
  /// 3. Un trigger en la base de datos se encarga de crear el registro correspondiente en la tabla `usuarios`.
  /// 4. Se obtiene el perfil recién creado de la tabla `usuarios` para devolverlo.
  ///
  /// @param nombreCompleto Nombre y apellidos del usuario.
  /// @param email Correo electrónico único del usuario.
  /// @param password Contraseña del usuario (mínimo 6 caracteres).
  /// @param profesion La profesión del usuario (opcional).
  /// @return Un `Future<Map<String, dynamic>>` que contiene:
  ///         - `success` (bool): `true` si el registro fue exitoso.
  ///         - `user` ([models.User]): El perfil del usuario desde la tabla `usuarios`.
  ///         - `session` ([Session]): La sesión de autenticación.
  ///         o en caso de error:
  ///         - `success` (bool): `false`.
  ///         - `message` (String): Un mensaje descriptivo del error.
  Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String email,
    required String password,
    String? profesion,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre_completo': nombreCompleto,
          'profesion': profesion ?? '',
        },
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Error al crear usuario',
        };
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final userData = await _supabase
          .from('usuarios')
          .select()
          .eq('supabase_uid', authResponse.user!.id)
          .single();

      final user = models.User.fromJson(userData);

      return {
        'success': true,
        'user': user,
        'session': authResponse.session,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Inicia sesión de un usuario existente mediante email y contraseña.
  ///
  /// Después de una autenticación exitosa, obtiene los datos del perfil
  /// del usuario desde la tabla `usuarios`.
  ///
  /// @param email El correo electrónico del usuario.
  /// @param password La contraseña del usuario.
  /// @return Un `Future<Map<String, dynamic>>` que contiene:
  ///         - `success` (bool): `true` si el inicio de sesión fue exitoso.
  ///         - `user` ([models.User]): El perfil del usuario.
  ///         - `session` ([Session]): La sesión de autenticación.
  ///         o en caso de error:
  ///         - `success` (bool): `false`.
  ///         - `message` (String): Un mensaje descriptivo del error.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {
          'success': false,
          'message': 'Credenciales inválidas',
        };
      }

      final userData = await _supabase
          .from('usuarios')
          .select()
          .eq('supabase_uid', response.user!.id)
          .single();

      final user = models.User.fromJson(userData);

      return {
        'success': true,
        'user': user,
        'session': response.session,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Cierra la sesión del usuario actual en el dispositivo.
  ///
  /// Invalida la sesión actual y elimina las credenciales almacenadas localmente.
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Devuelve el usuario de Supabase Auth actualmente autenticado.
  ///
  /// Puede ser `null` si no hay una sesión activa.
  User? get currentUser => _supabase.auth.currentUser;

  /// Indica si existe un usuario autenticado en la sesión actual.
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Devuelve la sesión actual de Supabase, si existe.
  ///
  /// Contiene los tokens de acceso y de refresco.
  Session? get currentSession => _supabase.auth.currentSession;

  /// Un stream que emite eventos sobre cambios en el estado de autenticación.
  ///
  /// Útil para escuchar cambios de sesión (login, logout) en tiempo real.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Envía un correo electrónico al usuario para restablecer su contraseña.
  ///
  /// @param email El correo electrónico del usuario.
  /// @return Un mapa indicando el resultado de la operación.
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);

      return {
        'success': true,
        'message': 'Se ha enviado un email para restablecer tu contraseña',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Actualiza la contraseña del usuario actualmente autenticado.
  ///
  /// @param newPassword La nueva contraseña.
  /// @return Un mapa indicando el resultado de la operación.
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return {
        'success': true,
        'message': 'Contraseña actualizada correctamente',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Traduce mensajes de error comunes de Supabase a un formato más claro en español.
  ///
  /// @param error El mensaje de error original de [AuthException].
  /// @return Un mensaje de error simplificado y traducido.
  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Credenciales inválidas';
    } else if (error.contains('Email not confirmed')) {
      return 'Email no confirmado. Revisa tu bandeja de entrada.';
    } else if (error.contains('User already registered')) {
      return 'El email ya está registrado';
    } else if (error.contains('weak password') ||
               error.contains('Password should be at least 6 characters')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    } else if (error.contains('Invalid email')) {
      return 'Email inválido';
    } else if (error.contains('Email rate limit exceeded')) {
      return 'Demasiados intentos. Intenta más tarde.';
    }
    return error;
  }

  /// Obtiene los datos de un usuario de la tabla `usuarios` por su `id_usuario`.
  ///
  /// @param userId El ID del usuario en la tabla `usuarios`.
  /// @return Un mapa con los datos del perfil del usuario, o `null` si no se encuentra.
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final data = await _supabase
          .from('usuarios')
          .select()
          .eq('id_usuario', userId)
          .single();

      return data;
    } catch (e) {
      return null;
    }
  }

  /// Actualiza campos básicos del perfil de un usuario en la tabla `usuarios`.
  ///
  /// Solo envía los campos no nulos proporcionados en los parámetros.
  ///
  /// @param userId El ID del usuario a actualizar.
  /// @param nombreCompleto El nuevo nombre completo del usuario (opcional).
  /// @param profesion La nueva profesión del usuario (opcional).
  /// @return Un mapa indicando el resultado de la operación.
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    String? nombreCompleto,
    String? profesion,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nombreCompleto != null) updates['nombre_completo'] = nombreCompleto;
      if (profesion != null) updates['profesion'] = profesion;

      await _supabase
          .from('usuarios')
          .update(updates)
          .eq('id_usuario', userId);

      return {
        'success': true,
        'message': 'Perfil actualizado correctamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al actualizar perfil: ${e.toString()}',
      };
    }
  }
}
