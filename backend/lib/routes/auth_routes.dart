import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_service.dart';

class AuthRoutes {
  final _authService = AuthService();

  Router get router {
    final router = Router();

    // POST /api/auth/register
    router.post('/register', _register);

    // POST /api/auth/login
    router.post('/login', _login);

    // GET /api/auth/me (requires token)
    router.get('/me', _getCurrentUser);

    return router;
  }

  Future<Response> _register(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final nombreCompleto = data['nombre_completo'] as String?;
      final email = data['email'] as String?;
      final password = data['password'] as String?;
      final profesion = data['profesion'] as String?;
      final firebaseUid = data['firebase_uid'] as String?;

      // Validate required fields
      if (nombreCompleto == null || nombreCompleto.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'nombre_completo is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'email is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (password == null || password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'password is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Register user
      final result = await _authService.register(
        nombreCompleto: nombreCompleto,
        email: email,
        password: password,
        profesion: profesion,
        firebaseUid: firebaseUid,
      );

      if (result['success'] == true) {
        return Response.ok(
          jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response(
          400,
          body: jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final password = data['password'] as String?;

      // Validate required fields
      if (email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'email is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (password == null || password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'password is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Login user
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        return Response.ok(
          jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response(
          401,
          body: jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getCurrentUser(Request request) async {
    try {
      // Get token from Authorization header
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({'success': false, 'message': 'No token provided'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7); // Remove 'Bearer '
      final payload = _authService.verifyToken(token);

      if (payload == null) {
        return Response(
          401,
          body: jsonEncode({'success': false, 'message': 'Invalid token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final userId = payload['id'] as int;
      final user = await _authService.getUserById(userId);

      if (user == null) {
        return Response(
          404,
          body: jsonEncode({'success': false, 'message': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'user': user.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
