import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/progress_service.dart';

class StatsRoutes {
  final ProgressService _progressService;
  final Router router = Router();

  StatsRoutes(this._progressService) {
    router.get('/user/<userId>', _getUserStats);
    router.get('/user/<userId>/course/<courseId>', _getCourseStats);
  }

  // GET /api/stats/user/:userId
  Future<Response> _getUserStats(Request request, String userId) async {
    try {
      final id = int.parse(userId);
      final stats = await _progressService.getUserStats(id);

      return Response.ok(
        json.encode({
          'success': true,
          'data': stats.toJson(),
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

  // GET /api/stats/user/:userId/course/:courseId
  Future<Response> _getCourseStats(
      Request request, String userId, String courseId) async {
    try {
      final uid = int.parse(userId);
      final cid = int.parse(courseId);

      final stats = await _progressService.getCourseStats(uid, cid);

      return Response.ok(
        json.encode({
          'success': true,
          'data': stats,
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
