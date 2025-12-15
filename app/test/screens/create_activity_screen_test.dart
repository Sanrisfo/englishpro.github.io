import 'package:englishpro_app/screens/create_activity_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: child);

  testWidgets('CreateActivityScreen: valida título requerido', (tester) async {
    await tester.pumpWidget(_wrap(const CreateActivityScreen(
      skillId: 1,
      skillName: 'Reading',
      courseName: 'TOEFL',
      activityTypeId: 1,
      activityTypeName: 'Practice',
    )));

    await tester.pumpAndSettle();

    // Tap en Create sin título
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pump();

    // Debe mostrar snackbar de validación
    expect(find.text('Title is required'), findsOneWidget);
  });

  testWidgets('CreateActivityScreen: alterna material y tipos', (tester) async {
    await tester.pumpWidget(_wrap(const CreateActivityScreen(
      skillId: 1,
      skillName: 'Reading',
      courseName: 'TOEFL',
      activityTypeId: 1,
      activityTypeName: 'Practice',
    )));

    await tester.pumpAndSettle();

    // Habilitar switch Add Material
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    // Cambiar tipo de material a Text
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text').last);
    await tester.pumpAndSettle();

    // Debe aparecer el campo de texto para contenido
    expect(find.widgetWithText(TextField, 'Text content'), findsOneWidget);
  });
}

