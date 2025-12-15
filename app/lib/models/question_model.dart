import 'matching_models.dart';
import 'completion_models.dart';

/// Representa una pregunta multimedia con distintos tipos y contenidos asociados.
///
/// Este modelo centraliza la definición de preguntas para diferentes tipos de actividades,
/// incluyendo selección múltiple, emparejamiento, completar, grabación de audio y texto.
class QuestionModel {
  /// El identificador único de la pregunta.
  final int id;

  /// El ID de la habilidad a la que pertenece esta pregunta.
  final int habilidadId;

  /// El texto principal de la pregunta.
  final String textoPregunta;

  /// El tipo de pregunta, que determina cómo se presenta y se responde.
  /// Valores posibles: 'multiple_choice', 'matching', 'completion', 'record_audio', 'write_text'.
  final String tipoPregunta;

  /// URL de un recurso de audio asociado a la pregunta (opcional).
  final String? audioUrl;

  /// URL de un recurso de video asociado a la pregunta (opcional).
  final String? videoUrl;

  /// URL de un recurso de imagen asociado a la pregunta (opcional).
  final String? imagenUrl;

  /// El nivel de dificultad de la pregunta.
  /// Valores posibles: 'easy', 'medium', 'hard'.
  final String nivelDificultad;

  /// El puntaje que se otorga al responder correctamente la pregunta.
  final int puntaje;

  /// El tiempo límite en segundos para responder la pregunta (opcional).
  final int? tiempoLimiteSegundos;

  /// Lista de opciones de respuesta para preguntas de tipo 'multiple_choice' (opcional).
  final List<AnswerOptionModel>? opciones;

  /// Lista de respuestas posibles para preguntas de tipo 'matching' (opcional).
  final List<MatchingAnswer>? matchingAnswers;

  /// Lista de enunciados para preguntas de tipo 'matching' (opcional).
  final List<MatchingStatement>? matchingStatements;

  /// Lista de oraciones con espacios en blanco para preguntas de tipo 'completion' (opcional).
  final List<CompletionSentence>? completionSentences;

  /// El número máximo de palabras permitidas para preguntas de tipo 'write_text' (opcional).
  final int? maxWords;

  /// Tiempo en segundos que se le da al usuario para pensar antes de grabar (solo 'record_audio').
  final int? thinkTimeSeconds;

  /// Tiempo máximo de grabación en segundos para 'record_audio'.
  final int? maxRecordSeconds;

  /// Explicación general o retroalimentación para la pregunta (opcional).
  final String? explicacionGeneral;

  /// Crea una instancia de [QuestionModel].
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

  /// Crea un [QuestionModel] a partir de un mapa JSON.
  ///
  /// @param json Un mapa que contiene los datos de la pregunta.
  /// @return Una nueva instancia de [QuestionModel].
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

  /// Convierte esta instancia de [QuestionModel] en un mapa JSON
  /// compatible con la API/base de datos.
  ///
  /// @return Una representación en mapa de la pregunta.
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

  /// Verifica si la pregunta es de tipo 'multiple_choice'.
  bool get isMultipleChoice => tipoPregunta == 'multiple_choice';

  /// Verifica si la pregunta es de tipo 'matching'.
  bool get isMatching => tipoPregunta == 'matching';

  /// Verifica si la pregunta es de tipo 'completion'.
  bool get isCompletion => tipoPregunta == 'completion';

  /// Verifica si la pregunta es de tipo 'record_audio'.
  bool get isRecordAudio => tipoPregunta == 'record_audio';

  /// Verifica si la pregunta es de tipo 'write_text'.
  bool get isWriteText => tipoPregunta == 'write_text';

  /// Verifica si la pregunta tiene algún contenido multimedia (audio, video o imagen).
  bool get hasMultimedia =>
      audioUrl != null || videoUrl != null || imagenUrl != null;

  /// Verifica si la pregunta tiene un tiempo límite establecido.
  bool get hasTimeLimit => tiempoLimiteSegundos != null;

  /// Crea una copia de este [QuestionModel] con los valores especificados
  /// reemplazando los valores actuales.
  ///
  /// @param id Nuevo ID de la pregunta.
  /// @param habilidadId Nuevo ID de la habilidad.
  /// @param textoPregunta Nuevo texto de la pregunta.
  /// @param tipoPregunta Nuevo tipo de pregunta.
  /// @param audioUrl Nueva URL de audio.
  /// @param videoUrl Nueva URL de video.
  /// @param imagenUrl Nueva URL de imagen.
  /// @param nivelDificultad Nuevo nivel de dificultad.
  /// @param puntaje Nuevo puntaje.
  /// @param tiempoLimiteSegundos Nuevo tiempo límite en segundos.
  /// @param opciones Nuevas opciones de respuesta.
  /// @param explicacionGeneral Nueva explicación general.
  /// @return Una nueva instancia de [QuestionModel] con los valores actualizados.
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
  /// Devuelve una representación en cadena de este [QuestionModel].
  String toString() {
    return 'QuestionModel(id: $id, tipo: $tipoPregunta, dificultad: $nivelDificultad)';
  }
}

/// Representa una opción de respuesta para preguntas de selección múltiple.
class AnswerOptionModel {
  /// El identificador único de la opción de respuesta.
  final int id;

  /// El ID de la pregunta a la que pertenece esta opción.
  final int preguntaId;

  /// El texto de la opción de respuesta.
  final String textoOpcion;

  /// Indica si esta opción es la respuesta correcta.
  final bool esCorrecta;

  /// Una explicación opcional sobre por qué esta opción es correcta o incorrecta.
  final String? explicacion;

  /// Crea una instancia de [AnswerOptionModel].
  ///
  /// @param id El identificador único.
  /// @param preguntaId El ID de la pregunta asociada.
  /// @param textoOpcion El texto de la opción.
  /// @param esCorrecta Indica si es la opción correcta.
  /// @param explicacion Una explicación opcional.
  AnswerOptionModel({
    required this.id,
    required this.preguntaId,
    required this.textoOpcion,
    required this.esCorrecta,
    this.explicacion,
  });

  /// Crea un [AnswerOptionModel] a partir de un mapa JSON.
  ///
  /// @param json Un mapa que contiene los datos de la opción de respuesta.
  /// @return Una nueva instancia de [AnswerOptionModel].
  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'] as int,
      preguntaId: json['pregunta_id'] as int,
      textoOpcion: json['texto_opcion'] as String,
      esCorrecta: json['es_correcta'] as bool,
      explicacion: json['explicacion'] as String?,
    );
  }

  /// Convierte esta instancia de [AnswerOptionModel] en un mapa JSON.
  ///
  /// @return Una representación en mapa de la opción de respuesta.
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
  /// Devuelve una representación en cadena de este [AnswerOptionModel].
  String toString() {
    return 'AnswerOptionModel(id: $id, correcta: $esCorrecta)';
  }
}

