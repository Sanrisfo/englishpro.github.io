import 'package:flutter_test/flutter_test.dart';
import 'package:englishpro_app/models/notification.dart';

void main() {
  group('Notification Model Tests', () {
    test('NotificationModel.fromJson should correctly parse JSON', () {
      final json = {
        'id_notificacion': 1,
        'id_usuario': 5,
        'titulo': 'Test Notification',
        'mensaje': 'This is a test message',
        'tipo': 'Info',
        'leida': false,
        'fecha_creacion': '2024-01-01T00:00:00.000Z',
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.idNotificacion, 1);
      expect(notification.idUsuario, 5);
      expect(notification.titulo, 'Test Notification');
      expect(notification.mensaje, 'This is a test message');
      expect(notification.tipo, 'Info');
      expect(notification.leida, false);
      expect(notification.fechaCreacion, isNotNull);
    });

    test('NotificationModel.toJson should correctly convert to JSON', () {
      final notification = NotificationModel(
        idNotificacion: 1,
        idUsuario: 5,
        titulo: 'Test Title',
        mensaje: 'Test Message',
        tipo: 'Pago',
        leida: true,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final json = notification.toJson();

      expect(json['id_notificacion'], 1);
      expect(json['id_usuario'], 5);
      expect(json['titulo'], 'Test Title');
      expect(json['mensaje'], 'Test Message');
      expect(json['tipo'], 'Pago');
      expect(json['leida'], true);
      expect(json['fecha_creacion'], isNotNull);
    });

    test('NotificationModel should have default values', () {
      final notification = NotificationModel(
        idNotificacion: 1,
        idUsuario: 5,
        titulo: 'Title',
        mensaje: 'Message',
      );

      expect(notification.tipo, 'Info');
      expect(notification.leida, false);
    });

    test('NotificationModel should handle different tipos', () {
      final tipos = ['Info', 'Retroalimentacion', 'Pago', 'Sistema'];

      for (final tipo in tipos) {
        final notification = NotificationModel(
          idNotificacion: 1,
          idUsuario: 5,
          titulo: 'Test',
          mensaje: 'Test Message',
          tipo: tipo,
        );

        expect(notification.tipo, tipo);
      }
    });

    test(
      'NotificationModel.fromJson should handle missing optional fields',
      () {
        final json = {
          'id_notificacion': 1,
          'id_usuario': 5,
          'titulo': 'Minimal Notification',
          'mensaje': 'Minimal Message',
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.idNotificacion, 1);
        expect(notification.idUsuario, 5);
        expect(notification.titulo, 'Minimal Notification');
        expect(notification.mensaje, 'Minimal Message');
        expect(notification.tipo, 'Info'); // default
        expect(notification.leida, false); // default
      },
    );
  });
}
