/// Progress Model - Representa el progreso de un usuario en un curso
class ProgressModel {
  final int id;
  final int usuarioId;
  final int cursoId;
  final double? avancePorcentaje; // Para TOEFL/IELTS (0-100)
  final int? modulosCompletados; // Para Business English/English in Action
  final DateTime ultimaActividad;
  final int tiempoTotalMinutos;
  final int preguntasRespondidas;
  final int preguntasCorrectas;

  ProgressModel({
    required this.id,
    required this.usuarioId,
    required this.cursoId,
    this.avancePorcentaje,
    this.modulosCompletados,
    required this.ultimaActividad,
    required this.tiempoTotalMinutos,
    required this.preguntasRespondidas,
    required this.preguntasCorrectas,
  });

  /// Crear ProgressModel desde JSON
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      cursoId: json['curso_id'] as int,
      avancePorcentaje: json['avance_porcentaje'] != null
          ? (json['avance_porcentaje'] as num).toDouble()
          : null,
      modulosCompletados: json['modulos_completados'] as int?,
      ultimaActividad: DateTime.parse(json['ultima_actividad'] as String),
      tiempoTotalMinutos: json['tiempo_total_minutos'] as int,
      preguntasRespondidas: json['preguntas_respondidas'] as int,
      preguntasCorrectas: json['preguntas_correctas'] as int,
    );
  }

  /// Convertir ProgressModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'curso_id': cursoId,
      'avance_porcentaje': avancePorcentaje,
      'modulos_completados': modulosCompletados,
      'ultima_actividad': ultimaActividad.toIso8601String(),
      'tiempo_total_minutos': tiempoTotalMinutos,
      'preguntas_respondidas': preguntasRespondidas,
      'preguntas_correctas': preguntasCorrectas,
    };
  }

  /// Calcular porcentaje de aciertos
  double get porcentajeAciertos {
    if (preguntasRespondidas == 0) return 0.0;
    return (preguntasCorrectas / preguntasRespondidas) * 100;
  }

  /// Verificar si el curso está completo
  bool get isCompleted {
    if (avancePorcentaje != null) {
      return avancePorcentaje! >= 100.0;
    }
    // Para cursos basados en módulos, se necesitaría el total de módulos
    return false;
  }

  /// Obtener progreso como string
  String get progresoString {
    if (avancePorcentaje != null) {
      return '${avancePorcentaje!.toStringAsFixed(1)}%';
    } else if (modulosCompletados != null) {
      return '$modulosCompletados módulos';
    }
    return '0%';
  }

  /// Crear copia del modelo con cambios
  ProgressModel copyWith({
    int? id,
    int? usuarioId,
    int? cursoId,
    double? avancePorcentaje,
    int? modulosCompletados,
    DateTime? ultimaActividad,
    int? tiempoTotalMinutos,
    int? preguntasRespondidas,
    int? preguntasCorrectas,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      cursoId: cursoId ?? this.cursoId,
      avancePorcentaje: avancePorcentaje ?? this.avancePorcentaje,
      modulosCompletados: modulosCompletados ?? this.modulosCompletados,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
      tiempoTotalMinutos: tiempoTotalMinutos ?? this.tiempoTotalMinutos,
      preguntasRespondidas: preguntasRespondidas ?? this.preguntasRespondidas,
      preguntasCorrectas: preguntasCorrectas ?? this.preguntasCorrectas,
    );
  }

  @override
  String toString() {
    return 'ProgressModel(id: $id, cursoId: $cursoId, progreso: $progresoString, aciertos: ${porcentajeAciertos.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProgressModel &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.cursoId == cursoId &&
        other.avancePorcentaje == avancePorcentaje &&
        other.modulosCompletados == modulosCompletados &&
        other.ultimaActividad == ultimaActividad &&
        other.tiempoTotalMinutos == tiempoTotalMinutos &&
        other.preguntasRespondidas == preguntasRespondidas &&
        other.preguntasCorrectas == preguntasCorrectas;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        usuarioId.hashCode ^
        cursoId.hashCode ^
        avancePorcentaje.hashCode ^
        modulosCompletados.hashCode ^
        ultimaActividad.hashCode ^
        tiempoTotalMinutos.hashCode ^
        preguntasRespondidas.hashCode ^
        preguntasCorrectas.hashCode;
  }
}
