import 'package:englishpro_app/models/course_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CourseModel getters behave as expected', () {
    final toefl = CourseModel(
      id: 1,
      nombre: 'TOEFL',
      descripcion: '',
      tipoCurso: 'Examen',
      estiloProgreso: 'Porcentaje',
      activo: true,
    );

    expect(toefl.isExamCourse, isTrue);
    expect(toefl.isImmersiveCourse, isFalse);
    expect(toefl.isPercentageBased, isTrue);
    expect(toefl.isModuleBased, isFalse);
    expect(toefl.colorHex, '#2563EB');

    final business = toefl.copyWith(
      nombre: 'Business English',
      tipoCurso: 'Inmersivo',
      estiloProgreso: 'Modular',
    );
    expect(business.isImmersiveCourse, isTrue);
    expect(business.isModuleBased, isTrue);
    expect(business.colorHex, '#F59E0B');
  });
}
