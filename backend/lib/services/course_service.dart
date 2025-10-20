import 'package:postgres/postgres.dart';
import '../models/course_model.dart';
import 'database_service.dart';

class CourseService {
  final DatabaseService _db = DatabaseService();

  /// Get all courses
  Future<List<Course>> getAllCourses() async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        'SELECT ID_Curso, Nombre_Curso, Descripcion, Tipo_Curso, Estilo_Progreso, URL_Imagen, Fecha_Creacion, Activo FROM Cursos ORDER BY ID_Curso ASC',
      );

      return results.map((row) {
        return Course.fromMap({
          'id': row[0],
          'nombre': row[1],
          'descripcion': row[2],
          'tipo_curso': row[3],
          'estilo_progreso': row[4],
          'url_imagen': row[5],
          'fecha_creacion': row[6]?.toString(),
          'activo': row[7],
        });
      }).toList();
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Get course by ID
  Future<Course?> getCourseById(int id) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('SELECT ID_Curso, Nombre_Curso, Descripcion, Tipo_Curso, Estilo_Progreso, URL_Imagen, Fecha_Creacion, Activo FROM Cursos WHERE ID_Curso = @id'),
        parameters: {'id': id},
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return Course.fromMap({
        'id': row[0],
        'nombre': row[1],
        'descripcion': row[2],
        'tipo_curso': row[3],
        'estilo_progreso': row[4],
        'url_imagen': row[5],
        'fecha_creacion': row[6]?.toString(),
        'activo': row[7],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Create new course
  Future<Course> createCourse(Course course) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('''
          INSERT INTO Cursos (Nombre_Curso, Descripcion, Tipo_Curso, Estilo_Progreso, URL_Imagen, Activo)
          VALUES (@nombre, @descripcion, @tipo_curso, @estilo_progreso, @url_imagen, @activo)
          RETURNING ID_Curso, Nombre_Curso, Descripcion, Tipo_Curso, Estilo_Progreso, URL_Imagen, Fecha_Creacion, Activo
        '''),
        parameters: {
          'nombre': course.nombre,
          'descripcion': course.descripcion,
          'tipo_curso': course.tipoCurso,
          'estilo_progreso': course.estiloProgreso,
          'url_imagen': course.urlImagen,
          'activo': course.activo,
        },
      );

      final row = results.first;
      return Course.fromMap({
        'id': row[0],
        'nombre': row[1],
        'descripcion': row[2],
        'tipo_curso': row[3],
        'estilo_progreso': row[4],
        'url_imagen': row[5],
        'fecha_creacion': row[6]?.toString(),
        'activo': row[7],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Update course
  Future<Course?> updateCourse(int id, Course course) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('''
          UPDATE Cursos
          SET Nombre_Curso = @nombre,
              Descripcion = @descripcion,
              Tipo_Curso = @tipo_curso,
              Estilo_Progreso = @estilo_progreso,
              URL_Imagen = @url_imagen,
              Activo = @activo
          WHERE ID_Curso = @id
          RETURNING ID_Curso, Nombre_Curso, Descripcion, Tipo_Curso, Estilo_Progreso, URL_Imagen, Fecha_Creacion, Activo
        '''),
        parameters: {
          'id': id,
          'nombre': course.nombre,
          'descripcion': course.descripcion,
          'tipo_curso': course.tipoCurso,
          'estilo_progreso': course.estiloProgreso,
          'url_imagen': course.urlImagen,
          'activo': course.activo,
        },
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return Course.fromMap({
        'id': row[0],
        'nombre': row[1],
        'descripcion': row[2],
        'tipo_curso': row[3],
        'estilo_progreso': row[4],
        'url_imagen': row[5],
        'fecha_creacion': row[6]?.toString(),
        'activo': row[7],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Delete course
  Future<bool> deleteCourse(int id) async {
    final conn = await _db.getConnection();

    try {
      final result = await conn.execute(
        Sql.named('DELETE FROM Cursos WHERE ID_Curso = @id'),
        parameters: {'id': id},
      );

      return result.affectedRows > 0;
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }
}
