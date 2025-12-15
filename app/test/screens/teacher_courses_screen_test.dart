import 'package:englishpro_app/screens/teacher_courses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('TeacherCoursesScreen renderiza cursos', (tester) async {
    await tester.pumpWidget(_wrap(const TeacherCoursesScreen()));
    await tester.pump();

    final state = tester.state(find.byType(TeacherCoursesScreen)) as dynamic;
    state.setState(() {
      state._isLoading = false;
      state._errorMessage = null;
      state._courses = [
        {'id': 1, 'nombre_curso': 'TOEFL', 'tipo_curso': 'Examen', 'estilo_progreso': 'Porcentaje'},
        {'id': 2, 'nombre_curso': 'IELTS', 'tipo_curso': 'Examen', 'estilo_progreso': 'Porcentaje'},
      ];
    });
    await tester.pumpAndSettle();

    expect(find.text('My courses'), findsOneWidget);
    expect(find.text('TOEFL'), findsWidgets);
    expect(find.text('IELTS'), findsWidgets);
  });
}

