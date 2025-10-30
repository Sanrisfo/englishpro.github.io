import 'package:flutter_test/flutter_test.dart';
import 'package:englishpro_app/models/progress_model.dart';

void main() {
  group('ProgressModel Tests', () {
    test('ProgressModel.fromJson should correctly parse JSON with percentage-based progress', () {
      final json = {
        'id': 1,
        'usuario_id': 100,
        'curso_id': 1,
        'avance_porcentaje': 75.5,
        'modulos_completados': null,
        'ultima_actividad': '2024-01-15T10:30:00.000Z',
        'tiempo_total_minutos': 120,
        'preguntas_respondidas': 50,
        'preguntas_correctas': 40,
      };

      final progress = ProgressModel.fromJson(json);

      expect(progress.id, 1);
      expect(progress.usuarioId, 100);
      expect(progress.cursoId, 1);
      expect(progress.avancePorcentaje, 75.5);
      expect(progress.modulosCompletados, null);
      expect(progress.ultimaActividad, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(progress.tiempoTotalMinutos, 120);
      expect(progress.preguntasRespondidas, 50);
      expect(progress.preguntasCorrectas, 40);
    });

    test('ProgressModel.fromJson should correctly parse JSON with module-based progress', () {
      final json = {
        'id': 2,
        'usuario_id': 101,
        'curso_id': 3,
        'avance_porcentaje': null,
        'modulos_completados': 5,
        'ultima_actividad': '2024-01-20T14:00:00.000Z',
        'tiempo_total_minutos': 200,
        'preguntas_respondidas': 30,
        'preguntas_correctas': 27,
      };

      final progress = ProgressModel.fromJson(json);

      expect(progress.id, 2);
      expect(progress.usuarioId, 101);
      expect(progress.cursoId, 3);
      expect(progress.avancePorcentaje, null);
      expect(progress.modulosCompletados, 5);
      expect(progress.tiempoTotalMinutos, 200);
    });

    test('ProgressModel.toJson should correctly convert to JSON', () {
      final progress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 80.0,
        modulosCompletados: null,
        ultimaActividad: DateTime.parse('2024-01-15T10:30:00.000Z'),
        tiempoTotalMinutos: 150,
        preguntasRespondidas: 60,
        preguntasCorrectas: 50,
      );

      final json = progress.toJson();

      expect(json['id'], 1);
      expect(json['usuario_id'], 100);
      expect(json['curso_id'], 1);
      expect(json['avance_porcentaje'], 80.0);
      expect(json['modulos_completados'], null);
      expect(json['ultima_actividad'], '2024-01-15T10:30:00.000Z');
      expect(json['tiempo_total_minutos'], 150);
      expect(json['preguntas_respondidas'], 60);
      expect(json['preguntas_correctas'], 50);
    });

    test('porcentajeAciertos should calculate correctly', () {
      final progress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.0,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      expect(progress.porcentajeAciertos, 80.0); // 40/50 * 100
    });

    test('porcentajeAciertos should return 0 when no questions answered', () {
      final progress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 0.0,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 0,
        preguntasRespondidas: 0,
        preguntasCorrectas: 0,
      );

      expect(progress.porcentajeAciertos, 0.0);
    });

    test('isCompleted should return true when percentage is 100 or more', () {
      final completed = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 100.0,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 200,
        preguntasRespondidas: 100,
        preguntasCorrectas: 90,
      );

      final overCompleted = ProgressModel(
        id: 2,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 110.0,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 200,
        preguntasRespondidas: 100,
        preguntasCorrectas: 95,
      );

      expect(completed.isCompleted, true);
      expect(overCompleted.isCompleted, true);
    });

    test('isCompleted should return false when percentage is less than 100', () {
      final incomplete = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.0,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      expect(incomplete.isCompleted, false);
    });

    test('isCompleted should return false for module-based progress (no total modules)', () {
      final moduleProgress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 3,
        modulosCompletados: 5,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 30,
        preguntasCorrectas: 25,
      );

      expect(moduleProgress.isCompleted, false);
    });

    test('progresoString should return percentage format for percentage-based', () {
      final progress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.5,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      expect(progress.progresoString, '75.5%');
    });

    test('progresoString should return modules format for module-based', () {
      final progress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 3,
        modulosCompletados: 5,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 30,
        preguntasCorrectas: 25,
      );

      expect(progress.progresoString, '5 módulos');
    });

    test('progresoString should return 0% when no progress data', () {
      final progress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 0,
        preguntasRespondidas: 0,
        preguntasCorrectas: 0,
      );

      expect(progress.progresoString, '0%');
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 50.0,
        ultimaActividad: DateTime.parse('2024-01-15T10:00:00.000Z'),
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      final updated = original.copyWith(
        avancePorcentaje: 75.0,
        preguntasRespondidas: 60,
        preguntasCorrectas: 50,
      );

      expect(updated.id, 1);
      expect(updated.usuarioId, 100);
      expect(updated.cursoId, 1);
      expect(updated.avancePorcentaje, 75.0);
      expect(updated.preguntasRespondidas, 60);
      expect(updated.preguntasCorrectas, 50);
      expect(updated.tiempoTotalMinutos, 100); // unchanged
    });

    test('equality operator should work correctly', () {
      final now = DateTime.parse('2024-01-15T10:00:00.000Z');

      final progress1 = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.0,
        ultimaActividad: now,
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      final progress2 = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.0,
        ultimaActividad: now,
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      final progress3 = ProgressModel(
        id: 2,
        usuarioId: 101,
        cursoId: 2,
        avancePorcentaje: 50.0,
        ultimaActividad: now,
        tiempoTotalMinutos: 50,
        preguntasRespondidas: 30,
        preguntasCorrectas: 25,
      );

      expect(progress1 == progress2, true);
      expect(progress1 == progress3, false);
    });

    test('hashCode should be consistent for equal objects', () {
      final now = DateTime.parse('2024-01-15T10:00:00.000Z');

      final progress1 = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.0,
        ultimaActividad: now,
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      final progress2 = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.0,
        ultimaActividad: now,
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      expect(progress1.hashCode, progress2.hashCode);
    });

    test('toString should return a readable string representation', () {
      final progress = ProgressModel(
        id: 1,
        usuarioId: 100,
        cursoId: 1,
        avancePorcentaje: 75.0,
        ultimaActividad: DateTime.now(),
        tiempoTotalMinutos: 100,
        preguntasRespondidas: 50,
        preguntasCorrectas: 40,
      );

      final str = progress.toString();
      expect(str, contains('ProgressModel'));
      expect(str, contains('id: 1'));
      expect(str, contains('cursoId: 1'));
      expect(str, contains('progreso: 75.0%'));
      expect(str, contains('aciertos: 80.0%'));
    });

    test('fromJson should handle integer avance_porcentaje', () {
      final json = {
        'id': 1,
        'usuario_id': 100,
        'curso_id': 1,
        'avance_porcentaje': 75, // Integer instead of double
        'ultima_actividad': '2024-01-15T10:30:00.000Z',
        'tiempo_total_minutos': 120,
        'preguntas_respondidas': 50,
        'preguntas_correctas': 40,
      };

      final progress = ProgressModel.fromJson(json);
      expect(progress.avancePorcentaje, 75.0);
    });
  });
}
