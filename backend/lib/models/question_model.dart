/// Question Model - Backend
/// Matches Preguntas table schema
class Question {
  final int? id;
  final int habilidadId;
  final String textoPregunta;
  final String tipoPregunta; // 'Multiple Choice', 'Texto Abierto', 'Audio Grabacion'
  final String? urlAudio;
  final String? urlVideo;
  final String? urlImagen;
  final int puntos;
  final String nivelDificultad; // 'Basico', 'Intermedio', 'Avanzado'
  final String nivelAcceso; // 'Freemium', 'Basico', 'Pro', 'Premium'
  final DateTime? fechaCreacion;
  final int? creadoPor;

  Question({
    this.id,
    required this.habilidadId,
    required this.textoPregunta,
    required this.tipoPregunta,
    this.urlAudio,
    this.urlVideo,
    this.urlImagen,
    this.puntos = 1,
    this.nivelDificultad = 'Basico',
    this.nivelAcceso = 'Freemium',
    this.fechaCreacion,
    this.creadoPor,
  });

  /// Create Question from database row
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id_pregunta'] as int?,
      habilidadId: map['id_habilidad'] as int,
      textoPregunta: map['texto_pregunta'] as String,
      tipoPregunta: map['tipo_pregunta'] as String,
      urlAudio: map['url_audio'] as String?,
      urlVideo: map['url_video'] as String?,
      urlImagen: map['url_imagen'] as String?,
      puntos: map['puntos'] as int? ?? 1,
      nivelDificultad: map['nivel_dificultad'] as String? ?? 'Basico',
      nivelAcceso: map['nivel_acceso'] as String? ?? 'Freemium',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
      creadoPor: map['creado_por'] as int?,
    );
  }

  /// Convert Question to database map (for INSERT/UPDATE)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_pregunta': id,
      'id_habilidad': habilidadId,
      'texto_pregunta': textoPregunta,
      'tipo_pregunta': tipoPregunta,
      'url_audio': urlAudio,
      'url_video': urlVideo,
      'url_imagen': urlImagen,
      'puntos': puntos,
      'nivel_dificultad': nivelDificultad,
      'nivel_acceso': nivelAcceso,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion!.toIso8601String(),
      'creado_por': creadoPor,
    };
  }

  /// Convert Question to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habilidad_id': habilidadId,
      'texto_pregunta': textoPregunta,
      'tipo_pregunta': tipoPregunta,
      'url_audio': urlAudio,
      'url_video': urlVideo,
      'url_imagen': urlImagen,
      'puntos': puntos,
      'nivel_dificultad': nivelDificultad,
      'nivel_acceso': nivelAcceso,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'creado_por': creadoPor,
    };
  }

  /// Create Question from JSON request
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int?,
      habilidadId: json['habilidad_id'] as int,
      textoPregunta: json['texto_pregunta'] as String,
      tipoPregunta: json['tipo_pregunta'] as String,
      urlAudio: json['url_audio'] as String?,
      urlVideo: json['url_video'] as String?,
      urlImagen: json['url_imagen'] as String?,
      puntos: json['puntos'] as int? ?? 1,
      nivelDificultad: json['nivel_dificultad'] as String? ?? 'Basico',
      nivelAcceso: json['nivel_acceso'] as String? ?? 'Freemium',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      creadoPor: json['creado_por'] as int?,
    );
  }
}

/// Answer Option Model - Backend
/// Matches Opciones_Respuesta table schema
class AnswerOption {
  final int? id;
  final int preguntaId;
  final String textoOpcion;
  final bool esCorrecta;
  final int orden;

  AnswerOption({
    this.id,
    required this.preguntaId,
    required this.textoOpcion,
    this.esCorrecta = false,
    this.orden = 1,
  });

  /// Create AnswerOption from database row
  factory AnswerOption.fromMap(Map<String, dynamic> map) {
    return AnswerOption(
      id: map['id_opcion'] as int?,
      preguntaId: map['id_pregunta'] as int,
      textoOpcion: map['texto_opcion'] as String,
      esCorrecta: map['es_correcta'] as bool? ?? false,
      orden: map['orden'] as int? ?? 1,
    );
  }

