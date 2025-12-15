import 'package:englishpro_app/screens/create_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('CreateQuestionScreen: construye UI y muestra selector de tipo', (tester) async {
    await tester.pumpWidget(_wrap(const CreateQuestionScreen(
      quizId: 1,
      skillId: 1,
      courseName: 'TOEFL',
      allowedTypes: ['multiple_choice', 'matching', 'completion'],
    )));

    // La pantalla hace init async; damos tiempo
    await tester.pumpAndSettle();

    // Debe existir el selector horizontal de tipos (al menos uno visible)
    expect(find.text('Choice'), findsOneWidget);
    expect(find.text('Match'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
  });
}

