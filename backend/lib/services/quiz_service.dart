import 'package:postgres/postgres.dart';
import '../models/quiz_model.dart';

class QuizService {
  final Connection _db;

  QuizService(this._db);

  // ========== QUIZZES ==========

  /// Get all quizzes
  Future<List<Quiz>> getAllQuizzes() async {
    final result = await _db.execute('''
      SELECT * FROM Cuestionarios
      ORDER BY fecha_creacion DESC
    ''');

    return result.map((row) => Quiz.fromMap(row.toColumnMap())).toList();
  }

  /// Get quiz by ID
  Future<Quiz?> getQuizById(int id) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Cuestionarios WHERE id_cuestionario = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return Quiz.fromMap(result.first.toColumnMap());
  }

  /// Get quizzes by skill ID
  Future<List<Quiz>> getQuizzesBySkillId(int skillId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Cuestionarios WHERE id_habilidad = @skillId ORDER BY fecha_creacion DESC'),
      parameters: {'skillId': skillId},
    );

    return result.map((row) => Quiz.fromMap(row.toColumnMap())).toList();
  }

  /// Get quizzes by filters
  Future<List<Quiz>> getQuizzesByFilters({
    int? skillId,
    String? difficulty,
    String? accessLevel,
  }) async {
    final conditions = <String>[];
    final parameters = <String, dynamic>{};

    if (skillId != null) {
      conditions.add('id_habilidad = @skillId');
      parameters['skillId'] = skillId;
    }
    if (difficulty != null) {
      conditions.add('nivel_dificultad = @difficulty');
      parameters['difficulty'] = difficulty;
    }
    if (accessLevel != null) {
      conditions.add('nivel_acceso = @accessLevel');
      parameters['accessLevel'] = accessLevel;
    }

    final whereClause = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    final result = await _db.execute(
      Sql.named('SELECT * FROM Cuestionarios $whereClause ORDER BY fecha_creacion DESC'),
      parameters: parameters,
    );

    return result.map((row) => Quiz.fromMap(row.toColumnMap())).toList();
  }

  /// Create new quiz
  Future<Quiz> createQuiz(Quiz quiz) async {
    final result = await _db.execute(
      Sql.named('''
      INSERT INTO Cuestionarios (
        id_habilidad, titulo, descripcion, duracion_minutos,
        puntos_totales, nivel_dificultad, nivel_acceso, creado_por
      ) VALUES (
        @habilidadId, @titulo, @descripcion, @duracionMinutos,
        @puntosTotales, @nivelDificultad, @nivelAcceso, @creadoPor
      )
      RETURNING *
      '''),
      parameters: {
        'habilidadId': quiz.habilidadId,
        'titulo': quiz.titulo,
        'descripcion': quiz.descripcion,
        'duracionMinutos': quiz.duracionMinutos,
        'puntosTotales': quiz.puntosTotales,
        'nivelDificultad': quiz.nivelDificultad,
        'nivelAcceso': quiz.nivelAcceso,
        'creadoPor': quiz.creadoPor,
      },
    );

    return Quiz.fromMap(result.first.toColumnMap());
  }

  /// Update quiz
  Future<Quiz?> updateQuiz(int id, Quiz quiz) async {
    final result = await _db.execute(
      Sql.named('''
      UPDATE Cuestionarios SET
        id_habilidad = @habilidadId,
        titulo = @titulo,
        descripcion = @descripcion,
        duracion_minutos = @duracionMinutos,
        puntos_totales = @puntosTotales,
        nivel_dificultad = @nivelDificultad,
        nivel_acceso = @nivelAcceso
      WHERE id_cuestionario = @id
      RETURNING *
      '''),
      parameters: {
        'id': id,
        'habilidadId': quiz.habilidadId,
        'titulo': quiz.titulo,
        'descripcion': quiz.descripcion,
        'duracionMinutos': quiz.duracionMinutos,
        'puntosTotales': quiz.puntosTotales,
        'nivelDificultad': quiz.nivelDificultad,
        'nivelAcceso': quiz.nivelAcceso,
      },
    );

    if (result.isEmpty) return null;
    return Quiz.fromMap(result.first.toColumnMap());
  }

  /// Delete quiz
  Future<bool> deleteQuiz(int id) async {
    final result = await _db.execute(
      Sql.named('DELETE FROM Cuestionarios WHERE id_cuestionario = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // ========== QUIZ QUESTIONS ==========

  /// Get questions for a quiz
  Future<List<QuizQuestion>> getQuizQuestions(int quizId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Cuestionario_Preguntas WHERE id_cuestionario = @quizId ORDER BY orden'),
      parameters: {'quizId': quizId},
    );

    return result.map((row) => QuizQuestion.fromMap(row.toColumnMap())).toList();
  }

  /// Add question to quiz
  Future<QuizQuestion> addQuestionToQuiz(QuizQuestion quizQuestion) async {
    final result = await _db.execute(
      Sql.named('''
      INSERT INTO Cuestionario_Preguntas (
        id_cuestionario, id_pregunta, orden
      ) VALUES (
        @cuestionarioId, @preguntaId, @orden
      )
      RETURNING *
      '''),
      parameters: {
        'cuestionarioId': quizQuestion.cuestionarioId,
        'preguntaId': quizQuestion.preguntaId,
        'orden': quizQuestion.orden,
      },
    );

    return QuizQuestion.fromMap(result.first.toColumnMap());
  }

  /// Update question order in quiz
  Future<QuizQuestion?> updateQuizQuestionOrder(int id, int orden) async {
    final result = await _db.execute(
      Sql.named('''
      UPDATE Cuestionario_Preguntas SET
        orden = @orden
      WHERE id_cuestionario_pregunta = @id
      RETURNING *
      '''),
      parameters: {'id': id, 'orden': orden},
    );

    if (result.isEmpty) return null;
    return QuizQuestion.fromMap(result.first.toColumnMap());
  }

  /// Remove question from quiz
  Future<bool> removeQuestionFromQuiz(int id) async {
    final result = await _db.execute(
      Sql.named('DELETE FROM Cuestionario_Preguntas WHERE id_cuestionario_pregunta = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // ========== QUIZ ATTEMPTS ==========

  /// Get all attempts for a user
  Future<List<QuizAttempt>> getUserAttempts(int userId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Intentos_Cuestionario WHERE id_usuario = @userId ORDER BY fecha_inicio DESC'),
      parameters: {'userId': userId},
    );

    return result.map((row) => QuizAttempt.fromMap(row.toColumnMap())).toList();
  }

  /// Get attempt by ID
  Future<QuizAttempt?> getAttemptById(int id) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Intentos_Cuestionario WHERE id_intento = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return QuizAttempt.fromMap(result.first.toColumnMap());
  }

  /// Get attempts for a specific quiz
  Future<List<QuizAttempt>> getQuizAttempts(int quizId, {int? userId}) async {
    if (userId != null) {
      final result = await _db.execute(
        Sql.named('''
        SELECT * FROM Intentos_Cuestionario
        WHERE id_cuestionario = @quizId AND id_usuario = @userId
        ORDER BY fecha_inicio DESC
        '''),
        parameters: {'quizId': quizId, 'userId': userId},
      );
      return result.map((row) => QuizAttempt.fromMap(row.toColumnMap())).toList();
    }

    final result = await _db.execute(
      Sql.named('SELECT * FROM Intentos_Cuestionario WHERE id_cuestionario = @quizId ORDER BY fecha_inicio DESC'),
      parameters: {'quizId': quizId},
    );

    return result.map((row) => QuizAttempt.fromMap(row.toColumnMap())).toList();
  }

  /// Create new attempt
  Future<QuizAttempt> createAttempt(QuizAttempt attempt) async {
    final result = await _db.execute(
      Sql.named('''
      INSERT INTO Intentos_Cuestionario (
        id_usuario, id_cuestionario, puntos_totales, estado
      ) VALUES (
        @usuarioId, @cuestionarioId, @puntosTotales, @estado
      )
      RETURNING *
      '''),
      parameters: {
        'usuarioId': attempt.usuarioId,
        'cuestionarioId': attempt.cuestionarioId,
        'puntosTotales': attempt.puntosTotales,
        'estado': attempt.estado,
      },
    );

    return QuizAttempt.fromMap(result.first.toColumnMap());
  }

  /// Update attempt (for completion)
  Future<QuizAttempt?> updateAttempt(int id, {
    DateTime? fechaFin,
    int? puntosObtenidos,
    double? porcentaje,
    String? estado,
  }) async {
    final updates = <String>[];
    final parameters = <String, dynamic>{'id': id};

    if (fechaFin != null) {
      updates.add('fecha_fin = @fechaFin');
      parameters['fechaFin'] = fechaFin.toIso8601String();
    }
    if (puntosObtenidos != null) {
      updates.add('puntos_obtenidos = @puntosObtenidos');
      parameters['puntosObtenidos'] = puntosObtenidos;
    }
    if (porcentaje != null) {
      updates.add('porcentaje = @porcentaje');
      parameters['porcentaje'] = porcentaje;
    }
    if (estado != null) {
      updates.add('estado = @estado');
      parameters['estado'] = estado;
    }

    if (updates.isEmpty) return getAttemptById(id);

    final result = await _db.execute(
      Sql.named('''
      UPDATE Intentos_Cuestionario SET
        ${updates.join(', ')}
      WHERE id_intento = @id
      RETURNING *
      '''),
      parameters: parameters,
    );

    if (result.isEmpty) return null;
    return QuizAttempt.fromMap(result.first.toColumnMap());
  }

  /// Delete attempt
  Future<bool> deleteAttempt(int id) async {
    final result = await _db.execute(
      Sql.named('DELETE FROM Intentos_Cuestionario WHERE id_intento = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  /// Get user's best attempt for a quiz
  Future<QuizAttempt?> getBestAttempt(int userId, int quizId) async {
    final result = await _db.execute(
      Sql.named('''
      SELECT * FROM Intentos_Cuestionario
      WHERE id_usuario = @userId AND id_cuestionario = @quizId
      AND estado = 'Completado'
      ORDER BY porcentaje DESC, puntos_obtenidos DESC
      LIMIT 1
      '''),
      parameters: {'userId': userId, 'quizId': quizId},
    );

    if (result.isEmpty) return null;
    return QuizAttempt.fromMap(result.first.toColumnMap());
  }
}
