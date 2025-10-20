import 'package:postgres/postgres.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final Connection _connection;

  FeedbackService(this._connection);

  // Crear nueva retroalimentación
  Future<Feedback> createFeedback(Feedback feedback) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO Retroalimentacion (
          id_usuario, id_pregunta, id_docente, tipo_respuesta,
          respuesta_texto, respuesta_audio_url, puntuacion,
          comentarios, estado, fecha_respuesta
        ) VALUES (
          @id_usuario, @id_pregunta, @id_docente, @tipo_respuesta,
          @respuesta_texto, @respuesta_audio_url, @puntuacion,
          @comentarios, @estado, @fecha_respuesta
        ) RETURNING id_feedback, fecha_respuesta, fecha_calificacion
      '''),
      parameters: {
        'id_usuario': feedback.usuarioId,
        'id_pregunta': feedback.preguntaId,
        'id_docente': feedback.docenteId,
        'tipo_respuesta': feedback.tipoRespuesta,
        'respuesta_texto': feedback.respuestaTexto,
        'respuesta_audio_url': feedback.respuestaAudioUrl,
        'puntuacion': feedback.puntuacion,
        'comentarios': feedback.comentarios,
        'estado': feedback.estado,
        'fecha_respuesta': feedback.fechaRespuesta ?? DateTime.now(),
      },
    );

    final row = result.first;
    return Feedback(
      id: row[0] as int,
      usuarioId: feedback.usuarioId,
      preguntaId: feedback.preguntaId,
      docenteId: feedback.docenteId,
      tipoRespuesta: feedback.tipoRespuesta,
      respuestaTexto: feedback.respuestaTexto,
      respuestaAudioUrl: feedback.respuestaAudioUrl,
      puntuacion: feedback.puntuacion,
      comentarios: feedback.comentarios,
      estado: feedback.estado,
      fechaRespuesta: row[1] as DateTime,
      fechaCalificacion: row[2] as DateTime?,
    );
  }

  // Obtener retroalimentación por ID
  Future<Feedback?> getFeedbackById(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          id_feedback, id_usuario, id_pregunta, id_docente,
          tipo_respuesta, respuesta_texto, respuesta_audio_url,
          puntuacion, comentarios, estado, fecha_respuesta, fecha_calificacion
        FROM Retroalimentacion
        WHERE id_feedback = @id
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return Feedback(
      id: row[0] as int,
      usuarioId: row[1] as int,
      preguntaId: row[2] as int,
      docenteId: row[3] as int?,
      tipoRespuesta: row[4] as String,
      respuestaTexto: row[5] as String?,
      respuestaAudioUrl: row[6] as String?,
      puntuacion: row[7] != null ? (row[7] as num).toDouble() : null,
      comentarios: row[8] as String?,
      estado: row[9] as String,
      fechaRespuesta: row[10] as DateTime?,
      fechaCalificacion: row[11] as DateTime?,
    );
  }

  // Obtener retroalimentaciones por usuario
  Future<List<Feedback>> getFeedbacksByUser(int userId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          id_feedback, id_usuario, id_pregunta, id_docente,
          tipo_respuesta, respuesta_texto, respuesta_audio_url,
          puntuacion, comentarios, estado, fecha_respuesta, fecha_calificacion
        FROM Retroalimentacion
        WHERE id_usuario = @userId
        ORDER BY fecha_respuesta DESC
      '''),
      parameters: {'userId': userId},
    );

    return result.map((row) => Feedback(
      id: row[0] as int,
      usuarioId: row[1] as int,
      preguntaId: row[2] as int,
      docenteId: row[3] as int?,
      tipoRespuesta: row[4] as String,
      respuestaTexto: row[5] as String?,
      respuestaAudioUrl: row[6] as String?,
      puntuacion: row[7] != null ? (row[7] as num).toDouble() : null,
      comentarios: row[8] as String?,
      estado: row[9] as String,
      fechaRespuesta: row[10] as DateTime?,
      fechaCalificacion: row[11] as DateTime?,
    )).toList();
  }

  // Obtener retroalimentaciones pendientes
  Future<List<Feedback>> getPendingFeedbacks() async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          id_feedback, id_usuario, id_pregunta, id_docente,
          tipo_respuesta, respuesta_texto, respuesta_audio_url,
          puntuacion, comentarios, estado, fecha_respuesta, fecha_calificacion
        FROM Retroalimentacion
        WHERE estado = 'Pendiente'
        ORDER BY fecha_respuesta ASC
      '''),
      parameters: {},
    );

    return result.map((row) => Feedback(
      id: row[0] as int,
      usuarioId: row[1] as int,
      preguntaId: row[2] as int,
      docenteId: row[3] as int?,
      tipoRespuesta: row[4] as String,
      respuestaTexto: row[5] as String?,
      respuestaAudioUrl: row[6] as String?,
      puntuacion: row[7] != null ? (row[7] as num).toDouble() : null,
      comentarios: row[8] as String?,
      estado: row[9] as String,
      fechaRespuesta: row[10] as DateTime?,
      fechaCalificacion: row[11] as DateTime?,
    )).toList();
  }

  // Obtener retroalimentaciones por docente
  Future<List<Feedback>> getFeedbacksByTeacher(int teacherId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          id_feedback, id_usuario, id_pregunta, id_docente,
          tipo_respuesta, respuesta_texto, respuesta_audio_url,
          puntuacion, comentarios, estado, fecha_respuesta, fecha_calificacion
        FROM Retroalimentacion
        WHERE id_docente = @teacherId
        ORDER BY fecha_calificacion DESC
      '''),
      parameters: {'teacherId': teacherId},
    );

    return result.map((row) => Feedback(
      id: row[0] as int,
      usuarioId: row[1] as int,
      preguntaId: row[2] as int,
      docenteId: row[3] as int?,
      tipoRespuesta: row[4] as String,
      respuestaTexto: row[5] as String?,
      respuestaAudioUrl: row[6] as String?,
      puntuacion: row[7] != null ? (row[7] as num).toDouble() : null,
      comentarios: row[8] as String?,
      estado: row[9] as String,
      fechaRespuesta: row[10] as DateTime?,
      fechaCalificacion: row[11] as DateTime?,
    )).toList();
  }

  // Calificar retroalimentación (actualizar puntuación y comentarios)
  Future<bool> gradeFeedback({
    required int feedbackId,
    required int teacherId,
    required double puntuacion,
    String? comentarios,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE Retroalimentacion
        SET
          id_docente = @teacherId,
          puntuacion = @puntuacion,
          comentarios = @comentarios,
          estado = 'Calificada',
          fecha_calificacion = CURRENT_TIMESTAMP
        WHERE id_feedback = @feedbackId
      '''),
      parameters: {
        'feedbackId': feedbackId,
        'teacherId': teacherId,
        'puntuacion': puntuacion,
        'comentarios': comentarios,
      },
    );

    return result.affectedRows > 0;
  }

  // Actualizar retroalimentación
  Future<bool> updateFeedback(int id, Map<String, dynamic> updates) async {
    final setClause = updates.keys.map((key) => '$key = @$key').join(', ');

    final result = await _connection.execute(
      Sql.named('''
        UPDATE Retroalimentacion
        SET $setClause
        WHERE id_feedback = @id
      '''),
      parameters: {'id': id, ...updates},
    );

    return result.affectedRows > 0;
  }

  // Eliminar retroalimentación
  Future<bool> deleteFeedback(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        DELETE FROM Retroalimentacion
        WHERE id_feedback = @id
      '''),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // Obtener estadísticas de retroalimentación por usuario
  Future<Map<String, dynamic>> getUserFeedbackStats(int userId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          COUNT(*) as total,
          COUNT(CASE WHEN estado = 'Pendiente' THEN 1 END) as pendientes,
          COUNT(CASE WHEN estado = 'Calificada' THEN 1 END) as calificadas,
          AVG(CASE WHEN puntuacion IS NOT NULL THEN puntuacion END) as promedio
        FROM Retroalimentacion
        WHERE id_usuario = @userId
      '''),
      parameters: {'userId': userId},
    );

    if (result.isEmpty) {
      return {
        'total': 0,
        'pendientes': 0,
        'calificadas': 0,
        'promedio': 0.0,
      };
    }

    final row = result.first;
    return {
      'total': row[0] as int,
      'pendientes': row[1] as int,
      'calificadas': row[2] as int,
      'promedio': row[3] != null ? (row[3] as num).toDouble() : 0.0,
    };
  }
}
