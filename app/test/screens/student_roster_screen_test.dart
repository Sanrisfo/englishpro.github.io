import 'package:englishpro_app/screens/student_roster_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('StudentRosterScreen lista estudiantes y permite filtrar en memoria', (tester) async {
    await tester.pumpWidget(_wrap(const StudentRosterScreen()));
    await tester.pump();

    final state = tester.state(find.byType(StudentRosterScreen)) as dynamic;
    state.setState(() {
      state._isLoading = false;
      state._errorMessage = null;
      state._plans = [
        {'id_plan': 1, 'nombre_plan': 'Freemium'},
        {'id_plan': 2, 'nombre_plan': 'Básico'},
      ];
      state._students = [
        {'id_usuario': 1, 'nombre_completo': 'Alice', 'email': 'alice@mail.com', 'id_plan': 1, 'rol': 'Estudiante'},
        {'id_usuario': 2, 'nombre_completo': 'Bob', 'email': 'bob@mail.com', 'id_plan': 2, 'rol': 'Estudiante'},
      ];
    });
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);

    // Filtro visual: simular búsqueda escribiendo en el primer TextField
    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'alice');
    await tester.pumpAndSettle();

    // Debe quedar solo Alice visible
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });
}

