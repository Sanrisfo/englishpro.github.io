import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/material_service.dart';
import '../models/material_model.dart';

class MaterialRoutes {
  final MaterialService _materialService = MaterialService();
  final Router router = Router();

  MaterialRoutes() {
    _setupRoutes();
  }

  void _setupRoutes() {
    // GET /api/materials - Get all materials
    router.get('/', _getAllMaterials);

    // GET /api/materials/<id> - Get material by ID
    router.get('/<id>', _getMaterialById);

    // GET /api/materials/skill/<skillId> - Get materials by skill ID
    router.get('/skill/<skillId>', _getMaterialsBySkillId);

    // POST /api/materials - Create new material
    router.post('/', _createMaterial);

    // PUT /api/materials/<id> - Update material
    router.put('/<id>', _updateMaterial);

    // DELETE /api/materials/<id> - Delete material
    router.delete('/<id>', _deleteMaterial);
  }

  /// GET /api/materials
  Future<Response> _getAllMaterials(Request request) async {
    try {
      final materials = await _materialService.getAllMaterials();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': materials.map((m) => m.toJson()).toList(),
          'count': materials.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch materials: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/materials/skill/<skillId>
  Future<Response> _getMaterialsBySkillId(Request request, String skillId) async {
    try {
      final id = int.tryParse(skillId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid skill ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final materials = await _materialService.getMaterialsBySkillId(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': materials.map((m) => m.toJson()).toList(),
          'count': materials.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch materials: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/materials/<id>
  Future<Response> _getMaterialById(Request request, String id) async {
    try {
      final materialId = int.tryParse(id);
      if (materialId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid material ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final material = await _materialService.getMaterialById(materialId);

      if (material == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Material not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': material.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to fetch material: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/materials
  Future<Response> _createMaterial(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final material = Material.fromJson(data);
      final createdMaterial = await _materialService.createMaterial(material);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'data': createdMaterial.toJson(),
          'message': 'Material created successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to create material: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /api/materials/<id>
  Future<Response> _updateMaterial(Request request, String id) async {
    try {
      final materialId = int.tryParse(id);
      if (materialId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid material ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final material = Material.fromJson(data);
      final updatedMaterial = await _materialService.updateMaterial(materialId, material);

      if (updatedMaterial == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Material not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': updatedMaterial.toJson(),
          'message': 'Material updated successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to update material: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /api/materials/<id>
  Future<Response> _deleteMaterial(Request request, String id) async {
    try {
      final materialId = int.tryParse(id);
      if (materialId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid material ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _materialService.deleteMaterial(materialId);

      if (!deleted) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Material not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Material deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to delete material: ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
