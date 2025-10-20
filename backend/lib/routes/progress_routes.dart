import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/progress_service.dart';
import '../models/progress_model.dart';

class ProgressRoutes {
  final ProgressService _progressService;
  final Router router = Router();

  ProgressRoutes(this._progressService) {
    router.get('/user/<userId>', _getUserProgress);
    router.get('/user/<userId>/course/<courseId>', _getProgress);
    router.post('/user/<userId>/course/<courseId>/initialize', _initializeProgress);
    router.post('/user/<userId>/course/<courseId>/update', _updateProgress);
    router.delete('/user/<userId>/course/<courseId>', _deleteProgress);
  }

  // GET /api/progress/user/:userId
  Future<Response> _getUserProgress(Request request, String userId) async {
    try {
      final id = int.parse(userId);
      final progressList = await _progressService.getUserProgress(id);

      return Response.ok(
        json.encode({
          'success': true,
          'data': progressList.map((p) => p.toJson()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/progress/user/:userId/course/:courseId
  Future<Response> _getProgress(
      Request request, String userId, String courseId) async {
    try {
      final uid = int.parse(userId);
      final cid = int.parse(courseId);

      final progress = await _progressService.getProgress(uid, cid);

      if (progress == null) {
        return Response.notFound(
          json.encode({'success': false, 'error': 'Progress not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode({
          'success': true,
          'data': progress.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/progress/user/:userId/course/:courseId/initialize
  Future<Response> _initializeProgress(
      Request request, String userId, String courseId) async {
    try {
      final uid = int.parse(userId);
      final cid = int.parse(courseId);

      final progress = await _progressService.initializeProgress(uid, cid);

      return Response.ok(
        json.encode({
          'success': true,
          'data': progress.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/progress/user/:userId/course/:courseId/update
  Future<Response> _updateProgress(
      Request request, String userId, String courseId) async {
    try {
      final uid = int.parse(userId);
      final cid = int.parse(courseId);
      final body = json.decode(await request.readAsString());

      Progress? progress;

      // Check if it's a quiz update or answer update
      if (body.containsKey('questionsAnswered')) {
        progress = await _progressService.updateProgressAfterQuiz(
          userId: uid,
          courseId: cid,
          questionsAnswered: body['questionsAnswered'] as int,
          correctAnswers: body['correctAnswers'] as int,
          pointsEarned: body['pointsEarned'] as int,
        );
      } else if (body.containsKey('isCorrect')) {
        progress = await _progressService.updateProgressAfterAnswer(
          userId: uid,
          courseId: cid,
          isCorrect: body['isCorrect'] as bool,
          pointsEarned: body['pointsEarned'] as int,
        );
      } else if (body.containsKey('percentage')) {
        progress = await _progressService.updateProgressPercentage(
          userId: uid,
          courseId: cid,
          percentage: (body['percentage'] as num).toDouble(),
        );
      }

      if (progress == null) {
        return Response.notFound(
          json.encode({'success': false, 'error': 'Progress not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode({
          'success': true,
          'data': progress.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/progress/user/:userId/course/:courseId
  Future<Response> _deleteProgress(
      Request request, String userId, String courseId) async {
    try {
      final uid = int.parse(userId);
      final cid = int.parse(courseId);

      final success = await _progressService.deleteProgress(uid, cid);

      if (!success) {
        return Response.notFound(
          json.encode({'success': false, 'error': 'Progress not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode({
          'success': true,
          'message': 'Progress deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
