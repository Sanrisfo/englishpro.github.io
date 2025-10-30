import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart' as models;

/// Supabase Authentication Service for EnglishPro
///
/// Handles user registration, login, logout, and session management
/// using Supabase Auth and PostgreSQL database.
class SupabaseAuthService {
  final _supabase = supabase;

  // ==================== REGISTRATION ====================

  /// Register a new user with Supabase
  ///
  /// The trigger `handle_new_user()` in Supabase will automatically
  /// create a record in the Usuarios table when a user signs up.
  Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String email,
    required String password,
    String? profesion,
  }) async {
    try {
      // 1. Create user in Supabase Auth
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

      // 2. Wait a moment for trigger to execute
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Get user data from usuarios table (lowercase in Supabase)
      final userData = await _supabase
          .from('usuarios')
          .select()
          .eq('supabase_uid', authResponse.user!.id)
          .single();

      // 4. Convert to User model using fromJson
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

  // ==================== LOGIN ====================

  /// Login user with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Supabase Auth
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

      // 2. Get user data from usuarios table (lowercase in Supabase)
      final userData = await _supabase
          .from('usuarios')
          .select()
          .eq('supabase_uid', response.user!.id)
          .single();

      // 3. Convert to User model using fromJson
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

  // ==================== LOGOUT ====================

  /// Logout current user
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // ==================== CURRENT USER ====================

  /// Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // ==================== AUTH STATE CHANGES ====================

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ==================== PASSWORD RECOVERY ====================

  /// Send password recovery email
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

  /// Update user password
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

  // ==================== HELPER METHODS ====================

  /// Translate error messages to Spanish
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

  /// Get user by ID from database
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

  /// Update user profile in database
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
