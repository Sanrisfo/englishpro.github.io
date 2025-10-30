import 'package:flutter_test/flutter_test.dart';
import 'package:englishpro_app/models/course_model.dart';

void main() {
  group('CourseModel Tests', () {
    test('CourseModel.fromJson should correctly parse JSON with all fields', () {
      final json = {
        'id': 1,
        'nombre': 'TOEFL',
        'descripcion': 'Test of English as a Foreign Language',
        'tipo_curso': 'Examen',
        'estilo_progreso': 'Porcentaje',
        'url_imagen': 'https://example.com/toefl.png',
        'fecha_creacion': '2024-01-01T00:00:00.000Z',
        'activo': true,
      };

      final course = CourseModel.fromJson(json);

      expect(course.id, 1);
      expect(course.nombre, 'TOEFL');
      expect(course.descripcion, 'Test of English as a Foreign Language');
      expect(course.tipoCurso, 'Examen');
      expect(course.estiloProgreso, 'Porcentaje');
      expect(course.urlImagen, 'https://example.com/toefl.png');
      expect(course.fechaCreacion, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(course.activo, true);
    });

    test('CourseModel.fromJson should handle missing optional fields', () {
      final json = {
        'id': 2,
        'nombre': 'IELTS',
        'tipo_curso': 'Examen',
        'estilo_progreso': 'Porcentaje',
      };

      final course = CourseModel.fromJson(json);

      expect(course.id, 2);
      expect(course.nombre, 'IELTS');
      expect(course.descripcion, ''); // default
      expect(course.urlImagen, null);
      expect(course.fechaCreacion, null);
      expect(course.activo, true); // default
    });

    test('CourseModel.toJson should correctly convert to JSON', () {
      final course = CourseModel(
        id: 3,
        nombre: 'Business English',
        descripcion: 'Professional English for the Workplace',
        tipoCurso: 'Inmersivo',
        estiloProgreso: 'Modular',
        urlImagen: 'https://example.com/business.png',
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
        activo: true,
      );

      final json = course.toJson();

      expect(json['id'], 3);
      expect(json['nombre'], 'Business English');
      expect(json['descripcion'], 'Professional English for the Workplace');
      expect(json['tipo_curso'], 'Inmersivo');
      expect(json['estilo_progreso'], 'Modular');
      expect(json['url_imagen'], 'https://example.com/business.png');
      expect(json['fecha_creacion'], '2024-01-01T00:00:00.000Z');
      expect(json['activo'], true);
    });

    test('isPercentageBased should return true for percentage-based courses', () {
      final course = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      expect(course.isPercentageBased, true);
      expect(course.isModuleBased, false);
    });

    test('isModuleBased should return true for module-based courses', () {
      final course = CourseModel(
        id: 3,
        nombre: 'Business English',
        descripcion: 'Professional English',
        tipoCurso: 'Inmersivo',
        estiloProgreso: 'Modular',
      );

      expect(course.isModuleBased, true);
      expect(course.isPercentageBased, false);
    });

    test('isExamCourse should return true for exam courses', () {
      final course = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      expect(course.isExamCourse, true);
      expect(course.isImmersiveCourse, false);
    });

    test('isImmersiveCourse should return true for immersive courses', () {
      final course = CourseModel(
        id: 3,
        nombre: 'Business English',
        descripcion: 'Professional English',
        tipoCurso: 'Inmersivo',
        estiloProgreso: 'Modular',
      );

      expect(course.isImmersiveCourse, true);
      expect(course.isExamCourse, false);
    });

    test('colorHex should return correct colors for each course', () {
      final toefl = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );
      expect(toefl.colorHex, '#2563EB'); // Blue

      final ielts = CourseModel(
        id: 2,
        nombre: 'IELTS',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );
      expect(ielts.colorHex, '#10B981'); // Green

      final business = CourseModel(
        id: 3,
        nombre: 'Business English',
        descripcion: 'Professional',
        tipoCurso: 'Inmersivo',
        estiloProgreso: 'Modular',
      );
      expect(business.colorHex, '#F59E0B'); // Orange

      final action = CourseModel(
        id: 4,
        nombre: 'English in Action',
        descripcion: 'Real-life English',
        tipoCurso: 'Inmersivo',
        estiloProgreso: 'Modular',
      );
      expect(action.colorHex, '#8B5CF6'); // Purple

      final unknown = CourseModel(
        id: 5,
        nombre: 'Unknown Course',
        descripcion: 'Unknown',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );
      expect(unknown.colorHex, '#6B7280'); // Gray (default)
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Original description',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
        activo: true,
      );

      final updated = original.copyWith(
        descripcion: 'Updated description',
        activo: false,
      );

      expect(updated.id, 1);
      expect(updated.nombre, 'TOEFL');
      expect(updated.descripcion, 'Updated description');
      expect(updated.tipoCurso, 'Examen');
      expect(updated.estiloProgreso, 'Porcentaje');
      expect(updated.activo, false);
    });

    test('equality operator should work correctly', () {
      final course1 = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      final course2 = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      final course3 = CourseModel(
        id: 2,
        nombre: 'IELTS',
        descripcion: 'Different',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      expect(course1 == course2, true);
      expect(course1 == course3, false);
    });

    test('hashCode should be consistent for equal objects', () {
      final course1 = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      final course2 = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      expect(course1.hashCode, course2.hashCode);
    });

    test('toString should return a readable string representation', () {
      final course = CourseModel(
        id: 1,
        nombre: 'TOEFL',
        descripcion: 'Test',
        tipoCurso: 'Examen',
        estiloProgreso: 'Porcentaje',
      );

      final str = course.toString();
      expect(str, contains('CourseModel'));
      expect(str, contains('id: 1'));
      expect(str, contains('nombre: TOEFL'));
      expect(str, contains('tipoCurso: Examen'));
      expect(str, contains('estiloProgreso: Porcentaje'));
    });
  });
}
