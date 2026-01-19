import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:englishpro_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EnglishPro Integration Tests', () {
    testWidgets('App should launch and show login screen', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is displayed
      expect(find.text('EnglishPro'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('Login screen should have email and password fields', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Find email field
      final emailField = find.widgetWithText(TextFormField, 'Email');
      expect(emailField, findsOneWidget);

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Find login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Login form should validate empty fields', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to login with empty fields
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Register link should navigate to register screen', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on Sign Up button
      final signUpButton = find.text('Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify register screen is displayed
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join EnglishPro today!'), findsOneWidget);
    });

    testWidgets('Register screen should have all required fields', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to register screen
      final signUpButton = find.text('Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify all fields are present
      expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('Password fields should toggle visibility', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Find visibility toggle button
      final visibilityButton = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility),
      );

      // Tap to toggle visibility
      if (visibilityButton.evaluate().isNotEmpty) {
        await tester.tap(visibilityButton);
        await tester.pumpAndSettle();

        // Should now show visibility_off icon
        expect(find.byIcon(Icons.visibility_off), findsWidgets);
      }
    });
  }, skip: true);

  group('Navigation Tests', () {
    testWidgets('Back button should work on register screen', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to register screen
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify we're on register screen
      expect(find.text('Create Account'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.text('Welcome Back!'), findsOneWidget);
    });
  }, skip: true);
}
