import 'matching_models.dart';
import 'completion_models.dart';

/// Question Model - Representa una pregunta multimedia
class QuestionModel {
  final int id;
  final int habilidadId;
  final String textoPregunta;
  final String tipoPregunta; // 'multiple_choice', 'matching', 'completion', 'record_audio', 'write_text'
  final String? audioUrl;
  final String? videoUrl;
  final String? imagenUrl;
  final String nivelDificultad; // 'easy', 'medium', 'hard'
  final int puntaje;
  final int? tiempoLimiteSegundos;
  // Multiple Choice
  final List<AnswerOptionModel>? opciones; // Para multiple_choice (multi-select)
  // Matching
  final List<MatchingAnswer>? matchingAnswers;
  final List<MatchingStatement>? matchingStatements;
  // Completion
  final List<CompletionSentence>? completionSentences;
  // Write Text
  final int? maxWords;
  // Record Audio
  final int? thinkTimeSeconds; // esperado 10
  final int? maxRecordSeconds; // esperado 45
  final String? explicacionGeneral; // Retroalimentación general para la pregunta

  QuestionModel({
    required this.id,
    required this.habilidadId,
    required this.textoPregunta,
    required this.tipoPregunta,
    this.audioUrl,
    this.videoUrl,
    this.imagenUrl,
    required this.nivelDificultad,
    required this.puntaje,
    this.tiempoLimiteSegundos,
    this.opciones,
    this.matchingAnswers,
    this.matchingStatements,
    this.completionSentences,
    this.maxWords,
    this.thinkTimeSeconds,
    this.maxRecordSeconds,
    this.explicacionGeneral,
  });

  /// Crear QuestionModel desde JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      habilidadId: (json['id_habilidad'] ?? json['habilidad_id']) as int,
      textoPregunta: json['texto_pregunta'] as String,
      tipoPregunta: json['tipo_pregunta'] as String,
      audioUrl: json['audio_url'] as String?,
      videoUrl: json['video_url'] as String?,
      imagenUrl: json['imagen_url'] as String?,
      nivelDificultad: json['nivel_dificultad'] as String,
      puntaje: json['puntaje'] as int,
      tiempoLimiteSegundos: json['tiempo_limite_segundos'] as int?,
      opciones: json['opciones'] != null
          ? (json['opciones'] as List)
              .map((e) => AnswerOptionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      matchingAnswers: json['matching_answers'] != null
          ? (json['matching_answers'] as List)
              .map((e) => MatchingAnswer.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      matchingStatements: json['matching_statements'] != null
          ? (json['matching_statements'] as List)
              .map((e) => MatchingStatement.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      completionSentences: json['completion_sentences'] != null
          ? (json['completion_sentences'] as List)
              .map((e) => CompletionSentence.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      maxWords: json['max_words'] as int?,
      thinkTimeSeconds: json['think_time_seconds'] as int?,
      maxRecordSeconds: json['max_record_seconds'] as int?,
      explicacionGeneral: (json['explicacion'] ?? json['explicacion_general']) as String?,
    );
  }

  /// Convertir QuestionModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_habilidad': habilidadId,
      'texto_pregunta': textoPregunta,
      'tipo_pregunta': tipoPregunta,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'imagen_url': imagenUrl,
      'nivel_dificultad': nivelDificultad,
      'puntaje': puntaje,
      'tiempo_limite_segundos': tiempoLimiteSegundos,
      'opciones': opciones?.map((e) => e.toJson()).toList(),
      'matching_answers': matchingAnswers?.map((e) => e.toJson()).toList(),
      'matching_statements': matchingStatements?.map((e) => e.toJson()).toList(),
      'completion_sentences': completionSentences?.map((e) => e.toJson()).toList(),
      'max_words': maxWords,
      'think_time_seconds': thinkTimeSeconds,
      'max_record_seconds': maxRecordSeconds,
      // Persistimos usando la columna existente 'explicacion'
      'explicacion': explicacionGeneral,
    };
  }

  /// Verificar si es pregunta de selección múltiple
  bool get isMultipleChoice => tipoPregunta == 'multiple_choice';

  /// Tipos adicionales
  bool get isMatching => tipoPregunta == 'matching';
  bool get isCompletion => tipoPregunta == 'completion';
  bool get isRecordAudio => tipoPregunta == 'record_audio';
  bool get isWriteText => tipoPregunta == 'write_text';

  /// Verificar si tiene contenido multimedia
  bool get hasMultimedia =>
      audioUrl != null || videoUrl != null || imagenUrl != null;

  /// Verificar si tiene límite de tiempo
  bool get hasTimeLimit => tiempoLimiteSegundos != null;

  /// Crear copia del modelo con cambios
  QuestionModel copyWith({
    int? id,
    int? habilidadId,
    String? textoPregunta,
    String? tipoPregunta,
    String? audioUrl,
    String? videoUrl,
    String? imagenUrl,
    String? nivelDificultad,
    int? puntaje,
    int? tiempoLimiteSegundos,
    List<AnswerOptionModel>? opciones,
    String? explicacionGeneral,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      habilidadId: habilidadId ?? this.habilidadId,
      textoPregunta: textoPregunta ?? this.textoPregunta,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      nivelDificultad: nivelDificultad ?? this.nivelDificultad,
      puntaje: puntaje ?? this.puntaje,
      tiempoLimiteSegundos: tiempoLimiteSegundos ?? this.tiempoLimiteSegundos,
      opciones: opciones ?? this.opciones,
      explicacionGeneral: explicacionGeneral ?? this.explicacionGeneral,
    );
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, tipo: $tipoPregunta, dificultad: $nivelDificultad)';
  }
}

/// Answer Option Model - Representa una opción de respuesta para preguntas de selección múltiple
class AnswerOptionModel {
  final int id;
  final int preguntaId;
  final String textoOpcion;
  final bool esCorrecta;
  final String? explicacion;

  AnswerOptionModel({
    required this.id,
    required this.preguntaId,
    required this.textoOpcion,
    required this.esCorrecta,
    this.explicacion,
  });

  /// Crear AnswerOptionModel desde JSON
  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'] as int,
      preguntaId: json['pregunta_id'] as int,
      textoOpcion: json['texto_opcion'] as String,
      esCorrecta: json['es_correcta'] as bool,
      explicacion: json['explicacion'] as String?,
    );
  }

  /// Convertir AnswerOptionModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta_id': preguntaId,
      'texto_opcion': textoOpcion,
      'es_correcta': esCorrecta,
      'explicacion': explicacion,
    };
  }

  @override
  String toString() {
    return 'AnswerOptionModel(id: $id, correcta: $esCorrecta)';
  }
}
