import 'package:postgres/postgres.dart';
import '../models/skill_model.dart';
import 'database_service.dart';

class SkillService {
  final DatabaseService _db = DatabaseService();

  /// Get all skills
  Future<List<Skill>> getAllSkills() async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        'SELECT * FROM Habilidades ORDER BY ID_Curso, Orden ASC',
      );

      return results.map((row) {
        return Skill.fromMap({
          'id': row[0],
          'curso_id': row[1],
          'nombre': row[2],
          'descripcion': row[3],
          'orden': row[4],
        });
      }).toList();
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Get skills by course ID
  Future<List<Skill>> getSkillsByCourseId(int courseId) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('SELECT * FROM Habilidades WHERE ID_Curso = @course_id ORDER BY Orden ASC'),
        parameters: {'course_id': courseId},
      );

      return results.map((row) {
        return Skill.fromMap({
          'id': row[0],
          'curso_id': row[1],
          'nombre': row[2],
          'descripcion': row[3],
          'orden': row[4],
        });
      }).toList();
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Get skill by ID
  Future<Skill?> getSkillById(int id) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('SELECT * FROM Habilidades WHERE ID_Habilidad = @id'),
        parameters: {'id': id},
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return Skill.fromMap({
        'id': row[0],
        'curso_id': row[1],
        'nombre': row[2],
        'descripcion': row[3],
        'orden': row[4],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Create new skill
  Future<Skill> createSkill(Skill skill) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('''
          INSERT INTO Habilidades (ID_Curso, Nombre_Habilidad, Descripcion, Orden)
          VALUES (@curso_id, @nombre, @descripcion, @orden)
          RETURNING *
        '''),
        parameters: {
          'curso_id': skill.cursoId,
          'nombre': skill.nombre,
          'descripcion': skill.descripcion,
          'orden': skill.orden,
        },
      );

      final row = results.first;
      return Skill.fromMap({
        'id': row[0],
        'curso_id': row[1],
        'nombre': row[2],
        'descripcion': row[3],
        'orden': row[4],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Update skill
  Future<Skill?> updateSkill(int id, Skill skill) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('''
          UPDATE Habilidades
          SET ID_Curso = @curso_id,
              Nombre_Habilidad = @nombre,
              Descripcion = @descripcion,
              Orden = @orden
          WHERE ID_Habilidad = @id
          RETURNING *
        '''),
        parameters: {
          'id': id,
          'curso_id': skill.cursoId,
          'nombre': skill.nombre,
          'descripcion': skill.descripcion,
          'orden': skill.orden,
        },
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return Skill.fromMap({
        'id': row[0],
        'curso_id': row[1],
        'nombre': row[2],
        'descripcion': row[3],
        'orden': row[4],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Delete skill
  Future<bool> deleteSkill(int id) async {
    final conn = await _db.getConnection();

    try {
      final result = await conn.execute(
        Sql.named('DELETE FROM Habilidades WHERE ID_Habilidad = @id'),
        parameters: {'id': id},
      );

      return result.affectedRows > 0;
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }
}
