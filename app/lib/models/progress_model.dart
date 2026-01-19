/// Representa el progreso de un usuario en un curso específico.
///
/// Este modelo almacena diversas métricas sobre el avance del usuario,
/// incluyendo porcentaje completado, módulos finalizados, tiempo de estudio,
/// y estadísticas de preguntas.
class ProgressModel {
  /// El identificador único del registro de progreso.
  final int id;

  /// El ID del usuario cuyo progreso se está registrando.
  final int usuarioId;

  /// El ID del curso al que se refiere este progreso.
  final int cursoId;

  /// El porcentaje de avance en el curso (0-100), típicamente usado para cursos tipo "Examen".
  final double? avancePorcentaje;

  /// El número de módulos completados, típicamente usado para cursos tipo "Inmersivo".
  final int? modulosCompletados;

  /// La fecha y hora de la última actividad registrada en este curso.
  final DateTime ultimaActividad;

  /// El tiempo total, en minutos, que el usuario ha dedicado al curso.
  final int tiempoTotalMinutos;

  /// El número total de preguntas respondidas en el curso.
  final int preguntasRespondidas;

  /// El número total de preguntas respondidas correctamente en el curso.
  final int preguntasCorrectas;

  /// Crea una instancia de [ProgressModel].
  ///
  /// @param id El identificador único.
  /// @param usuarioId El ID del usuario.
  /// @param cursoId El ID del curso.
  /// @param avancePorcentaje El porcentaje de avance.
  /// @param modulosCompletados El número de módulos completados.
  /// @param ultimaActividad La fecha de la última actividad.
  /// @param tiempoTotalMinutos El tiempo total en minutos.
  /// @param preguntasRespondidas El número de preguntas respondidas.
  /// @param preguntasCorrectas El número de preguntas correctas.
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

  /// Crea un [ProgressModel] a partir de un mapa JSON.
  ///
  /// @param json Un mapa que contiene los datos del progreso.
  /// @return Una nueva instancia de [ProgressModel].
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

  /// Convierte esta instancia de [ProgressModel] en un mapa JSON
  /// compatible con la API/base de datos.
  ///
  /// @return Una representación en mapa del progreso.
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

  /// Calcula el porcentaje de aciertos en las preguntas respondidas.
  ///
  /// @return Un valor double entre 0.0 y 100.0 que representa el porcentaje de preguntas correctas.
  double get porcentajeAciertos {
    if (preguntasRespondidas == 0) return 0.0;
    return (preguntasCorrectas / preguntasRespondidas) * 100;
  }

  /// Verifica si el curso se considera completo.
  ///
  /// Para cursos basados en porcentaje, se considera completo si `avancePorcentaje` es 100.0.
  /// Para cursos basados en módulos, se necesitaría un total de módulos para determinar si está completo.
  ///
  /// @return `true` si el curso está completo, `false` en caso contrario.
  bool get isCompleted {
    if (avancePorcentaje != null) {
      return avancePorcentaje! >= 100.0;
    }
    // Para cursos basados en mÃ³dulos, se necesitarÃ­a el total de mÃ³dulos
    return false;
  }

  /// Devuelve una representación del progreso como una cadena de texto.
  ///
  /// Formatea el progreso como porcentaje si `avancePorcentaje` está disponible,
  /// o como el número de módulos completados si `modulosCompletados` está disponible.
  ///
  /// @return Una cadena de texto que describe el progreso actual.
  String get progresoString {
    if (avancePorcentaje != null) {
      return '${avancePorcentaje!.toStringAsFixed(1)}%';
    } else if (modulosCompletados != null) {
      return '$modulosCompletados módulos';
    }
    return '0%';
  }

  /// Crea una copia de este [ProgressModel] con los valores especificados
  /// reemplazando los valores actuales.
  ///
  /// @param id Nuevo ID del progreso.
  /// @param usuarioId Nuevo ID del usuario.
  /// @param cursoId Nuevo ID del curso.
  /// @param avancePorcentaje Nuevo porcentaje de avance.
  /// @param modulosCompletados Nuevo número de módulos completados.
  /// @param ultimaActividad Nueva fecha de última actividad.
  /// @param tiempoTotalMinutos Nuevo tiempo total en minutos.
  /// @param preguntasRespondidas Nuevo número de preguntas respondidas.
  /// @param preguntasCorrectas Nuevo número de preguntas correctas.
  /// @return Una nueva instancia de [ProgressModel] con los valores actualizados.
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
  /// Devuelve una representación en cadena de este [ProgressModel].
  String toString() {
    return 'ProgressModel(id: $id, cursoId: $cursoId, progreso: $progresoString, aciertos: ${porcentajeAciertos.toStringAsFixed(1)}%)';
  }

  @override
  /// Compara si este [ProgressModel] es igual a otro objeto.
  ///
  /// @param other El otro objeto a comparar.
  /// @return `true` si los objetos son idénticos o tienen los mismos valores en todas sus propiedades, `false` en caso contrario.
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
  /// Devuelve el código hash para este [ProgressModel].
  ///
  /// @return Un entero que representa el código hash.
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
