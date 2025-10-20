import 'package:postgres/postgres.dart';
import '../models/progress_model.dart';

class ProgressService {
  final Connection _db;

  ProgressService(this._db);

  // ========== PROGRESS MANAGEMENT ==========

  /// Get progress for a user and course
  Future<Progress?> getProgress(int userId, int courseId) async {
    final result = await _db.execute(
      Sql.named('''
      SELECT * FROM Progreso_Usuarios
      WHERE id_usuario = @userId AND id_curso = @courseId
      '''),
      parameters: {'userId': userId, 'courseId': courseId},
    );

    if (result.isEmpty) return null;
    return Progress.fromMap(result.first.toColumnMap());
  }

  /// Get all progress for a user
  Future<List<Progress>> getUserProgress(int userId) async {
    final result = await _db.execute(
      Sql.named('''
      SELECT * FROM Progreso_Usuarios
      WHERE id_usuario = @userId
      ORDER BY ultima_actividad DESC
      '''),
      parameters: {'userId': userId},
    );

    return result.map((row) => Progress.fromMap(row.toColumnMap())).toList();
  }

  /// Create or initialize progress for a user and course
  Future<Progress> initializeProgress(int userId, int courseId) async {
    final result = await _db.execute(
      Sql.named('''
      INSERT INTO Progreso_Usuarios (
        id_usuario, id_curso, avance_porcentaje, modulos_completados,
        preguntas_respondidas, preguntas_correctas, puntos_totales
      ) VALUES (
        @userId, @courseId, 0.0, 0, 0, 0, 0
      )
      ON CONFLICT (id_usuario, id_curso) DO NOTHING
      RETURNING *
      '''),
      parameters: {'userId': userId, 'courseId': courseId},
    );

    if (result.isEmpty) {
      // Already exists, fetch it
      return (await getProgress(userId, courseId))!;
    }

    return Progress.fromMap(result.first.toColumnMap());
  }

  /// Update progress after answering questions
  Future<Progress?> updateProgressAfterAnswer({
    required int userId,
    required int courseId,
    required bool isCorrect,
    required int pointsEarned,
  }) async {
    // Ensure progress exists
    await initializeProgress(userId, courseId);

    // Update progress
    final result = await _db.execute(
      Sql.named('''
      UPDATE Progreso_Usuarios SET
        preguntas_respondidas = preguntas_respondidas + 1,
        preguntas_correctas = preguntas_correctas + @increment,
        puntos_totales = puntos_totales + @points,
        ultima_actividad = CURRENT_TIMESTAMP
      WHERE id_usuario = @userId AND id_curso = @courseId
      RETURNING *
      '''),
      parameters: {
        'userId': userId,
        'courseId': courseId,
        'increment': isCorrect ? 1 : 0,
        'points': pointsEarned,
      },
    );

    if (result.isEmpty) return null;
    final progress = Progress.fromMap(result.first.toColumnMap());

    // Recalculate percentage
    await _recalculateProgress(userId, courseId);

    return getProgress(userId, courseId);
  }

  /// Update progress after completing a quiz
  Future<Progress?> updateProgressAfterQuiz({
    required int userId,
    required int courseId,
    required int questionsAnswered,
    required int correctAnswers,
    required int pointsEarned,
  }) async {
    // Ensure progress exists
    await initializeProgress(userId, courseId);

    // Update progress
    final result = await _db.execute(
      Sql.named('''
      UPDATE Progreso_Usuarios SET
        preguntas_respondidas = preguntas_respondidas + @answered,
        preguntas_correctas = preguntas_correctas + @correct,
        puntos_totales = puntos_totales + @points,
        ultima_actividad = CURRENT_TIMESTAMP
      WHERE id_usuario = @userId AND id_curso = @courseId
      RETURNING *
      '''),
      parameters: {
        'userId': userId,
        'courseId': courseId,
        'answered': questionsAnswered,
        'correct': correctAnswers,
        'points': pointsEarned,
      },
    );

    if (result.isEmpty) return null;

    // Recalculate percentage
    await _recalculateProgress(userId, courseId);

    return getProgress(userId, courseId);
  }

  /// Recalculate progress percentage based on completed quizzes
  Future<void> _recalculateProgress(int userId, int courseId) async {
    // Get total quizzes for the course
    final totalQuizzesResult = await _db.execute(
      Sql.named('''
      SELECT COUNT(DISTINCT c.id_cuestionario) as total
      FROM Cuestionarios c
      JOIN Habilidades h ON c.id_habilidad = h.id_habilidad
      WHERE h.id_curso = @courseId
      '''),
      parameters: {'courseId': courseId},
    );

    final totalQuizzes = totalQuizzesResult.first.toColumnMap()['total'] as int;

    if (totalQuizzes == 0) return;

    // Get completed quizzes for the user
    final completedQuizzesResult = await _db.execute(
      Sql.named('''
      SELECT COUNT(DISTINCT ic.id_cuestionario) as completed
      FROM Intentos_Cuestionario ic
      JOIN Cuestionarios c ON ic.id_cuestionario = c.id_cuestionario
      JOIN Habilidades h ON c.id_habilidad = h.id_habilidad
      WHERE ic.id_usuario = @userId
        AND h.id_curso = @courseId
        AND ic.estado = 'Completado'
        AND ic.porcentaje >= 70
      '''),
      parameters: {'userId': userId, 'courseId': courseId},
    );

    final completedQuizzes =
        completedQuizzesResult.first.toColumnMap()['completed'] as int;

    final percentage = (completedQuizzes / totalQuizzes) * 100;

    // Update percentage
    await _db.execute(
      Sql.named('''
      UPDATE Progreso_Usuarios SET
        avance_porcentaje = @percentage,
        modulos_completados = @completed
      WHERE id_usuario = @userId AND id_curso = @courseId
      '''),
      parameters: {
        'userId': userId,
        'courseId': courseId,
        'percentage': percentage,
        'completed': completedQuizzes,
      },
    );
  }