  /// Convert AnswerOption to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_opcion': id,
      'id_pregunta': preguntaId,
      'texto_opcion': textoOpcion,
      'es_correcta': esCorrecta,
      'orden': orden,
    };
  }

  /// Convert AnswerOption to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta_id': preguntaId,
      'texto_opcion': textoOpcion,
      'es_correcta': esCorrecta,
      'orden': orden,
    };
  }

  /// Create AnswerOption from JSON request
  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] as int?,
      preguntaId: json['pregunta_id'] as int,
      textoOpcion: json['texto_opcion'] as String,
      esCorrecta: json['es_correcta'] as bool? ?? false,
      orden: json['orden'] as int? ?? 1,
    );
  }
}

/// User Answer Model - Backend
/// Matches Respuestas_Usuario table schema
class UserAnswer {
  final int? id;
  final int usuarioId;
  final int preguntaId;
  final int? opcionSeleccionadaId;
  final String? textoEnsayo;
  final String? urlGrabacion;
  final bool? esCorrecta;
  final int puntosObtenidos;
  final DateTime? fechaRespuesta;
  final bool requiereRevision;

  UserAnswer({
    this.id,
    required this.usuarioId,
    required this.preguntaId,
    this.opcionSeleccionadaId,
    this.textoEnsayo,
    this.urlGrabacion,
    this.esCorrecta,
    this.puntosObtenidos = 0,
    this.fechaRespuesta,
    this.requiereRevision = false,
  });

  /// Create UserAnswer from database row
  factory UserAnswer.fromMap(Map<String, dynamic> map) {
    return UserAnswer(
      id: map['id_respuesta'] as int?,
      usuarioId: map['id_usuario'] as int,
      preguntaId: map['id_pregunta'] as int,
      opcionSeleccionadaId: map['id_opcion_seleccionada'] as int?,
      textoEnsayo: map['texto_ensayo'] as String?,
      urlGrabacion: map['url_grabacion'] as String?,
      esCorrecta: map['es_correcta'] as bool?,
      puntosObtenidos: map['puntos_obtenidos'] as int? ?? 0,
      fechaRespuesta: map['fecha_respuesta'] != null
          ? DateTime.parse(map['fecha_respuesta'] as String)
          : null,
      requiereRevision: map['requiere_revision'] as bool? ?? false,
    );
  }

  /// Convert UserAnswer to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_respuesta': id,
      'id_usuario': usuarioId,
      'id_pregunta': preguntaId,
      'id_opcion_seleccionada': opcionSeleccionadaId,
      'texto_ensayo': textoEnsayo,
      'url_grabacion': urlGrabacion,
      'es_correcta': esCorrecta,
      'puntos_obtenidos': puntosObtenidos,
      if (fechaRespuesta != null) 'fecha_respuesta': fechaRespuesta!.toIso8601String(),
      'requiere_revision': requiereRevision,
    };
  }

  /// Convert UserAnswer to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'pregunta_id': preguntaId,
      'opcion_seleccionada_id': opcionSeleccionadaId,
      'texto_ensayo': textoEnsayo,
      'url_grabacion': urlGrabacion,
      'es_correcta': esCorrecta,
      'puntos_obtenidos': puntosObtenidos,
      'fecha_respuesta': fechaRespuesta?.toIso8601String(),
      'requiere_revision': requiereRevision,
    };
  }

  /// Create UserAnswer from JSON request
  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      id: json['id'] as int?,
      usuarioId: json['usuario_id'] as int,
      preguntaId: json['pregunta_id'] as int,
      opcionSeleccionadaId: json['opcion_seleccionada_id'] as int?,
      textoEnsayo: json['texto_ensayo'] as String?,
      urlGrabacion: json['url_grabacion'] as String?,
      esCorrecta: json['es_correcta'] as bool?,
      puntosObtenidos: json['puntos_obtenidos'] as int? ?? 0,
      fechaRespuesta: json['fecha_respuesta'] != null
          ? DateTime.parse(json['fecha_respuesta'] as String)
          : null,
      requiereRevision: json['requiere_revision'] as bool? ?? false,
    );
  }
}
