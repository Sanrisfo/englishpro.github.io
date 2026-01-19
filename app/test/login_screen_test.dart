import 'package:englishpro_app/models/user.dart' as models;
import 'package:englishpro_app/providers/auth_provider.dart';
import 'package:englishpro_app/screens/home_screen.dart';
import 'package:englishpro_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Mockito replaced with a simple fake for stability in non-nullable named args
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:englishpro_app/services/supabase_auth_service.dart';

class FakeSupabaseAuthService extends SupabaseAuthService {
  final models.User user;
  FakeSupabaseAuthService(this.user) : super();

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return {
      'success': true,
      'user': user,
      'session': _FakeSession('token-abc'),
    };
  }
}

class _FakeSession {
  final String? accessToken;
  _FakeSession(this.accessToken);
}

void main() {
  testWidgets('LoginScreen logs in and navigates to HomeScreen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final user = models.User(
      idUsuario: 42,
      nombreCompleto: 'Jane Doe',
      email: 'jane@example.com',
      idPlan: 1,
      rol: 'Estudiante',
    );
    final fakeAuth = FakeSupabaseAuthService(user);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const MaterialApp(home: SizedBox()),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: MaterialApp(
          home: LoginScreen(authService: fakeAuth),
          routes: {'/home': (_) => const HomeScreen()},
        ),
      ),
    );

    // Enter credentials
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'jane@example.com');
    await tester.enterText(passwordField, 'secret123');

    // Tap login button
    final loginButton = find.text('Login');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Expect HomeScreen content to be present (headline text)
    expect(find.text('Your fluency starts here.'), findsOneWidget);
  });
}
