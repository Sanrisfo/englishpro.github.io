import 'package:flutter_test/flutter_test.dart';
import 'package:englishpro_app/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson should correctly parse JSON', () {
      final json = {
        'id_usuario': 1,
        'nombre_completo': 'John Doe',
        'email': 'john@example.com',
        'profesion': 'Engineer',
        'id_plan': 2,
        'es_docente': false,
        'rol': 'Estudiante',
        'fecha_registro': '2024-01-01T00:00:00.000Z',
        'ultimo_acceso': '2024-01-15T12:00:00.000Z',
        'firebase_uid': 'firebase123',
        'email_verificado': true,
      };

      final user = User.fromJson(json);

      expect(user.idUsuario, 1);
      expect(user.nombreCompleto, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.profesion, 'Engineer');
      expect(user.idPlan, 2);
      expect(user.esDocente, false);
      expect(user.rol, 'Estudiante');
      expect(user.firebaseUid, 'firebase123');
      expect(user.emailVerificado, true);
    });

    test('User.toJson should correctly convert to JSON', () {
      final user = User(
        idUsuario: 1,
        nombreCompleto: 'Jane Smith',
        email: 'jane@example.com',
        profesion: 'Teacher',
        idPlan: 3,
        esDocente: true,
        rol: 'Docente',
        fechaRegistro: DateTime.parse('2024-01-01T00:00:00.000Z'),
        ultimoAcceso: DateTime.parse('2024-01-15T12:00:00.000Z'),
        firebaseUid: 'firebase456',
        emailVerificado: true,
      );

      final json = user.toJson();

      expect(json['id_usuario'], 1);
      expect(json['nombre_completo'], 'Jane Smith');
      expect(json['email'], 'jane@example.com');
      expect(json['profesion'], 'Teacher');
      expect(json['id_plan'], 3);
      expect(json['es_docente'], true);
      expect(json['rol'], 'Docente');
      expect(json['firebase_uid'], 'firebase456');
      expect(json['email_verificado'], true);
    });

    test('User should have default values', () {
      final user = User(
        idUsuario: 1,
        nombreCompleto: 'Test User',
        email: 'test@example.com',
        idPlan: 1,
      );

      expect(user.esDocente, false);
      expect(user.rol, 'Estudiante');
      expect(user.emailVerificado, false);
      expect(user.profesion, null);
      expect(user.firebaseUid, null);
    });

    test('User.fromJson should handle missing optional fields', () {
      final json = {
        'id_usuario': 1,
        'nombre_completo': 'Minimal User',
        'email': 'minimal@example.com',
      };

      final user = User.fromJson(json);

      expect(user.idUsuario, 1);
      expect(user.nombreCompleto, 'Minimal User');
      expect(user.email, 'minimal@example.com');
      expect(user.idPlan, 1); // default
      expect(user.esDocente, false); // default
      expect(user.rol, 'Estudiante'); // default
      expect(user.emailVerificado, false); // default
    });
  });
}
