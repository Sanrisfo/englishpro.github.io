import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/quiz_service.dart';
import '../services/plan_validation_service.dart';
import '../models/quiz_model.dart';

class QuizRoutes {
  final QuizService _quizService;
  final PlanValidationService? _planValidationService;

  QuizRoutes(this._quizService, {PlanValidationService? planValidationService})
      : _planValidationService = planValidationService;

  Router get router {
    final router = Router();

    // ========== QUIZZES ==========
    router.get('/', _getAllQuizzes);
    router.get('/<id>', _getQuizById);
    router.get('/skill/<skillId>', _getQuizzesBySkill);
    router.post('/', _createQuiz);
    router.put('/<id>', _updateQuiz);
    router.delete('/<id>', _deleteQuiz);

    // ========== QUIZ QUESTIONS ==========
    router.get('/<quizId>/questions', _getQuizQuestions);
    router.post('/<quizId>/questions', _addQuestionToQuiz);
    router.put('/quiz-questions/<id>', _updateQuizQuestionOrder);
    router.delete('/quiz-questions/<id>', _removeQuestionFromQuiz);

    // ========== QUIZ ATTEMPTS ==========
    router.get('/users/<userId>/attempts', _getUserAttempts);
    router.get('/attempts/<id>', _getAttemptById);
    router.get('/<quizId>/attempts', _getQuizAttempts);
    router.post('/attempts', _createAttempt);
    router.put('/attempts/<id>', _updateAttempt);
    router.delete('/attempts/<id>', _deleteAttempt);
    router.get('/users/<userId>/quizzes/<quizId>/best', _getBestAttempt);

    return router;
  }

  // ========== QUIZ HANDLERS ==========

  Future<Response> _getAllQuizzes(Request request) async {
    try {
      final params = request.url.queryParameters;

      if (params.isNotEmpty) {
        final quizzes = await _quizService.getQuizzesByFilters(
          skillId: params['skill_id'] != null ? int.tryParse(params['skill_id']!) : null,
          difficulty: params['difficulty'],
          accessLevel: params['access_level'],
        );

        return Response.ok(
          jsonEncode({
            'success': true,
            'data': quizzes.map((q) => q.toJson()).toList(),
            'count': quizzes.length,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final quizzes = await _quizService.getAllQuizzes();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': quizzes.map((q) => q.toJson()).toList(),
          'count': quizzes.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getQuizById(Request request, String id) async {
    try {
      final quizId = int.tryParse(id);
      if (quizId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final quiz = await _quizService.getQuizById(quizId);
      if (quiz == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Quiz not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Get questions for this quiz
      final quizQuestions = await _quizService.getQuizQuestions(quizId);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            ...quiz.toJson(),
            'questions': quizQuestions.map((q) => q.toJson()).toList(),
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getQuizzesBySkill(Request request, String skillId) async {
    try {
      final id = int.tryParse(skillId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid skill ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final quizzes = await _quizService.getQuizzesBySkillId(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': quizzes.map((q) => q.toJson()).toList(),
          'count': quizzes.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _createQuiz(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final quiz = Quiz.fromJson(payload);

      final created = await _quizService.createQuiz(quiz);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'message': 'Quiz created successfully',
          'data': created.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateQuiz(Request request, String id) async {
    try {
      final quizId = int.tryParse(id);
      if (quizId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final quiz = Quiz.fromJson(payload);

      final updated = await _quizService.updateQuiz(quizId, quiz);
      if (updated == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Quiz not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Quiz updated successfully',
          'data': updated.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteQuiz(Request request, String id) async {
    try {
      final quizId = int.tryParse(id);
      if (quizId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _quizService.deleteQuiz(quizId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Quiz not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Quiz deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ========== QUIZ QUESTION HANDLERS ==========

  Future<Response> _getQuizQuestions(Request request, String quizId) async {
    try {
      final id = int.tryParse(quizId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final questions = await _quizService.getQuizQuestions(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': questions.map((q) => q.toJson()).toList(),
          'count': questions.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _addQuestionToQuiz(Request request, String quizId) async {
    try {
      final id = int.tryParse(quizId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      payload['cuestionario_id'] = id;
      final quizQuestion = QuizQuestion.fromJson(payload);

      final created = await _quizService.addQuestionToQuiz(quizQuestion);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'message': 'Question added to quiz successfully',
          'data': created.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateQuizQuestionOrder(Request request, String id) async {
    try {
      final quizQuestionId = int.tryParse(id);
      if (quizQuestionId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz question ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final orden = payload['orden'] as int;

      final updated = await _quizService.updateQuizQuestionOrder(quizQuestionId, orden);
      if (updated == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Quiz question not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Question order updated successfully',
          'data': updated.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _removeQuestionFromQuiz(Request request, String id) async {
    try {
      final quizQuestionId = int.tryParse(id);
      if (quizQuestionId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz question ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _quizService.removeQuestionFromQuiz(quizQuestionId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Quiz question not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Question removed from quiz successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ========== QUIZ ATTEMPT HANDLERS ==========

  Future<Response> _getUserAttempts(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final attempts = await _quizService.getUserAttempts(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': attempts.map((a) => a.toJson()).toList(),
          'count': attempts.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getAttemptById(Request request, String id) async {
    try {
      final attemptId = int.tryParse(id);
      if (attemptId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid attempt ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final attempt = await _quizService.getAttemptById(attemptId);
      if (attempt == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Attempt not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': attempt.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getQuizAttempts(Request request, String quizId) async {
    try {
      final id = int.tryParse(quizId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid quiz ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final params = request.url.queryParameters;
      final userId = params['user_id'] != null ? int.tryParse(params['user_id']!) : null;

      final attempts = await _quizService.getQuizAttempts(id, userId: userId);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': attempts.map((a) => a.toJson()).toList(),
          'count': attempts.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _createAttempt(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final attempt = QuizAttempt.fromJson(payload);

      // Validar límites del plan si el servicio está disponible
      if (_planValidationService != null) {
        final validation = await _planValidationService!.validateQuizLimits(attempt.usuarioId);

        if (!(validation['canTake'] as bool)) {
          return Response(403,
            body: jsonEncode({
              'success': false,
              'error': 'Límite de cuestionarios alcanzado',
              'message': validation['message'],
              'data': {
                'plan': validation['plan'],
                'daily': validation['daily'],
                'monthly': validation['monthly'],
              },
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      final created = await _quizService.createAttempt(attempt);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'message': 'Quiz attempt created successfully',
          'data': created.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateAttempt(Request request, String id) async {
    try {
      final attemptId = int.tryParse(id);
      if (attemptId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid attempt ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final updated = await _quizService.updateAttempt(
        attemptId,
        fechaFin: payload['fecha_fin'] != null ? DateTime.parse(payload['fecha_fin'] as String) : null,
        puntosObtenidos: payload['puntos_obtenidos'] as int?,
        porcentaje: payload['porcentaje'] as double?,
        estado: payload['estado'] as String?,
      );

      if (updated == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Attempt not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Quiz attempt updated successfully',
          'data': updated.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteAttempt(Request request, String id) async {
    try {
      final attemptId = int.tryParse(id);
      if (attemptId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid attempt ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _quizService.deleteAttempt(attemptId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Attempt not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Quiz attempt deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getBestAttempt(Request request, String userId, String quizId) async {
    try {
      final uId = int.tryParse(userId);
      final qId = int.tryParse(quizId);

      if (uId == null || qId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid user or quiz ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final attempt = await _quizService.getBestAttempt(uId, qId);
      if (attempt == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'No completed attempts found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': attempt.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
