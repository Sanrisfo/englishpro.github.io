import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/notification_service.dart';

class NotificationRoutes {
  final _notificationService = NotificationService();

  Router get router {
    final router = Router();

    // POST /api/notifications - Create notification
    router.post('/', _createNotification);

    // GET /api/notifications/:userId - Get all notifications for user
    router.get('/<userId>', _getNotifications);

    // GET /api/notifications/:userId/unread - Get unread notifications
    router.get('/<userId>/unread', _getUnreadNotifications);

    // GET /api/notifications/:userId/count - Get notification count
    router.get('/<userId>/count', _getNotificationCount);

    // PUT /api/notifications/:id/read - Mark as read
    router.put('/<id>/read', _markAsRead);

    // PUT /api/notifications/:userId/read-all - Mark all as read
    router.put('/<userId>/read-all', _markAllAsRead);

    // DELETE /api/notifications/:id - Delete notification
    router.delete('/<id>', _deleteNotification);

    return router;
  }

  Future<Response> _createNotification(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final idUsuario = data['id_usuario'] as int?;
      final titulo = data['titulo'] as String?;
      final mensaje = data['mensaje'] as String?;
      final tipo = data['tipo'] as String? ?? 'Info';

      if (idUsuario == null || titulo == null || mensaje == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'id_usuario, titulo, and mensaje are required'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _notificationService.createNotification(
        idUsuario: idUsuario,
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
      );

      if (result['success'] == true) {
        return Response.ok(
          jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response(
          400,
          body: jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getNotifications(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _notificationService.getNotificationsByUserId(id);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getUnreadNotifications(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _notificationService.getUnreadNotifications(id);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getNotificationCount(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _notificationService.getNotificationCount(id);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _markAsRead(Request request, String id) async {
    try {
      final notificationId = int.tryParse(id);
      if (notificationId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Invalid notification ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _notificationService.markAsRead(notificationId);

      if (result['success'] == true) {
        return Response.ok(
          jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response(
          404,
          body: jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _markAllAsRead(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _notificationService.markAllAsRead(id);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteNotification(Request request, String id) async {
    try {
      final notificationId = int.tryParse(id);
      if (notificationId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Invalid notification ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _notificationService.deleteNotification(notificationId);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Server error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
