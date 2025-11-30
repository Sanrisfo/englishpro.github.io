import 'package:flutter_test/flutter_test.dart';
import 'package:englishpro_app/providers/auth_provider.dart';
import 'package:englishpro_app/models/user.dart' as models;

void main() {
  group('AuthProvider', () {
    test('setUser establishes session and notifies', () {
      final provider = AuthProvider();
      var notified = false;
      provider.addListener(() => notified = true);

      final user = models.User(
        idUsuario: 1,
        nombreCompleto: 'Test User',
        email: 'test@example.com',
        idPlan: 1,
      );

      provider.setUser(user, 'token-123');

      expect(provider.user, isNotNull);
      expect(provider.token, equals('token-123'));
      expect(provider.isAuthenticated, isTrue);
      expect(notified, isTrue);
    });

    test('logout clears session and notifies', () {
      final provider = AuthProvider();
      provider.setUser(
        models.User(
          idUsuario: 1,
          nombreCompleto: 'Test',
          email: 't@e.com',
          idPlan: 1,
        ),
        't',
      );

      var notified = false;
      provider.addListener(() => notified = true);
      provider.logout();

      expect(provider.user, isNull);
      expect(provider.token, isNull);
      expect(provider.isAuthenticated, isFalse);
      expect(notified, isTrue);
    });

    test('updateUser replaces current user', () {
      final provider = AuthProvider();
      provider.setUser(
        models.User(
          idUsuario: 1,
          nombreCompleto: 'A',
          email: 'a@e.com',
          idPlan: 1,
        ),
        't',
      );

      final updated = models.User(
        idUsuario: 1,
        nombreCompleto: 'B',
        email: 'b@e.com',
        idPlan: 1,
      );

      provider.updateUser(updated);
      expect(provider.user?.nombreCompleto, equals('B'));
    });
  });
}

