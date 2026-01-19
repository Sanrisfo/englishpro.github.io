import 'package:englishpro_app/screens/teacher_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('TeacherDashboardScreen muestra acciones y métricas básicas', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const TeacherDashboardScreen()));
    await tester.pump();

    // Inyectar estado sin red
    final state = tester.state(find.byType(TeacherDashboardScreen)) as dynamic;
    state.setState(() {
      state._isLoading = false;
      state._errorMessage = null;
      state._teacherData = {'id_docente': 1};
      state._teacherStats = {
        'total_calificaciones': 10,
        'calificadas': 8,
        'pendientes': 2,
        'promedio_puntuacion': 4.5,
      };
      state._pendingFeedbacks = [];
    });
    await tester.pumpAndSettle();

    // Verifica secciones visibles
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('My courses'), findsWidgets);
    expect(find.text('Student roster'), findsWidgets);
    expect(find.text('Manual review'), findsWidgets);

    // Vacío de pendientes
    expect(find.text('No pending submissions'), findsOneWidget);
  });
}
