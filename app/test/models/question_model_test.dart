import 'package:englishpro_app/models/question_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QuestionModel fromJson/toJson roundtrip for options', () {
    final json = {
      'id': 10,
      'habilidad_id': 3,
      'texto_pregunta': 'Choose the correct option',
      'tipo_pregunta': 'multiple_choice',
      'nivel_dificultad': 'easy',
      'puntaje': 5,
      'opciones': [
        {'id': 1, 'pregunta_id': 10, 'texto_opcion': 'A', 'es_correcta': false},
        {'id': 2, 'pregunta_id': 10, 'texto_opcion': 'B', 'es_correcta': true},
      ],
    };

    final q = QuestionModel.fromJson(json);
    expect(q.isMultipleChoice, isTrue);
    expect(q.opciones?.length, 2);
    final out = q.toJson();
    expect(out['id'], 10);
    expect((out['opciones'] as List).length, 2);
  });
}
