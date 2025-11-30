import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/notification.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Bandeja de notificaciones del usuario con lectura/borrado.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int _userId = 0;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndNotifications();
    // Configure timeago to use Spanish
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  Future<void> _loadUserIdAndNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    setState(() {
      _userId = userId;
    });

    if (userId > 0) {
      await _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getNotificationsByUserId(_userId);

    if (result['success'] == true) {
      final notificationsData = result['notifications'] as List<dynamic>;
      final notifications = notificationsData
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _notifications = notifications;
        _unreadCount = notifications.where((n) => !n.leida).length;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error loading notifications'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.leida) return;

    final result = await ApiService.markNotificationAsRead(notification.idNotificacion);

    if (result['success'] == true) {
      await _loadNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    final result = await ApiService.markAllNotificationsAsRead(_userId);

    if (result['success'] == true) {
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ApiService.deleteNotification(notification.idNotificacion);

      if (result['success'] == true) {
        await _loadNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'Retroalimentacion':
        return Icons.feedback;
      case 'Pago':
        return Icons.payment;
      case 'Sistema':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String tipo) {
    switch (tipo) {
      case 'Retroalimentacion':
        return Colors.blue;
      case 'Pago':
        return Colors.green;
      case 'Sistema':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isUnread = !notification.leida;

                      return Dismissible(
                        key: Key(notification.idNotificacion.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        onDismissed: (direction) {
                          _deleteNotification(notification);
                        },
                        child: GestureDetector(
                          onTap: () => _markAsRead(notification),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isUnread ? Colors.blue[50] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _getColorForType(notification.tipo).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForType(notification.tipo),
                                  color: _getColorForType(notification.tipo),
                                  size: 24,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.titulo,
                                      style: TextStyle(
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (isUnread)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.mensaje,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.fechaCreacion != null
                                        ? timeago.format(
                                            notification.fechaCreacion!,
                                            locale: 'en',
                                          )
                                        : 'Just now',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'mark_read') {
                                    _markAsRead(notification);
                                  } else if (value == 'delete') {
                                    _deleteNotification(notification);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (isUnread)
                                    const PopupMenuItem(
                                      value: 'mark_read',
                                      child: Row(
                                        children: [
                                          Icon(Icons.done, size: 20),
                                          SizedBox(width: 8),
                                          Text('Mark as read'),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
