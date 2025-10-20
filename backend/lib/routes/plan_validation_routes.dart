import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/plan_validation_service.dart';

class PlanValidationRoutes {
  final PlanValidationService _planValidationService;
  final Router router = Router();

  PlanValidationRoutes(this._planValidationService) {
    router.get('/user/<userId>', _getUserPlanInfo);
    router.get('/user/<userId>/validate-quiz', _validateQuizLimits);
    router.get('/user/<userId>/course/<courseId>/access', _validateCourseAccess);
    router.put('/user/<userId>/plan', _updateUserPlan);
  }

  // GET /api/plan-validation/user/:userId
  Future<Response> _getUserPlanInfo(Request request, String userId) async {
    try {
      final uid = int.parse(userId);
      final planInfo = await _planValidationService.getUserPlanInfo(uid);

      return Response.ok(
        json.encode({
          'success': true,
          'data': planInfo,
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

  // GET /api/plan-validation/user/:userId/validate-quiz
  Future<Response> _validateQuizLimits(Request request, String userId) async {
    try {
      final uid = int.parse(userId);
      final validation = await _planValidationService.validateQuizLimits(uid);

      return Response.ok(
        json.encode({
          'success': true,
          'data': validation,
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

  // GET /api/plan-validation/user/:userId/course/:courseId/access
  Future<Response> _validateCourseAccess(
    Request request,
    String userId,
    String courseId,
  ) async {
    try {
      final uid = int.parse(userId);
      final cid = int.parse(courseId);
      final access = await _planValidationService.canAccessCourse(uid, cid);

      return Response.ok(
        json.encode({
          'success': true,
          'data': access,
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

  // PUT /api/plan-validation/user/:userId/plan
  Future<Response> _updateUserPlan(Request request, String userId) async {
    try {
      final uid = int.parse(userId);
      final body = json.decode(await request.readAsString());
      final newPlan = body['plan'] as String;

      final success = await _planValidationService.updateUserPlan(uid, newPlan);

      if (success) {
        return Response.ok(
          json.encode({
            'success': true,
            'message': 'Plan actualizado correctamente',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: json.encode({
            'success': false,
            'error': 'No se pudo actualizar el plan',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
