class Feedback {
  final int? id;
  final int usuarioId;
  final int preguntaId;
  final int? docenteId;
  final String tipoRespuesta; // 'Writing' o 'Speaking'
  final String? respuestaTexto;
  final String? respuestaAudioUrl;
  final double? puntuacion;
  final String? comentarios;
  final String estado; // 'Pendiente', 'Calificada', 'Revisada'
  final DateTime? fechaRespuesta;
  final DateTime? fechaCalificacion;

  Feedback({
    this.id,
    required this.usuarioId,
    required this.preguntaId,
    this.docenteId,
    required this.tipoRespuesta,
    this.respuestaTexto,
    this.respuestaAudioUrl,
    this.puntuacion,
    this.comentarios,
    this.estado = 'Pendiente',
    this.fechaRespuesta,
    this.fechaCalificacion,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id_feedback'] as int?,
      usuarioId: json['id_usuario'] as int,
      preguntaId: json['id_pregunta'] as int,
      docenteId: json['id_docente'] as int?,
      tipoRespuesta: json['tipo_respuesta'] as String,
      respuestaTexto: json['respuesta_texto'] as String?,
      respuestaAudioUrl: json['respuesta_audio_url'] as String?,
      puntuacion: json['puntuacion'] != null ? (json['puntuacion'] as num).toDouble() : null,
      comentarios: json['comentarios'] as String?,
      estado: json['estado'] as String? ?? 'Pendiente',
      fechaRespuesta: json['fecha_respuesta'] != null
          ? DateTime.parse(json['fecha_respuesta'] as String)
          : null,
      fechaCalificacion: json['fecha_calificacion'] != null
          ? DateTime.parse(json['fecha_calificacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id_feedback': id,
      'id_usuario': usuarioId,
      'id_pregunta': preguntaId,
      if (docenteId != null) 'id_docente': docenteId,
      'tipo_respuesta': tipoRespuesta,
      if (respuestaTexto != null) 'respuesta_texto': respuestaTexto,
      if (respuestaAudioUrl != null) 'respuesta_audio_url': respuestaAudioUrl,
      if (puntuacion != null) 'puntuacion': puntuacion,
      if (comentarios != null) 'comentarios': comentarios,
      'estado': estado,
      if (fechaRespuesta != null) 'fecha_respuesta': fechaRespuesta!.toIso8601String(),
      if (fechaCalificacion != null) 'fecha_calificacion': fechaCalificacion!.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id_usuario': usuarioId,
      'id_pregunta': preguntaId,
      if (docenteId != null) 'id_docente': docenteId,
      'tipo_respuesta': tipoRespuesta,
      if (respuestaTexto != null) 'respuesta_texto': respuestaTexto,
      if (respuestaAudioUrl != null) 'respuesta_audio_url': respuestaAudioUrl,
      if (puntuacion != null) 'puntuacion': puntuacion,
      if (comentarios != null) 'comentarios': comentarios,
      'estado': estado,
      if (fechaRespuesta != null) 'fecha_respuesta': fechaRespuesta,
      if (fechaCalificacion != null) 'fecha_calificacion': fechaCalificacion,
    };
  }
}
