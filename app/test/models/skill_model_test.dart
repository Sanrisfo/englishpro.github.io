import 'package:flutter_test/flutter_test.dart';
import 'package:englishpro_app/models/skill_model.dart';

void main() {
  group('SkillModel Tests', () {
    test('SkillModel.fromJson should correctly parse JSON with all fields', () {
      final json = {
        'id': 1,
        'curso_id': 1,
        'nombre': 'Reading',
        'descripcion': 'Improve your reading comprehension',
        'icon_url': 'https://example.com/reading.png',
        'orden': 1,
      };

      final skill = SkillModel.fromJson(json);

      expect(skill.id, 1);
      expect(skill.cursoId, 1);
      expect(skill.nombre, 'Reading');
      expect(skill.descripcion, 'Improve your reading comprehension');
      expect(skill.iconUrl, 'https://example.com/reading.png');
      expect(skill.orden, 1);
    });

    test('SkillModel.fromJson should handle missing optional fields', () {
      final json = {
        'id': 2,
        'curso_id': 1,
        'nombre': 'Writing',
        'descripcion': 'Master writing skills',
        'orden': 2,
      };

      final skill = SkillModel.fromJson(json);

      expect(skill.id, 2);
      expect(skill.cursoId, 1);
      expect(skill.nombre, 'Writing');
      expect(skill.iconUrl, null);
    });

    test('SkillModel.toJson should correctly convert to JSON', () {
      final skill = SkillModel(
        id: 3,
        cursoId: 2,
        nombre: 'Listening',
        descripcion: 'Practice listening to various accents',
        iconUrl: 'https://example.com/listening.png',
        orden: 3,
      );

      final json = skill.toJson();

      expect(json['id'], 3);
      expect(json['curso_id'], 2);
      expect(json['nombre'], 'Listening');
      expect(json['descripcion'], 'Practice listening to various accents');
      expect(json['icon_url'], 'https://example.com/listening.png');
      expect(json['orden'], 3);
    });

    test('isReading should return true only for Reading skill', () {
      final reading = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Reading skill',
        orden: 1,
      );

      final writing = SkillModel(
        id: 2,
        cursoId: 1,
        nombre: 'Writing',
        descripcion: 'Writing skill',
        orden: 2,
      );

      expect(reading.isReading, true);
      expect(writing.isReading, false);
    });

    test('isWriting should return true only for Writing skill', () {
      final writing = SkillModel(
        id: 2,
        cursoId: 1,
        nombre: 'Writing',
        descripcion: 'Writing skill',
        orden: 2,
      );

      final listening = SkillModel(
        id: 3,
        cursoId: 1,
        nombre: 'Listening',
        descripcion: 'Listening skill',
        orden: 3,
      );

      expect(writing.isWriting, true);
      expect(listening.isWriting, false);
    });

    test('isListening should return true only for Listening skill', () {
      final listening = SkillModel(
        id: 3,
        cursoId: 1,
        nombre: 'Listening',
        descripcion: 'Listening skill',
        orden: 3,
      );

      final speaking = SkillModel(
        id: 4,
        cursoId: 1,
        nombre: 'Speaking',
        descripcion: 'Speaking skill',
        orden: 4,
      );

      expect(listening.isListening, true);
      expect(speaking.isListening, false);
    });

    test('isSpeaking should return true only for Speaking skill', () {
      final speaking = SkillModel(
        id: 4,
        cursoId: 1,
        nombre: 'Speaking',
        descripcion: 'Speaking skill',
        orden: 4,
      );

      final reading = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Reading skill',
        orden: 1,
      );

      expect(speaking.isSpeaking, true);
      expect(reading.isSpeaking, false);
    });

    test(
      'requiresManualFeedback should return true for Writing and Speaking',
      () {
        final writing = SkillModel(
          id: 2,
          cursoId: 1,
          nombre: 'Writing',
          descripcion: 'Writing skill',
          orden: 2,
        );

        final speaking = SkillModel(
          id: 4,
          cursoId: 1,
          nombre: 'Speaking',
          descripcion: 'Speaking skill',
          orden: 4,
        );

        final reading = SkillModel(
          id: 1,
          cursoId: 1,
          nombre: 'Reading',
          descripcion: 'Reading skill',
          orden: 1,
        );

        final listening = SkillModel(
          id: 3,
          cursoId: 1,
          nombre: 'Listening',
          descripcion: 'Listening skill',
          orden: 3,
        );

        expect(writing.requiresManualFeedback, true);
        expect(speaking.requiresManualFeedback, true);
        expect(reading.requiresManualFeedback, false);
        expect(listening.requiresManualFeedback, false);
      },
    );

    test('skill type checkers should be case insensitive', () {
      final reading = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'READING',
        descripcion: 'Reading skill',
        orden: 1,
      );

      final writing = SkillModel(
        id: 2,
        cursoId: 1,
        nombre: 'writing',
        descripcion: 'Writing skill',
        orden: 2,
      );

      expect(reading.isReading, true);
      expect(writing.isWriting, true);
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Original description',
        orden: 1,
      );

      final updated = original.copyWith(
        descripcion: 'Updated description',
        orden: 5,
      );

      expect(updated.id, 1);
      expect(updated.cursoId, 1);
      expect(updated.nombre, 'Reading');
      expect(updated.descripcion, 'Updated description');
      expect(updated.orden, 5);
    });

    test('equality operator should work correctly', () {
      final skill1 = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Test',
        orden: 1,
      );

      final skill2 = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Test',
        orden: 1,
      );

      final skill3 = SkillModel(
        id: 2,
        cursoId: 1,
        nombre: 'Writing',
        descripcion: 'Different',
        orden: 2,
      );

      expect(skill1 == skill2, true);
      expect(skill1 == skill3, false);
    });

    test('hashCode should be consistent for equal objects', () {
      final skill1 = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Test',
        orden: 1,
      );

      final skill2 = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Test',
        orden: 1,
      );

      expect(skill1.hashCode, skill2.hashCode);
    });

    test('toString should return a readable string representation', () {
      final skill = SkillModel(
        id: 1,
        cursoId: 1,
        nombre: 'Reading',
        descripcion: 'Test',
        orden: 1,
      );

      final str = skill.toString();
      expect(str, contains('SkillModel'));
      expect(str, contains('id: 1'));
      expect(str, contains('nombre: Reading'));
      expect(str, contains('cursoId: 1'));
    });
  });
}
