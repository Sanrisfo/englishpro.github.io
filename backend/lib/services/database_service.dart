import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _log = Logger('DatabaseService');
  Connection? _connection;

  Future<void> connect() async {
    try {
      // Intentar cargar .env pero no fallar si no existe (para Docker)
      try {
        final env = DotEnv()..load();
      } catch (e) {
        _log.info('No .env file found, using environment variables');
      }

      // Usar variables de entorno del sistema (para Docker) o .env
      final host = Platform.environment['DB_HOST'] ?? 'localhost';
      final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
      final database = Platform.environment['DB_NAME'] ?? 'englishpro_db';
      final username = Platform.environment['DB_USER'] ?? 'admin';
      final password = Platform.environment['DB_PASSWORD'] ?? 'admin123';

      _connection = await Connection.open(
        Endpoint(
          host: host,
          port: port,
          database: database,
          username: username,
          password: password,
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );

      _log.info('✅ Database connected successfully to $host:$port/$database');
    } catch (e) {
      _log.severe('❌ Database connection failed: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _log.info('Database disconnected');
  }

  Connection get connection {
    if (_connection == null) {
      throw Exception('Database not connected. Call connect() first.');
    }
    return _connection!;
  }

  Future<Connection> getConnection() async {
    if (_connection == null) {
      await connect();
    }
    return _connection!;
  }

  Future<Result> execute(
    String query, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      return await connection.execute(
        Sql.named(query),
        parameters: parameters ?? {},
      );
    } catch (e) {
      _log.severe('Query execution failed: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String query, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final result = await connection.execute(
        Sql.named(query),
        parameters: parameters ?? {},
      );

      return result.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < result.schema.columns.length; i++) {
          final columnName = result.schema.columns[i].columnName ?? 'column_$i';
          map[columnName] = row[i];
        }
        return map;
      }).toList();
    } catch (e) {
      _log.severe('Query failed: $e');
      rethrow;
    }
  }
}
