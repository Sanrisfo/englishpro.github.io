import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/feedback_service.dart';
import '../models/feedback_model.dart';

class FeedbackRoutes {
  final FeedbackService _feedbackService;
  final Router router = Router();

  FeedbackRoutes(this._feedbackService) {
    // Feedback CRUD routes
    router.post('/', _createFeedback);
    router.get('/<id>', _getFeedbackById);
    router.get('/user/<userId>', _getFeedbacksByUser);
    router.put('/<id>', _updateFeedback);
    router.delete('/<id>', _deleteFeedback);

    // Special routes
    router.get('/pending/all', _getPendingFeedbacks);
    router.get('/teacher/<teacherId>', _getFeedbacksByTeacher);
    router.post('/<id>/grade', _gradeFeedback);
    router.get('/user/<userId>/stats', _getUserFeedbackStats);
  }

  // POST /api/feedback
  Future<Response> _createFeedback(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final feedback = Feedback(
        usuarioId: payload['usuario_id'] as int,
        preguntaId: payload['pregunta_id'] as int,
        docenteId: payload['docente_id'] as int?,
        tipoRespuesta: payload['tipo_respuesta'] as String,
        respuestaTexto: payload['respuesta_texto'] as String?,
        respuestaAudioUrl: payload['respuesta_audio_url'] as String?,
        puntuacion: payload['puntuacion'] != null ? (payload['puntuacion'] as num).toDouble() : null,
        comentarios: payload['comentarios'] as String?,
        estado: payload['estado'] as String? ?? 'Pendiente',
      );

      final created = await _feedbackService.createFeedback(feedback);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'data': created.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/feedback/:id
  Future<Response> _getFeedbackById(Request request, String id) async {
    try {
      final feedbackId = int.tryParse(id);
      if (feedbackId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid feedback ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final feedback = await _feedbackService.getFeedbackById(feedbackId);

      if (feedback == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Feedback not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': feedback.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/feedback/user/:userId
  Future<Response> _getFeedbacksByUser(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid user ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final feedbacks = await _feedbackService.getFeedbacksByUser(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': feedbacks.map((f) => f.toJson()).toList(),
          'count': feedbacks.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/feedback/pending/all
  Future<Response> _getPendingFeedbacks(Request request) async {
    try {
      final feedbacks = await _feedbackService.getPendingFeedbacks();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': feedbacks.map((f) => f.toJson()).toList(),
          'count': feedbacks.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/feedback/teacher/:teacherId
  Future<Response> _getFeedbacksByTeacher(Request request, String teacherId) async {
    try {
      final id = int.tryParse(teacherId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid teacher ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final feedbacks = await _feedbackService.getFeedbacksByTeacher(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': feedbacks.map((f) => f.toJson()).toList(),
          'count': feedbacks.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/feedback/:id/grade
  Future<Response> _gradeFeedback(Request request, String id) async {
    try {
      final feedbackId = int.tryParse(id);
      if (feedbackId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid feedback ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final success = await _feedbackService.gradeFeedback(
        feedbackId: feedbackId,
        teacherId: payload['teacher_id'] as int,
        puntuacion: (payload['puntuacion'] as num).toDouble(),
        comentarios: payload['comentarios'] as String?,
      );

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Feedback graded successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to grade feedback',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PUT /api/feedback/:id
  Future<Response> _updateFeedback(Request request, String id) async {
    try {
      final feedbackId = int.tryParse(id);
      if (feedbackId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid feedback ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updates = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final success = await _feedbackService.updateFeedback(feedbackId, updates);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Feedback updated successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Feedback not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/feedback/:id
  Future<Response> _deleteFeedback(Request request, String id) async {
    try {
      final feedbackId = int.tryParse(id);
      if (feedbackId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid feedback ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final success = await _feedbackService.deleteFeedback(feedbackId);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Feedback deleted successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Feedback not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/feedback/user/:userId/stats
  Future<Response> _getUserFeedbackStats(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid user ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final stats = await _feedbackService.getUserFeedbackStats(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': stats,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
