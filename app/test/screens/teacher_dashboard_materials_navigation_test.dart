import 'package:englishpro_app/screens/teacher_dashboard_screen.dart';
import 'package:englishpro_app/screens/teacher_materials_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('TeacherDashboard: navega a My materials', (tester) async {
    await tester.pumpWidget(_wrap(const TeacherDashboardScreen()));
    await tester.pump();

    // Inyectar estado no-cargando
    final state = tester.state(find.byType(TeacherDashboardScreen)) as dynamic;
    state.setState(() {
      state._isLoading = false;
      state._errorMessage = null;
      state._teacherData = {'id_docente': 1};
      state._teacherStats = {
        'total_calificaciones': 0,
        'calificadas': 0,
        'pendientes': 0,
        'promedio_puntuacion': 0.0,
      };
      state._pendingFeedbacks = [];
    });
    await tester.pumpAndSettle();

    // Tap en la tarjeta "My materials"
    final tile = find.text('My materials');
    expect(tile, findsOneWidget);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    // Debe navegar a TeacherMaterialsScreen
    expect(find.byType(TeacherMaterialsScreen), findsOneWidget);
  });
}
