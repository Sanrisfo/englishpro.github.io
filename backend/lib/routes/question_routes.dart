import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/question_service.dart';
import '../models/question_model.dart';

class QuestionRoutes {
  final QuestionService _questionService;

  QuestionRoutes(this._questionService);

  Router get router {
    final router = Router();

    // ========== QUESTIONS ==========
    router.get('/', _getAllQuestions);
    router.get('/<id>', _getQuestionById);
    router.get('/skill/<skillId>', _getQuestionsBySkill);
    router.post('/', _createQuestion);
    router.put('/<id>', _updateQuestion);
    router.delete('/<id>', _deleteQuestion);

    // ========== ANSWER OPTIONS ==========
    router.get('/<questionId>/options', _getAnswerOptions);
    router.post('/<questionId>/options', _createAnswerOption);
    router.put('/options/<id>', _updateAnswerOption);
    router.delete('/options/<id>', _deleteAnswerOption);

    // ========== USER ANSWERS ==========
    router.get('/users/<userId>/answers', _getUserAnswers);
    router.get('/answers/<id>', _getUserAnswerById);
    router.post('/answers', _createUserAnswer);
    router.put('/answers/<id>', _updateUserAnswer);
    router.delete('/answers/<id>', _deleteUserAnswer);
    router.get('/answers/review/pending', _getAnswersRequiringReview);

    return router;
  }

  // ========== QUESTION HANDLERS ==========

  Future<Response> _getAllQuestions(Request request) async {
    try {
      // Check for query parameters
      final params = request.url.queryParameters;

      if (params.isNotEmpty) {
        // Filter questions
        final questions = await _questionService.getQuestionsByFilters(
          skillId: params['skill_id'] != null ? int.tryParse(params['skill_id']!) : null,
          difficulty: params['difficulty'],
          type: params['type'],
          accessLevel: params['access_level'],
        );

        return Response.ok(
          jsonEncode({
            'success': true,
            'data': questions.map((q) => q.toJson()).toList(),
            'count': questions.length,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Get all questions
      final questions = await _questionService.getAllQuestions();

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

  Future<Response> _getQuestionById(Request request, String id) async {
    try {
      final questionId = int.tryParse(id);
      if (questionId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid question ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final question = await _questionService.getQuestionById(questionId);
      if (question == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Question not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Get answer options if it's a multiple choice question
      List<AnswerOption> options = [];
      if (question.tipoPregunta == 'Multiple Choice') {
        options = await _questionService.getAnswerOptionsByQuestionId(questionId);
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            ...question.toJson(),
            'options': options.map((o) => o.toJson()).toList(),
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

  Future<Response> _getQuestionsBySkill(Request request, String skillId) async {
    try {
      final id = int.tryParse(skillId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid skill ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final questions = await _questionService.getQuestionsBySkillId(id);

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

  Future<Response> _createQuestion(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final question = Question.fromJson(payload);

      final created = await _questionService.createQuestion(question);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'message': 'Question created successfully',
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

  Future<Response> _updateQuestion(Request request, String id) async {
    try {
      final questionId = int.tryParse(id);
      if (questionId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid question ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final question = Question.fromJson(payload);

      final updated = await _questionService.updateQuestion(questionId, question);
      if (updated == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Question not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Question updated successfully',
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

  Future<Response> _deleteQuestion(Request request, String id) async {
    try {
      final questionId = int.tryParse(id);
      if (questionId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid question ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _questionService.deleteQuestion(questionId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Question not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Question deleted successfully',
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

  // ========== ANSWER OPTION HANDLERS ==========

  Future<Response> _getAnswerOptions(Request request, String questionId) async {
    try {
      final id = int.tryParse(questionId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid question ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final options = await _questionService.getAnswerOptionsByQuestionId(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': options.map((o) => o.toJson()).toList(),
          'count': options.length,
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

  Future<Response> _createAnswerOption(Request request, String questionId) async {
    try {
      final id = int.tryParse(questionId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid question ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      payload['pregunta_id'] = id; // Ensure question ID matches route
      final option = AnswerOption.fromJson(payload);

      final created = await _questionService.createAnswerOption(option);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'message': 'Answer option created successfully',
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

  Future<Response> _updateAnswerOption(Request request, String id) async {
    try {
      final optionId = int.tryParse(id);
      if (optionId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid option ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final option = AnswerOption.fromJson(payload);

      final updated = await _questionService.updateAnswerOption(optionId, option);
      if (updated == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Answer option not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Answer option updated successfully',
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

  Future<Response> _deleteAnswerOption(Request request, String id) async {
    try {
      final optionId = int.tryParse(id);
      if (optionId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid option ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _questionService.deleteAnswerOption(optionId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Answer option not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Answer option deleted successfully',
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

  // ========== USER ANSWER HANDLERS ==========

  Future<Response> _getUserAnswers(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final answers = await _questionService.getUserAnswersByUserId(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': answers.map((a) => a.toJson()).toList(),
          'count': answers.length,
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

  Future<Response> _getUserAnswerById(Request request, String id) async {
    try {
      final answerId = int.tryParse(id);
      if (answerId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid answer ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final answer = await _questionService.getUserAnswerById(answerId);
      if (answer == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User answer not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': answer.toJson(),
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

  Future<Response> _createUserAnswer(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final answer = UserAnswer.fromJson(payload);

      final created = await _questionService.createUserAnswer(answer);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'message': 'User answer created successfully',
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

  Future<Response> _updateUserAnswer(Request request, String id) async {
    try {
      final answerId = int.tryParse(id);
      if (answerId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid answer ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final updated = await _questionService.updateUserAnswer(
        answerId,
        esCorrecta: payload['es_correcta'] as bool?,
        puntosObtenidos: payload['puntos_obtenidos'] as int?,
        requiereRevision: payload['requiere_revision'] as bool?,
      );

      if (updated == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User answer not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'User answer updated successfully',
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

  Future<Response> _deleteUserAnswer(Request request, String id) async {
    try {
      final answerId = int.tryParse(id);
      if (answerId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid answer ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _questionService.deleteUserAnswer(answerId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User answer not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'User answer deleted successfully',
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

  Future<Response> _getAnswersRequiringReview(Request request) async {
    try {
      final answers = await _questionService.getAnswersRequiringReview();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': answers.map((a) => a.toJson()).toList(),
          'count': answers.length,
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
