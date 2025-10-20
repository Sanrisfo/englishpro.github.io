import 'package:postgres/postgres.dart';
import '../models/question_model.dart';

class QuestionService {
  final Connection _db;

  QuestionService(this._db);

  // ========== QUESTIONS ==========

  /// Get all questions
  Future<List<Question>> getAllQuestions() async {
    final result = await _db.execute('''
      SELECT * FROM Preguntas
      ORDER BY fecha_creacion DESC
    ''');

    return result.map((row) => Question.fromMap(row.toColumnMap())).toList();
  }

  /// Get question by ID
  Future<Question?> getQuestionById(int id) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Preguntas WHERE id_pregunta = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return Question.fromMap(result.first.toColumnMap());
  }

  /// Get questions by skill ID
  Future<List<Question>> getQuestionsBySkillId(int skillId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Preguntas WHERE id_habilidad = @skillId ORDER BY fecha_creacion DESC'),
      parameters: {'skillId': skillId},
    );

    return result.map((row) => Question.fromMap(row.toColumnMap())).toList();
  }

  /// Get questions by filters (difficulty, type, access level)
  Future<List<Question>> getQuestionsByFilters({
    int? skillId,
    String? difficulty,
    String? type,
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
    if (type != null) {
      conditions.add('tipo_pregunta = @type');
      parameters['type'] = type;
    }
    if (accessLevel != null) {
      conditions.add('nivel_acceso = @accessLevel');
      parameters['accessLevel'] = accessLevel;
    }

    final whereClause = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    final result = await _db.execute(
      Sql.named('SELECT * FROM Preguntas $whereClause ORDER BY fecha_creacion DESC'),
      parameters: parameters,
    );

    return result.map((row) => Question.fromMap(row.toColumnMap())).toList();
  }

  /// Create new question
  Future<Question> createQuestion(Question question) async {
    final result = await _db.execute(
      Sql.named('''
      INSERT INTO Preguntas (
        id_habilidad, texto_pregunta, tipo_pregunta, url_audio, url_video,
        url_imagen, puntos, nivel_dificultad, nivel_acceso, creado_por
      ) VALUES (
        @habilidadId, @textoPregunta, @tipoPregunta, @urlAudio, @urlVideo,
        @urlImagen, @puntos, @nivelDificultad, @nivelAcceso, @creadoPor
      )
      RETURNING *
      '''),
      parameters: {
        'habilidadId': question.habilidadId,
        'textoPregunta': question.textoPregunta,
        'tipoPregunta': question.tipoPregunta,
        'urlAudio': question.urlAudio,
        'urlVideo': question.urlVideo,
        'urlImagen': question.urlImagen,
        'puntos': question.puntos,
        'nivelDificultad': question.nivelDificultad,
        'nivelAcceso': question.nivelAcceso,
        'creadoPor': question.creadoPor,
      },
    );

    return Question.fromMap(result.first.toColumnMap());
  }

  /// Update question
  Future<Question?> updateQuestion(int id, Question question) async {
    final result = await _db.execute(
      Sql.named('''
      UPDATE Preguntas SET
        id_habilidad = @habilidadId,
        texto_pregunta = @textoPregunta,
        tipo_pregunta = @tipoPregunta,
        url_audio = @urlAudio,
        url_video = @urlVideo,
        url_imagen = @urlImagen,
        puntos = @puntos,
        nivel_dificultad = @nivelDificultad,
        nivel_acceso = @nivelAcceso
      WHERE id_pregunta = @id
      RETURNING *
      '''),
      parameters: {
        'id': id,
        'habilidadId': question.habilidadId,
        'textoPregunta': question.textoPregunta,
        'tipoPregunta': question.tipoPregunta,
        'urlAudio': question.urlAudio,
        'urlVideo': question.urlVideo,
        'urlImagen': question.urlImagen,
        'puntos': question.puntos,
        'nivelDificultad': question.nivelDificultad,
        'nivelAcceso': question.nivelAcceso,
      },
    );

    if (result.isEmpty) return null;
    return Question.fromMap(result.first.toColumnMap());
  }

  /// Delete question
  Future<bool> deleteQuestion(int id) async {
    final result = await _db.execute(
      Sql.named('DELETE FROM Preguntas WHERE id_pregunta = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // ========== ANSWER OPTIONS ==========

  /// Get answer options for a question
  Future<List<AnswerOption>> getAnswerOptionsByQuestionId(int questionId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Opciones_Respuesta WHERE id_pregunta = @questionId ORDER BY orden'),
      parameters: {'questionId': questionId},
    );

    return result.map((row) => AnswerOption.fromMap(row.toColumnMap())).toList();
  }

  /// Create answer option
  Future<AnswerOption> createAnswerOption(AnswerOption option) async {
    final result = await _db.execute(
      Sql.named('''
      INSERT INTO Opciones_Respuesta (
        id_pregunta, texto_opcion, es_correcta, orden
      ) VALUES (
        @preguntaId, @textoOpcion, @esCorrecta, @orden
      )
      RETURNING *
      '''),
      parameters: {
        'preguntaId': option.preguntaId,
        'textoOpcion': option.textoOpcion,
        'esCorrecta': option.esCorrecta,
        'orden': option.orden,
      },
    );

    return AnswerOption.fromMap(result.first.toColumnMap());
  }

  /// Update answer option
  Future<AnswerOption?> updateAnswerOption(int id, AnswerOption option) async {
    final result = await _db.execute(
      Sql.named('''
      UPDATE Opciones_Respuesta SET
        texto_opcion = @textoOpcion,
        es_correcta = @esCorrecta,
        orden = @orden
      WHERE id_opcion = @id
      RETURNING *
      '''),
      parameters: {
        'id': id,
        'textoOpcion': option.textoOpcion,
        'esCorrecta': option.esCorrecta,
        'orden': option.orden,
      },
    );

    if (result.isEmpty) return null;
    return AnswerOption.fromMap(result.first.toColumnMap());
  }

  /// Delete answer option
  Future<bool> deleteAnswerOption(int id) async {
    final result = await _db.execute(
      Sql.named('DELETE FROM Opciones_Respuesta WHERE id_opcion = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // ========== USER ANSWERS ==========

  /// Get user answers by user ID
  Future<List<UserAnswer>> getUserAnswersByUserId(int userId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Respuestas_Usuario WHERE id_usuario = @userId ORDER BY fecha_respuesta DESC'),
      parameters: {'userId': userId},
    );

    return result.map((row) => UserAnswer.fromMap(row.toColumnMap())).toList();
  }

  /// Get user answer by ID
  Future<UserAnswer?> getUserAnswerById(int id) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM Respuestas_Usuario WHERE id_respuesta = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return UserAnswer.fromMap(result.first.toColumnMap());
  }

  /// Get user answers for a specific question
  Future<List<UserAnswer>> getUserAnswersByQuestionId(int userId, int questionId) async {
    final result = await _db.execute(
      Sql.named('''
      SELECT * FROM Respuestas_Usuario
      WHERE id_usuario = @userId AND id_pregunta = @questionId
      ORDER BY fecha_respuesta DESC
      '''),
      parameters: {'userId': userId, 'questionId': questionId},
    );

    return result.map((row) => UserAnswer.fromMap(row.toColumnMap())).toList();
  }

  /// Create user answer
  Future<UserAnswer> createUserAnswer(UserAnswer answer) async {
    final result = await _db.execute(
      Sql.named('''
      INSERT INTO Respuestas_Usuario (
        id_usuario, id_pregunta, id_opcion_seleccionada, texto_ensayo,
        url_grabacion, es_correcta, puntos_obtenidos, requiere_revision
      ) VALUES (
        @usuarioId, @preguntaId, @opcionSeleccionadaId, @textoEnsayo,
        @urlGrabacion, @esCorrecta, @puntosObtenidos, @requiereRevision
      )
      RETURNING *
      '''),
      parameters: {
        'usuarioId': answer.usuarioId,
        'preguntaId': answer.preguntaId,
        'opcionSeleccionadaId': answer.opcionSeleccionadaId,
        'textoEnsayo': answer.textoEnsayo,
        'urlGrabacion': answer.urlGrabacion,
        'esCorrecta': answer.esCorrecta,
        'puntosObtenidos': answer.puntosObtenidos,
        'requiereRevision': answer.requiereRevision,
      },
    );

    return UserAnswer.fromMap(result.first.toColumnMap());
  }

  /// Update user answer (for manual review)
  Future<UserAnswer?> updateUserAnswer(int id, {
    bool? esCorrecta,
    int? puntosObtenidos,
    bool? requiereRevision,
  }) async {
    final updates = <String>[];
    final parameters = <String, dynamic>{'id': id};

    if (esCorrecta != null) {
      updates.add('es_correcta = @esCorrecta');
      parameters['esCorrecta'] = esCorrecta;
    }
    if (puntosObtenidos != null) {
      updates.add('puntos_obtenidos = @puntosObtenidos');
      parameters['puntosObtenidos'] = puntosObtenidos;
    }
    if (requiereRevision != null) {
      updates.add('requiere_revision = @requiereRevision');
      parameters['requiereRevision'] = requiereRevision;
    }

    if (updates.isEmpty) return getUserAnswerById(id);

    final result = await _db.execute(
      Sql.named('''
      UPDATE Respuestas_Usuario SET
        ${updates.join(', ')}
      WHERE id_respuesta = @id
      RETURNING *
      '''),
      parameters: parameters,
    );

    if (result.isEmpty) return null;
    return UserAnswer.fromMap(result.first.toColumnMap());
  }

  /// Delete user answer
  Future<bool> deleteUserAnswer(int id) async {
    final result = await _db.execute(
      Sql.named('DELETE FROM Respuestas_Usuario WHERE id_respuesta = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  /// Get answers that require manual review
  Future<List<UserAnswer>> getAnswersRequiringReview() async {
    final result = await _db.execute(
      'SELECT * FROM Respuestas_Usuario WHERE requiere_revision = true ORDER BY fecha_respuesta ASC',
    );

    return result.map((row) => UserAnswer.fromMap(row.toColumnMap())).toList();
  }
}
