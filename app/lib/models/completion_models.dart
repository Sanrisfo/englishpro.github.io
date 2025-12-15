/// Representa una oración con espacios en blanco (Completion) asociada a una pregunta.
///
/// Esta clase es utilizada para actividades donde el usuario debe completar
/// palabras o frases faltantes en una oración. Utiliza `textoTemplate` con
/// placeholders como `{{1}}`, `{{2}}` para indicar la posición de los `gaps`.
class CompletionSentence {
  /// El identificador único de la oración de completion.
  final int id;

  /// El ID de la pregunta a la que pertenece esta oración de completion.
  final int preguntaId;

  /// La plantilla de texto de la oración con placeholders para los espacios en blanco.
  /// Ej: "Mi nombre es {{1}} y tengo {{2}} años."
  final String textoTemplate;

  /// El orden de esta oración dentro de un conjunto de oraciones de completion.
  final int orden;

  /// Una lista de los espacios en blanco (gaps) que deben ser completados en la oración.
  final List<CompletionGap> gaps;

  /// Crea una instancia de [CompletionSentence].
  ///
  /// @param id El identificador único.
  /// @param preguntaId El ID de la pregunta asociada.
  /// @param textoTemplate La plantilla de texto con placeholders.
  /// @param orden El orden de visualización.
  /// @param gaps La lista de espacios en blanco.
  CompletionSentence({
    required this.id,
    required this.preguntaId,
    required this.textoTemplate,
    required this.orden,
    required this.gaps,
  });

  /// Crea un [CompletionSentence] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica acepta claves JSON alternativas para
  /// compatibilidad con diferentes formatos de datos.
  ///
  /// @param json Un mapa que contiene los datos de la oración de completion.
  /// @return Una nueva instancia de [CompletionSentence].
  factory CompletionSentence.fromJson(Map<String, dynamic> json) => CompletionSentence(
        id: json['id'] as int,
        preguntaId: (json['id_pregunta'] ?? json['pregunta_id']) as int,
        textoTemplate: (json['texto_template'] ?? json['texto'] ?? '') as String,
        orden: (json['orden'] as num?)?.toInt() ?? 1,
        gaps: (json['gaps'] as List?)
                ?.map((e) => CompletionGap.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  /// Convierte esta instancia de [CompletionSentence] en un mapa JSON.
  ///
  /// Este método serializa la oración de completion incluyendo sus gaps
  /// para su almacenamiento o transmisión.
  ///
  /// @return Una representación en mapa de la oración de completion.
  Map<String, dynamic> toJson() => {
        'id': id,
        'id_pregunta': preguntaId,
        'texto_template': textoTemplate,
        'orden': orden,
        'gaps': gaps.map((e) => e.toJson()).toList(),
      };
}

/// Representa un espacio en blanco (gap) de una oración de completion,
/// incluyendo el texto correcto que debe insertarse.
class CompletionGap {
  /// El identificador único del gap.
  final int id;

  /// El ID de la oración de completion a la que pertenece este gap.
  final int sentenceId;

  /// El índice del gap dentro de la oración (ej. 1 para `{{1}}`).
  final int gapIndex;

  /// El texto correcto que debe ir en este espacio en blanco.
  final String correctText;

  /// Crea una instancia de [CompletionGap].
  ///
  /// @param id El identificador único.
  /// @param sentenceId El ID de la oración asociada.
  /// @param gapIndex El índice del gap.
  /// @param correctText El texto correcto.
  CompletionGap({
    required this.id,
    required this.sentenceId,
    required this.gapIndex,
    required this.correctText,
  });

  /// Crea un [CompletionGap] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica acepta claves JSON alternativas para
  /// compatibilidad con diferentes formatos de datos.
  ///
  /// @param json Un mapa que contiene los datos del gap de completion.
  /// @return Una nueva instancia de [CompletionGap].
  factory CompletionGap.fromJson(Map<String, dynamic> json) => CompletionGap(
        id: json['id'] as int,
        sentenceId: (json['sentence_id'] ?? json['id_oracion']) as int,
        gapIndex: (json['gap_index'] ?? json['indice_gap']) as int,
        correctText: (json['correct_text'] ?? json['texto_correcto']) as String,
      );

  /// Convierte esta instancia de [CompletionGap] en un mapa JSON.
  ///
  /// Este método serializa el gap al formato estándar para su
  /// almacenamiento o transmisión.
  ///
  /// @return Una representación en mapa del gap de completion.
  Map<String, dynamic> toJson() => {
        'id': id,
        'sentence_id': sentenceId,
        'gap_index': gapIndex,
        'correct_text': correctText,
      };
}
