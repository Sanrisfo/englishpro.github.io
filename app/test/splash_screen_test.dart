import 'package:englishpro_app/screens/home_screen.dart';
import 'package:englishpro_app/screens/login_screen.dart';
import 'package:englishpro_app/screens/splash_screen.dart';
import 'package:englishpro_app/screens/teacher_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash routes to Login when no token', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('Splash routes to Home for student', (tester) async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'abc',
      'user_role': 'Estudiante',
      'user_is_teacher': false,
    });
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Your fluency starts here.'), findsOneWidget);
  });

  testWidgets('Splash routes to TeacherDashboard for teacher', (tester) async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'abc',
      'user_role': 'Docente',
      'user_is_teacher': true,
    });
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(TeacherDashboardScreen), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
  });
}

