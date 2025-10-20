import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/course_service.dart';
import '../models/course_model.dart';

class CourseRoutes {
  final CourseService _courseService = CourseService();
  final Router router = Router();

  CourseRoutes() {
    _setupRoutes();
  }

  void _setupRoutes() {
    // GET /api/courses - Get all courses
    router.get('/', _getAllCourses);

    // GET /api/courses/<id> - Get course by ID
    router.get('/<id>', _getCourseById);

    // POST /api/courses - Create new course
    router.post('/', _createCourse);

    // PUT /api/courses/<id> - Update course
    router.put('/<id>', _updateCourse);

    // DELETE /api/courses/<id> - Delete course
    router.delete('/<id>', _deleteCourse);
  }

  /// GET /api/courses
  Future<Response> _getAllCourses(Request request) async {
    try {
      final courses = await _courseService.getAllCourses();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': courses.map((c) => c.toJson()).toList(),
          'count': courses.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch courses: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/courses/<id>
  Future<Response> _getCourseById(Request request, String id) async {
    try {
      final courseId = int.tryParse(id);
      if (courseId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid course ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final course = await _courseService.getCourseById(courseId);

      if (course == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Course not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': course.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch course: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/courses
  Future<Response> _createCourse(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final course = Course.fromJson(data);
      final createdCourse = await _courseService.createCourse(course);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'data': createdCourse.toJson(),
          'message': 'Course created successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to create course: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /api/courses/<id>
  Future<Response> _updateCourse(Request request, String id) async {
    try {
      final courseId = int.tryParse(id);
      if (courseId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid course ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final course = Course.fromJson(data);
      final updatedCourse = await _courseService.updateCourse(courseId, course);

      if (updatedCourse == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Course not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': updatedCourse.toJson(),
          'message': 'Course updated successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to update course: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /api/courses/<id>
  Future<Response> _deleteCourse(Request request, String id) async {
    try {
      final courseId = int.tryParse(id);
      if (courseId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid course ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _courseService.deleteCourse(courseId);

      if (!deleted) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Course not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Course deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to delete course: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
