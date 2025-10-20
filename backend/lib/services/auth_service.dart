import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logging/logging.dart';
import 'package:dotenv/dotenv.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final _log = Logger('AuthService');
  final _db = DatabaseService();
  late final String _jwtSecret;

  AuthService() {
    final env = DotEnv()..load();
    _jwtSecret = env['JWT_SECRET'] ?? 'englishpro_secret_key_2024';
  }

  // Hash password
  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  // Verify password
  bool verifyPassword(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }

  // Generate JWT token
  String generateToken(User user) {
    final jwt = JWT({
      'id': user.idUsuario,
      'email': user.email,
      'nombre': user.nombreCompleto,
      'es_docente': user.esDocente,
      'rol': user.rol,
      'id_plan': user.idPlan,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    });

    return jwt.sign(SecretKey(_jwtSecret));
  }

  // Verify JWT token
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      _log.warning('Invalid token: $e');
      return null;
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String email,
    required String password,
    String? profesion,
    String? firebaseUid,
  }) async {
    try {
      // Check if email already exists
      final existingUsers = await _db.query(
        'SELECT * FROM Usuarios WHERE email = @email',
        parameters: {'email': email},
      );

      if (existingUsers.isNotEmpty) {
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      // Hash password
      final passwordHash = hashPassword(password);

      // Insert new user
      final result = await _db.query(
        '''
        INSERT INTO Usuarios (nombre_completo, email, password_hash, profesion, firebase_uid, id_plan, es_docente, rol)
        VALUES (@nombre, @email, @password, @profesion, @firebase_uid, 1, false, 'Estudiante')
        RETURNING *
        ''',
        parameters: {
          'nombre': nombreCompleto,
          'email': email,
          'password': passwordHash,
          'profesion': profesion,
          'firebase_uid': firebaseUid,
        },
      );

      if (result.isEmpty) {
        return {
          'success': false,
          'message': 'Failed to create user',
        };
      }

      final user = User.fromJson(result.first);

      // Create beneficios entry for the user
      await _db.execute(
        'INSERT INTO Beneficios_Usuario (id_usuario) VALUES (@id_usuario)',
        parameters: {'id_usuario': user.idUsuario},
      );

      final token = generateToken(user);

      _log.info('✅ User registered: ${user.email}');

      return {
        'success': true,
        'message': 'User registered successfully',
        'user': user.toJson(),
        'token': token,
      };
    } catch (e) {
      _log.severe('Registration failed: $e');
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Find user by email
      final result = await _db.query(
        'SELECT * FROM Usuarios WHERE email = @email',
        parameters: {'email': email},
      );

      if (result.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }

      final userData = result.first;
      final passwordHash = userData['password_hash'] as String;

      // Verify password
      if (!verifyPassword(password, passwordHash)) {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }

      final user = User.fromJson(userData);

      // Update last access
      await _db.execute(
        'UPDATE Usuarios SET ultimo_acceso = CURRENT_TIMESTAMP WHERE id_usuario = @id',
        parameters: {'id': user.idUsuario},
      );

      final token = generateToken(user);

      _log.info('✅ User logged in: ${user.email}');

      return {
        'success': true,
        'message': 'Login successful',
        'user': user.toJson(),
        'token': token,
      };
    } catch (e) {
      _log.severe('Login failed: $e');
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Get user by ID
  Future<User?> getUserById(int userId) async {
    try {
      final result = await _db.query(
        'SELECT * FROM Usuarios WHERE id_usuario = @id',
        parameters: {'id': userId},
      );

      if (result.isEmpty) return null;
      return User.fromJson(result.first);
    } catch (e) {
      _log.severe('Get user failed: $e');
      return null;
    }
  }

  // Get user by Firebase UID
  Future<User?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final result = await _db.query(
        'SELECT * FROM Usuarios WHERE firebase_uid = @uid',
        parameters: {'uid': firebaseUid},
      );

      if (result.isEmpty) return null;
      return User.fromJson(result.first);
    } catch (e) {
      _log.severe('Get user by Firebase UID failed: $e');
      return null;
    }
  }
}