  /// Manually update progress percentage
  Future<Progress?> updateProgressPercentage({
    required int userId,
    required int courseId,
    required double percentage,
  }) async {
    final result = await _db.execute(
      Sql.named('''
      UPDATE Progreso_Usuarios SET
        avance_porcentaje = @percentage,
        ultima_actividad = CURRENT_TIMESTAMP
      WHERE id_usuario = @userId AND id_curso = @courseId
      RETURNING *
      '''),
      parameters: {
        'userId': userId,
        'courseId': courseId,
        'percentage': percentage,
      },
    );

    if (result.isEmpty) return null;
    return Progress.fromMap(result.first.toColumnMap());
  }

  // ========== STATISTICS ==========

  /// Get user statistics across all courses
  Future<UserStats> getUserStats(int userId) async {
    // Total points and questions from progress
    final progressResult = await _db.execute(
      Sql.named('''
      SELECT
        COALESCE(SUM(puntos_totales), 0) as total_points,
        COALESCE(SUM(preguntas_respondidas), 0) as total_answered,
        COALESCE(SUM(preguntas_correctas), 0) as total_correct,
        COUNT(*) as courses_started,
        COUNT(CASE WHEN avance_porcentaje >= 100 THEN 1 END) as courses_completed,
        MAX(ultima_actividad) as last_activity
      FROM Progreso_Usuarios
      WHERE id_usuario = @userId
      '''),
      parameters: {'userId': userId},
    );

    final progressData = progressResult.first.toColumnMap();

    // Total quizzes completed
    final quizzesResult = await _db.execute(
      Sql.named('''
      SELECT COUNT(*) as quizzes_completed
      FROM Intentos_Cuestionario
      WHERE id_usuario = @userId AND estado = 'Completado'
      '''),
      parameters: {'userId': userId},
    );

    final quizzesCompleted =
        quizzesResult.first.toColumnMap()['quizzes_completed'] as int;

    final totalAnswered = progressData['total_answered'] as int;
    final totalCorrect = progressData['total_correct'] as int;
    final accuracy =
        totalAnswered > 0 ? (totalCorrect / totalAnswered) * 100 : 0.0;

    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserStats(
      userId: userId,
      totalPoints: progressData['total_points'] as int,
      totalQuestionsAnswered: totalAnswered,
      totalCorrectAnswers: totalCorrect,
      accuracyPercentage: accuracy,
      coursesStarted: progressData['courses_started'] as int,
      coursesCompleted: progressData['courses_completed'] as int,
      quizzesCompleted: quizzesCompleted,
      lastActivity: parseDateTime(progressData['last_activity']),
    );
  }

  /// Get course-specific statistics
  Future<Map<String, dynamic>> getCourseStats(int userId, int courseId) async {
    final progress = await getProgress(userId, courseId);

    if (progress == null) {
      return {
        'progress': null,
        'quizzesCompleted': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
      };
    }

    // Get quiz statistics
    final quizStatsResult = await _db.execute(
      Sql.named('''
      SELECT
        COUNT(*) as quizzes_completed,
        COALESCE(AVG(porcentaje), 0) as average_score,
        COALESCE(MAX(porcentaje), 0) as best_score
      FROM Intentos_Cuestionario ic
      JOIN Cuestionarios c ON ic.id_cuestionario = c.id_cuestionario
      JOIN Habilidades h ON c.id_habilidad = h.id_habilidad
      WHERE ic.id_usuario = @userId
        AND h.id_curso = @courseId
        AND ic.estado = 'Completado'
      '''),
      parameters: {'userId': userId, 'courseId': courseId},
    );

    final quizStats = quizStatsResult.first.toColumnMap();

    return {
      'progress': progress.toJson(),
      'quizzesCompleted': quizStats['quizzes_completed'],
      'averageScore': quizStats['average_score'],
      'bestScore': quizStats['best_score'],
    };
  }

  /// Delete progress
  Future<bool> deleteProgress(int userId, int courseId) async {
    final result = await _db.execute(
      Sql.named('''
      DELETE FROM Progreso_Usuarios
      WHERE id_usuario = @userId AND id_curso = @courseId
      '''),
      parameters: {'userId': userId, 'courseId': courseId},
    );

    return result.affectedRows > 0;
  }
}
