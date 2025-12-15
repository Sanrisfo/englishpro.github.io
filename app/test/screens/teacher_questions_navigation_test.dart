import 'package:englishpro_app/screens/create_question_screen.dart';
import 'package:englishpro_app/screens/teacher_questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('TeacherQuestionsScreen: FAB navega a CreateQuestionScreen', (tester) async {
    await tester.pumpWidget(_wrap(const TeacherQuestionsScreen(
      quizId: 1,
      skillId: 1,
      quizTitle: 'Quiz A',
      courseName: 'TOEFL',
      skillName: 'Reading',
    )));

    // Destrabar loading
    final state = tester.state(find.byType(TeacherQuestionsScreen)) as dynamic;
    state.setState(() {
      state._isLoading = false;
      state._errorMessage = null;
      state._allowedTypes = const ['multiple_choice', 'matching', 'completion'];
      state._items = const [];
    });
    await tester.pumpAndSettle();

    // Tap en FAB "New Question"
    final newQuestionFab = find.widgetWithText(FloatingActionButton, 'New Question');
    expect(newQuestionFab, findsOneWidget);
    await tester.tap(newQuestionFab);
    await tester.pumpAndSettle();

    // Debe navegar a CreateQuestionScreen
    expect(find.byType(CreateQuestionScreen), findsOneWidget);
    // El selector de tipos muestra etiquetas (por ejemplo 'Choice')
    expect(find.text('Choice'), findsOneWidget);
  });
}

