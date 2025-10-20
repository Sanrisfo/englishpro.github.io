import 'package:logging/logging.dart';
import '../models/notification_model.dart';
import 'database_service.dart';

class NotificationService {
  final _log = Logger('NotificationService');
  final _db = DatabaseService();

  // Create notification
  Future<Map<String, dynamic>> createNotification({
    required int idUsuario,
    required String titulo,
    required String mensaje,
    String tipo = 'Info',
  }) async {
    try {
      final result = await _db.query(
        '''
        INSERT INTO Notificaciones (id_usuario, titulo, mensaje, tipo, leida)
        VALUES (@id_usuario, @titulo, @mensaje, @tipo, false)
        RETURNING *
        ''',
        parameters: {
          'id_usuario': idUsuario,
          'titulo': titulo,
          'mensaje': mensaje,
          'tipo': tipo,
        },
      );

      if (result.isEmpty) {
        return {
          'success': false,
          'message': 'Failed to create notification',
        };
      }

      final notification = Notification.fromJson(result.first);
      _log.info('✅ Notification created: ${notification.idNotificacion}');

      return {
        'success': true,
        'message': 'Notification created successfully',
        'notification': notification.toJson(),
      };
    } catch (e) {
      _log.severe('Create notification failed: $e');
      return {
        'success': false,
        'message': 'Failed to create notification: $e',
      };
    }
  }

  // Get all notifications for a user
  Future<Map<String, dynamic>> getNotificationsByUserId(int userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT * FROM Notificaciones
        WHERE id_usuario = @user_id
        ORDER BY fecha_creacion DESC
        ''',
        parameters: {'user_id': userId},
      );

      final notifications = result.map((row) => Notification.fromJson(row).toJson()).toList();

      return {
        'success': true,
        'notifications': notifications,
        'count': notifications.length,
      };
    } catch (e) {
      _log.severe('Get notifications failed: $e');
      return {
        'success': false,
        'message': 'Failed to get notifications: $e',
      };
    }
  }

  // Get unread notifications for a user
  Future<Map<String, dynamic>> getUnreadNotifications(int userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT * FROM Notificaciones
        WHERE id_usuario = @user_id AND leida = false
        ORDER BY fecha_creacion DESC
        ''',
        parameters: {'user_id': userId},
      );

      final notifications = result.map((row) => Notification.fromJson(row).toJson()).toList();

      return {
        'success': true,
        'notifications': notifications,
        'count': notifications.length,
      };
    } catch (e) {
      _log.severe('Get unread notifications failed: $e');
      return {
        'success': false,
        'message': 'Failed to get unread notifications: $e',
      };
    }
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      final result = await _db.query(
        '''
        UPDATE Notificaciones
        SET leida = true
        WHERE id_notificacion = @id
        RETURNING *
        ''',
        parameters: {'id': notificationId},
      );

      if (result.isEmpty) {
        return {
          'success': false,
          'message': 'Notification not found',
        };
      }

      final notification = Notification.fromJson(result.first);

      return {
        'success': true,
        'message': 'Notification marked as read',
        'notification': notification.toJson(),
      };
    } catch (e) {
      _log.severe('Mark as read failed: $e');
      return {
        'success': false,
        'message': 'Failed to mark notification as read: $e',
      };
    }
  }

  // Mark all notifications as read for a user
  Future<Map<String, dynamic>> markAllAsRead(int userId) async {
    try {
      await _db.execute(
        '''
        UPDATE Notificaciones
        SET leida = true
        WHERE id_usuario = @user_id AND leida = false
        ''',
        parameters: {'user_id': userId},
      );

      return {
        'success': true,
        'message': 'All notifications marked as read',
      };
    } catch (e) {
      _log.severe('Mark all as read failed: $e');
      return {
        'success': false,
        'message': 'Failed to mark all notifications as read: $e',
      };
    }
  }

  // Delete notification
  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      await _db.execute(
        'DELETE FROM Notificaciones WHERE id_notificacion = @id',
        parameters: {'id': notificationId},
      );

      return {
        'success': true,
        'message': 'Notification deleted successfully',
      };
    } catch (e) {
      _log.severe('Delete notification failed: $e');
      return {
        'success': false,
        'message': 'Failed to delete notification: $e',
      };
    }
  }

  // Get notification count for a user
  Future<Map<String, dynamic>> getNotificationCount(int userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT
          COUNT(*) as total,
          COUNT(CASE WHEN leida = false THEN 1 END) as unread
        FROM Notificaciones
        WHERE id_usuario = @user_id
        ''',
        parameters: {'user_id': userId},
      );

      if (result.isEmpty) {
        return {
          'success': true,
          'total': 0,
          'unread': 0,
        };
      }

      final row = result.first;
      return {
        'success': true,
        'total': row['total'] as int,
        'unread': row['unread'] as int,
      };
    } catch (e) {
      _log.severe('Get notification count failed: $e');
      return {
        'success': false,
        'message': 'Failed to get notification count: $e',
      };
    }
  }
}
