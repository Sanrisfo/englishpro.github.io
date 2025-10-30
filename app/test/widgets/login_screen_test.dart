import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:englishpro_app/screens/login_screen.dart';
import 'package:englishpro_app/providers/auth_provider.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    Widget createLoginScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('LoginScreen should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.text('EnglishPro'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('LoginScreen should have email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('LoginScreen should have login button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('LoginScreen should have Sign Up link', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('Email field should show error when empty', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Find and tap the login button without entering data
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Email field should show error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalidemail');

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Password field should show error when empty', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter email only
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Password field should toggle visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Find and tap visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pump();

      // After tapping, visibility icon should change to visibility_off
      final visibilityOffButton = find.byIcon(Icons.visibility_off);
      expect(visibilityOffButton, findsOneWidget);

      // Tap again to hide
      await tester.tap(visibilityOffButton);
      await tester.pump();

      // Should show visibility icon again
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Should have email and lock icons', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('Form fields should accept text input', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
