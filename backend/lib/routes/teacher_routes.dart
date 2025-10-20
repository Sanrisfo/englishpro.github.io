import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/teacher_service.dart';
import '../models/teacher_model.dart';

class TeacherRoutes {
  final TeacherService _teacherService;
  final Router router = Router();

  TeacherRoutes(this._teacherService) {
    // Teacher CRUD routes
    router.post('/', _createTeacher);
    router.get('/<id>', _getTeacherById);
    router.get('/user/<userId>', _getTeacherByUserId);
    router.get('/', _getAllTeachers);
    router.put('/<id>', _updateTeacher);
    router.delete('/<id>', _deleteTeacher);

    // Special routes
    router.post('/<id>/deactivate', _deactivateTeacher);
    router.post('/<id>/activate', _activateTeacher);
    router.get('/<id>/stats', _getTeacherStats);
    router.get('/specialty/<specialty>', _getTeachersBySpecialty);
  }

  // POST /api/teachers
  Future<Response> _createTeacher(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final teacher = Teacher(
        usuarioId: payload['usuario_id'] as int,
        especialidad: payload['especialidad'] as String,
        certificaciones: payload['certificaciones'] as String?,
        aniosExperiencia: payload['anios_experiencia'] as int? ?? 0,
        activo: payload['activo'] as bool? ?? true,
      );

      final created = await _teacherService.createTeacher(teacher);

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

  // GET /api/teachers/:id
  Future<Response> _getTeacherById(Request request, String id) async {
    try {
      final teacherId = int.tryParse(id);
      if (teacherId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid teacher ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final teacher = await _teacherService.getTeacherById(teacherId);

      if (teacher == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Teacher not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': teacher.toJson(),
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

  // GET /api/teachers/user/:userId
  Future<Response> _getTeacherByUserId(Request request, String userId) async {
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

      final teacher = await _teacherService.getTeacherByUserId(id);

      if (teacher == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Teacher not found for this user',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': teacher.toJson(),
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

  // GET /api/teachers
  Future<Response> _getAllTeachers(Request request) async {
    try {
      final activoParam = request.url.queryParameters['activo'];
      bool? activo;

      if (activoParam != null) {
        activo = activoParam.toLowerCase() == 'true';
      }

      final teachers = await _teacherService.getAllTeachers(activo: activo);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': teachers.map((t) => t.toJson()).toList(),
          'count': teachers.length,
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

  // PUT /api/teachers/:id
  Future<Response> _updateTeacher(Request request, String id) async {
    try {
      final teacherId = int.tryParse(id);
      if (teacherId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid teacher ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updates = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final success = await _teacherService.updateTeacher(teacherId, updates);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Teacher updated successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Teacher not found',
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

  // DELETE /api/teachers/:id
  Future<Response> _deleteTeacher(Request request, String id) async {
    try {
      final teacherId = int.tryParse(id);
      if (teacherId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid teacher ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final success = await _teacherService.deleteTeacher(teacherId);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Teacher deleted successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Teacher not found',
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

  // POST /api/teachers/:id/deactivate
  Future<Response> _deactivateTeacher(Request request, String id) async {
    try {
      final teacherId = int.tryParse(id);
      if (teacherId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid teacher ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final success = await _teacherService.deactivateTeacher(teacherId);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Teacher deactivated successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Teacher not found',
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

  // POST /api/teachers/:id/activate
  Future<Response> _activateTeacher(Request request, String id) async {
    try {
      final teacherId = int.tryParse(id);
      if (teacherId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid teacher ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final success = await _teacherService.activateTeacher(teacherId);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Teacher activated successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Teacher not found',
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

  // GET /api/teachers/:id/stats
  Future<Response> _getTeacherStats(Request request, String id) async {
    try {
      final teacherId = int.tryParse(id);
      if (teacherId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid teacher ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final stats = await _teacherService.getTeacherStats(teacherId);

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

  // GET /api/teachers/specialty/:specialty
  Future<Response> _getTeachersBySpecialty(Request request, String specialty) async {
    try {
      final teachers = await _teacherService.getTeachersBySpecialty(specialty);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': teachers.map((t) => t.toJson()).toList(),
          'count': teachers.length,
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
