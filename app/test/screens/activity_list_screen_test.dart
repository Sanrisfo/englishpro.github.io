import 'package:englishpro_app/screens/activity_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('ActivityListScreen renderiza quizzes y bloquea según plan', (tester) async {
    // Dado un usuario sin sesión (plan por defecto Freemium)
    final screen = ActivityListScreen(
      skillId: 1,
      activityTypeId: 1,
      skillName: 'Reading',
      courseName: 'TOEFL',
      activityTypeName: 'Practice Tests',
    );

    await tester.pumpWidget(_wrap(screen));
    await tester.pumpAndSettle();

    // Inyectamos datos en estado para evitar red
    final state = tester.state(find.byType(ActivityListScreen)) as dynamic;
    final quizzes = List.generate(5, (i) => {
          'id_cuestionario': i + 1,
          'titulo': 'Quiz ${i + 1}',
          'tiempo_limite_minutos': 10 + i,
          'tipo_evaluacion': 'Practica',
          'activo': true,
          'descripcion': 'Desc ${i + 1}',
        });
    state.setState(() {
      state._quizzes = List<Map<String, dynamic>>.from(quizzes);
      state._isLoading = false;
      state._errorMessage = null;
    });
    await tester.pumpAndSettle();

    expect(find.text('Quiz 1'), findsOneWidget);
    expect(find.text('Quiz 5'), findsOneWidget);
    // Freemium limita a 1; el resto aparecen bloqueados
    expect(find.byIcon(Icons.lock), findsWidgets);
  });
}
