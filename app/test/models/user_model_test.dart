import 'package:englishpro_app/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('User.fromJson handles upper/lower case keys', () {
    final jsonUpper = {
      'ID_Usuario': 7,
      'Nombre_Completo': 'Upper Case',
      'Email': 'upper@example.com',
      'Es_Docente': true,
      'Rol': 'Docente',
    };
    final u1 = User.fromJson(jsonUpper);
    expect(u1.idUsuario, 7);
    expect(u1.nombreCompleto, 'Upper Case');
    expect(u1.email, 'upper@example.com');
    expect(u1.esDocente, true);
    expect(u1.rol, 'Docente');

    final jsonLower = {
      'id_usuario': 8,
      'nombre_completo': 'Lower Case',
      'email': 'lower@example.com',
      'es_docente': false,
      'rol': 'Estudiante',
    };
    final u2 = User.fromJson(jsonLower);
    expect(u2.idUsuario, 8);
    expect(u2.nombreCompleto, 'Lower Case');
    expect(u2.esDocente, false);
    expect(u2.rol, 'Estudiante');
  });

  test('User.toJson maps expected fields', () {
    final user = User(
      idUsuario: 1,
      nombreCompleto: 'Test',
      email: 't@e.com',
      idPlan: 1,
    );
    final json = user.toJson();
    expect(json['id_usuario'], 1);
    expect(json['nombre_completo'], 'Test');
    expect(json['email'], 't@e.com');
  });
}

