class Progress {
  final int? idProgreso;
  final int idUsuario;
  final int idCurso;
  final double avancePorcentaje;
  final int modulosCompletados;
  final int preguntasRespondidas;
  final int preguntasCorrectas;
  final int puntosTotales;
  final DateTime? ultimaActividad;
  final DateTime? fechaInicio;

  Progress({
    this.idProgreso,
    required this.idUsuario,
    required this.idCurso,
    this.avancePorcentaje = 0.0,
    this.modulosCompletados = 0,
    this.preguntasRespondidas = 0,
    this.preguntasCorrectas = 0,
    this.puntosTotales = 0,
    this.ultimaActividad,
    this.fechaInicio,
  });

  factory Progress.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Progress(
      idProgreso: map['id_progreso'] as int?,
      idUsuario: map['id_usuario'] as int,
      idCurso: map['id_curso'] as int,
      avancePorcentaje: parseDouble(map['avance_porcentaje']),
      modulosCompletados: parseInt(map['modulos_completados']),
      preguntasRespondidas: parseInt(map['preguntas_respondidas']),
      preguntasCorrectas: parseInt(map['preguntas_correctas']),
      puntosTotales: parseInt(map['puntos_totales']),
      ultimaActividad: map['ultima_actividad'] != null
          ? DateTime.parse(map['ultima_actividad'].toString())
          : null,
      fechaInicio: map['fecha_inicio'] != null
          ? DateTime.parse(map['fecha_inicio'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_progreso': idProgreso,
      'id_usuario': idUsuario,
      'id_curso': idCurso,
      'avance_porcentaje': avancePorcentaje,
      'modulos_completados': modulosCompletados,
      'preguntas_respondidas': preguntasRespondidas,
      'preguntas_correctas': preguntasCorrectas,
      'puntos_totales': puntosTotales,
      'ultima_actividad': ultimaActividad?.toIso8601String(),
      'fecha_inicio': fechaInicio?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idProgreso,
      'userId': idUsuario,
      'courseId': idCurso,
      'progressPercentage': avancePorcentaje,
      'modulesCompleted': modulosCompletados,
      'questionsAnswered': preguntasRespondidas,
      'correctAnswers': preguntasCorrectas,
      'totalPoints': puntosTotales,
      'lastActivity': ultimaActividad?.toIso8601String(),
      'startDate': fechaInicio?.toIso8601String(),
    };
  }
}

// User statistics model
class UserStats {
  final int userId;
  final int totalPoints;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final double accuracyPercentage;
  final int coursesStarted;
  final int coursesCompleted;
  final int quizzesCompleted;
  final DateTime? lastActivity;

  UserStats({
    required this.userId,
    this.totalPoints = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.accuracyPercentage = 0.0,
    this.coursesStarted = 0,
    this.coursesCompleted = 0,
    this.quizzesCompleted = 0,
    this.lastActivity,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'accuracyPercentage': accuracyPercentage,
      'coursesStarted': coursesStarted,
      'coursesCompleted': coursesCompleted,
      'quizzesCompleted': quizzesCompleted,
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }
}
