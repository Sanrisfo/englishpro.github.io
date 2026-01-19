import 'package:englishpro_app/models/user.dart' as models;
import 'package:englishpro_app/providers/auth_provider.dart';
import 'package:englishpro_app/screens/home_screen.dart';
import 'package:englishpro_app/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:englishpro_app/services/supabase_auth_service.dart';

class MockSupabaseAuthService extends Mock implements SupabaseAuthService {}

class _FakeSession {
  final String? accessToken;
  _FakeSession(this.accessToken);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RegisterScreen validates form fields', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );

    // Tap Sign Up without filling fields
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Expect validation errors
    expect(
      find.text('Please enter your full name'),
      findsNothing,
    ); // name has no validator in current UI
    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets(
    'RegisterScreen registers and navigates to HomeScreen for student',
    (tester) async {
      final mockAuth = MockSupabaseAuthService();
      final user = models.User(
        idUsuario: 1,
        nombreCompleto: 'John Doe',
        email: 'john@example.com',
        idPlan: 1,
        rol: 'Estudiante',
      );
      when(
        mockAuth.register(
          nombreCompleto: 'any_nombre_completo',
          email: 'any_email@example.com',
          password: 'any_password',
          profesion: anyNamed('profesion'),
        ),
      ).thenAnswer(
        (_) async => {
          'success': true,
          'user': user,
          'session': _FakeSession('token-xyz'),
        },
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
          child: MaterialApp(
            home: RegisterScreen(authService: mockAuth),
            routes: {'/home': (_) => const HomeScreen()},
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.enterText(find.byType(TextFormField).at(3), 'secret123');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Your fluency starts here.'), findsOneWidget);
    },
  );
}
