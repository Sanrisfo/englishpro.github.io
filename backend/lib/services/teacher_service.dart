import 'package:postgres/postgres.dart';
import '../models/teacher_model.dart';

class TeacherService {
  final Connection _connection;

  TeacherService(this._connection);

  // Crear nuevo docente
  Future<Teacher> createTeacher(Teacher teacher) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO Docentes (
          id_usuario, especialidad, certificaciones,
          anos_experiencia, activo, fecha_registro
        ) VALUES (
          @id_usuario, @especialidad, @certificaciones,
          @anos_experiencia, @activo, @fecha_registro
        ) RETURNING id_docente, fecha_registro
      '''),
      parameters: {
        'id_usuario': teacher.usuarioId,
        'especialidad': teacher.especialidad,
        'certificaciones': teacher.certificaciones,
        'anos_experiencia': teacher.aniosExperiencia,
        'activo': teacher.activo,
        'fecha_registro': teacher.fechaRegistro ?? DateTime.now(),
      },
    );

    final row = result.first;
    return Teacher(
      id: row[0] as int,
      usuarioId: teacher.usuarioId,
      especialidad: teacher.especialidad,
      certificaciones: teacher.certificaciones,
      aniosExperiencia: teacher.aniosExperiencia,
      activo: teacher.activo,
      fechaRegistro: row[1] as DateTime,
    );
  }

  // Obtener docente por ID
  Future<Teacher?> getTeacherById(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          id_docente, id_usuario, especialidad, certificaciones,
          anos_experiencia, activo, fecha_registro
        FROM Docentes
        WHERE id_docente = @id
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return Teacher(
      id: row[0] as int,
      usuarioId: row[1] as int,
      especialidad: row[2] as String,
      certificaciones: row[3] as String?,
      aniosExperiencia: row[4] as int,
      activo: row[5] as bool,
      fechaRegistro: row[6] as DateTime?,
    );
  }

  // Obtener docente por usuario ID
  Future<Teacher?> getTeacherByUserId(int userId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          id_docente, id_usuario, especialidad, certificaciones,
          anos_experiencia
        FROM Docentes
        WHERE id_usuario = @userId
      '''),
      parameters: {'userId': userId},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return Teacher(
      id: row[0] as int,
      usuarioId: row[1] as int,
      especialidad: row[2] as String,
      certificaciones: row[3] as String?,
      aniosExperiencia: row[4] as int,
    );
  }

  // Obtener todos los docentes
  Future<List<Teacher>> getAllTeachers({bool? activo}) async {
    String query = '''
      SELECT
        id_docente, id_usuario, especialidad, certificaciones,
        anos_experiencia, activo, fecha_registro
      FROM Docentes
    ''';

    Map<String, dynamic> parameters = {};

    if (activo != null) {
      query += ' WHERE activo = @activo';
      parameters['activo'] = activo;
    }

    query += ' ORDER BY fecha_registro DESC';

    final result = await _connection.execute(
      Sql.named(query),
      parameters: parameters,
    );

    return result.map((row) => Teacher(
      id: row[0] as int,
      usuarioId: row[1] as int,
      especialidad: row[2] as String,
      certificaciones: row[3] as String?,
      aniosExperiencia: row[4] as int,
      activo: row[5] as bool,
      fechaRegistro: row[6] as DateTime?,
    )).toList();
  }

  // Actualizar docente
  Future<bool> updateTeacher(int id, Map<String, dynamic> updates) async {
    final setClause = updates.keys.map((key) => '$key = @$key').join(', ');

    final result = await _connection.execute(
      Sql.named('''
        UPDATE Docentes
        SET $setClause
        WHERE id_docente = @id
      '''),
      parameters: {'id': id, ...updates},
    );

    return result.affectedRows > 0;
  }

  // Desactivar docente
  Future<bool> deactivateTeacher(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE Docentes
        SET activo = FALSE
        WHERE id_docente = @id
      '''),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // Activar docente
  Future<bool> activateTeacher(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE Docentes
        SET activo = TRUE
        WHERE id_docente = @id
      '''),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // Eliminar docente
  Future<bool> deleteTeacher(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        DELETE FROM Docentes
        WHERE id_docente = @id
      '''),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // Obtener estadísticas del docente
  Future<Map<String, dynamic>> getTeacherStats(int teacherId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          COUNT(*) as total_calificaciones,
          COUNT(CASE WHEN estado = 'Calificada' THEN 1 END) as calificadas,
          COUNT(CASE WHEN estado = 'Pendiente' THEN 1 END) as pendientes,
          AVG(CASE WHEN puntuacion IS NOT NULL THEN puntuacion END) as promedio_puntuacion
        FROM Retroalimentacion
        WHERE id_docente = @teacherId
      '''),
      parameters: {'teacherId': teacherId},
    );

    if (result.isEmpty) {
      return {
        'total_calificaciones': 0,
        'calificadas': 0,
        'pendientes': 0,
        'promedio_puntuacion': 0.0,
      };
    }

    final row = result.first;
    return {
      'total_calificaciones': row[0] as int,
      'calificadas': row[1] as int,
      'pendientes': row[2] as int,
      'promedio_puntuacion': row[3] != null ? (row[3] as num).toDouble() : 0.0,
    };
  }

  // Obtener docentes por especialidad
  Future<List<Teacher>> getTeachersBySpecialty(String especialidad) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          id_docente, id_usuario, especialidad, certificaciones,
          anos_experiencia, activo, fecha_registro
        FROM Docentes
        WHERE especialidad = @especialidad AND activo = TRUE
        ORDER BY anos_experiencia DESC
      '''),
      parameters: {'especialidad': especialidad},
    );

    return result.map((row) => Teacher(
      id: row[0] as int,
      usuarioId: row[1] as int,
      especialidad: row[2] as String,
      certificaciones: row[3] as String?,
      aniosExperiencia: row[4] as int,
      activo: row[5] as bool,
      fechaRegistro: row[6] as DateTime?,
    )).toList();
  }
}
