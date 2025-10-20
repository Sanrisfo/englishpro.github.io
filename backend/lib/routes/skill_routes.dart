import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/skill_service.dart';
import '../models/skill_model.dart';

class SkillRoutes {
  final SkillService _skillService = SkillService();
  final Router router = Router();

  SkillRoutes() {
    _setupRoutes();
  }

  void _setupRoutes() {
    // GET /api/skills - Get all skills
    router.get('/', _getAllSkills);

    // GET /api/skills/<id> - Get skill by ID
    router.get('/<id>', _getSkillById);

    // GET /api/skills/course/<courseId> - Get skills by course ID
    router.get('/course/<courseId>', _getSkillsByCourseId);

    // POST /api/skills - Create new skill
    router.post('/', _createSkill);

    // PUT /api/skills/<id> - Update skill
    router.put('/<id>', _updateSkill);

    // DELETE /api/skills/<id> - Delete skill
    router.delete('/<id>', _deleteSkill);
  }

  /// GET /api/skills
  Future<Response> _getAllSkills(Request request) async {
    try {
      final skills = await _skillService.getAllSkills();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': skills.map((s) => s.toJson()).toList(),
          'count': skills.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch skills: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/skills/course/<courseId>
  Future<Response> _getSkillsByCourseId(Request request, String courseId) async {
    try {
      final id = int.tryParse(courseId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid course ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final skills = await _skillService.getSkillsByCourseId(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': skills.map((s) => s.toJson()).toList(),
          'count': skills.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch skills: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/skills/<id>
  Future<Response> _getSkillById(Request request, String id) async {
    try {
      final skillId = int.tryParse(id);
      if (skillId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid skill ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final skill = await _skillService.getSkillById(skillId);

      if (skill == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Skill not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': skill.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch skill: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/skills
  Future<Response> _createSkill(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final skill = Skill.fromJson(data);
      final createdSkill = await _skillService.createSkill(skill);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'data': createdSkill.toJson(),
          'message': 'Skill created successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to create skill: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /api/skills/<id>
  Future<Response> _updateSkill(Request request, String id) async {
    try {
      final skillId = int.tryParse(id);
      if (skillId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid skill ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final skill = Skill.fromJson(data);
      final updatedSkill = await _skillService.updateSkill(skillId, skill);

      if (updatedSkill == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Skill not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': updatedSkill.toJson(),
          'message': 'Skill updated successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to update skill: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /api/skills/<id>
  Future<Response> _deleteSkill(Request request, String id) async {
    try {
      final skillId = int.tryParse(id);
      if (skillId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid skill ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _skillService.deleteSkill(skillId);

      if (!deleted) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Skill not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Skill deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to delete skill: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
