/// Quiz Model - Backend
/// Matches Cuestionarios table schema
class Quiz {
  final int? id;
  final int habilidadId;
  final String titulo;
  final String? descripcion;
  final int? duracionMinutos;
  final int puntosTotales;
  final String nivelDificultad; // 'Basico', 'Intermedio', 'Avanzado'
  final String nivelAcceso; // 'Freemium', 'Basico', 'Pro', 'Premium'
  final DateTime? fechaCreacion;
  final int? creadoPor;

  Quiz({
    this.id,
    required this.habilidadId,
    required this.titulo,
    this.descripcion,
    this.duracionMinutos,
    this.puntosTotales = 0,
    this.nivelDificultad = 'Basico',
    this.nivelAcceso = 'Freemium',
    this.fechaCreacion,
    this.creadoPor,
  });

  /// Create Quiz from database row
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id_cuestionario'] as int?,
      habilidadId: map['id_habilidad'] as int,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      duracionMinutos: map['duracion_minutos'] as int?,
      puntosTotales: map['puntos_totales'] as int? ?? 0,
      nivelDificultad: map['nivel_dificultad'] as String? ?? 'Basico',
      nivelAcceso: map['nivel_acceso'] as String? ?? 'Freemium',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
      creadoPor: map['creado_por'] as int?,
    );
  }

  /// Convert Quiz to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_cuestionario': id,
      'id_habilidad': habilidadId,
      'titulo': titulo,
      'descripcion': descripcion,
      'duracion_minutos': duracionMinutos,
      'puntos_totales': puntosTotales,
      'nivel_dificultad': nivelDificultad,
      'nivel_acceso': nivelAcceso,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion!.toIso8601String(),
      'creado_por': creadoPor,
    };
  }

  /// Convert Quiz to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habilidad_id': habilidadId,
      'titulo': titulo,
      'descripcion': descripcion,
      'duracion_minutos': duracionMinutos,
      'puntos_totales': puntosTotales,
      'nivel_dificultad': nivelDificultad,
      'nivel_acceso': nivelAcceso,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'creado_por': creadoPor,
    };
  }

  /// Create Quiz from JSON request
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int?,
      habilidadId: json['habilidad_id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      duracionMinutos: json['duracion_minutos'] as int?,
      puntosTotales: json['puntos_totales'] as int? ?? 0,
      nivelDificultad: json['nivel_dificultad'] as String? ?? 'Basico',
      nivelAcceso: json['nivel_acceso'] as String? ?? 'Freemium',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      creadoPor: json['creado_por'] as int?,
    );
  }
}

/// Quiz Question Association Model
/// Matches Cuestionario_Preguntas table schema
class QuizQuestion {
  final int? id;
  final int cuestionarioId;
  final int preguntaId;
  final int orden;

  QuizQuestion({
    this.id,
    required this.cuestionarioId,
    required this.preguntaId,
    this.orden = 1,
  });

  /// Create QuizQuestion from database row
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id_cuestionario_pregunta'] as int?,
      cuestionarioId: map['id_cuestionario'] as int,
      preguntaId: map['id_pregunta'] as int,
      orden: map['orden'] as int? ?? 1,
    );
  }

  /// Convert QuizQuestion to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_cuestionario_pregunta': id,
      'id_cuestionario': cuestionarioId,
      'id_pregunta': preguntaId,
      'orden': orden,
    };
  }

  /// Convert QuizQuestion to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cuestionario_id': cuestionarioId,
      'pregunta_id': preguntaId,
      'orden': orden,
    };
  }

  /// Create QuizQuestion from JSON request
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int?,
      cuestionarioId: json['cuestionario_id'] as int,
      preguntaId: json['pregunta_id'] as int,
      orden: json['orden'] as int? ?? 1,
    );
  }
}

/// User Quiz Attempt Model
/// Matches Intentos_Cuestionario table schema
class QuizAttempt {
  final int? id;
  final int usuarioId;
  final int cuestionarioId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int puntosObtenidos;
  final int puntosTotales;
  final double? porcentaje;
  final String estado; // 'En Progreso', 'Completado', 'Abandonado'

  QuizAttempt({
    this.id,
    required this.usuarioId,
    required this.cuestionarioId,
    this.fechaInicio,
    this.fechaFin,
    this.puntosObtenidos = 0,
    this.puntosTotales = 0,
    this.porcentaje,
    this.estado = 'En Progreso',
  });

  /// Create QuizAttempt from database row
  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id_intento'] as int?,
      usuarioId: map['id_usuario'] as int,
      cuestionarioId: map['id_cuestionario'] as int,
      fechaInicio: map['fecha_inicio'] != null
          ? DateTime.parse(map['fecha_inicio'] as String)
          : null,
      fechaFin: map['fecha_fin'] != null
          ? DateTime.parse(map['fecha_fin'] as String)
          : null,
      puntosObtenidos: map['puntos_obtenidos'] as int? ?? 0,
      puntosTotales: map['puntos_totales'] as int? ?? 0,
      porcentaje: map['porcentaje'] as double?,
      estado: map['estado'] as String? ?? 'En Progreso',
    );
  }

  /// Convert QuizAttempt to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_intento': id,
      'id_usuario': usuarioId,
      'id_cuestionario': cuestionarioId,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio!.toIso8601String(),
      if (fechaFin != null) 'fecha_fin': fechaFin!.toIso8601String(),
      'puntos_obtenidos': puntosObtenidos,
      'puntos_totales': puntosTotales,
      'porcentaje': porcentaje,
      'estado': estado,
    };
  }

  /// Convert QuizAttempt to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'cuestionario_id': cuestionarioId,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'puntos_obtenidos': puntosObtenidos,
      'puntos_totales': puntosTotales,
      'porcentaje': porcentaje,
      'estado': estado,
    };
  }

  /// Create QuizAttempt from JSON request
  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as int?,
      usuarioId: json['usuario_id'] as int,
      cuestionarioId: json['cuestionario_id'] as int,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      puntosObtenidos: json['puntos_obtenidos'] as int? ?? 0,
      puntosTotales: json['puntos_totales'] as int? ?? 0,
      porcentaje: json['porcentaje'] as double?,
      estado: json['estado'] as String? ?? 'En Progreso',
    );
  }
}
