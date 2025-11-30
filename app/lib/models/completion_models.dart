/// Oración con espacios en blanco (Completion) asociada a una pregunta.
class CompletionSentence {
  final int id;
  final int preguntaId;
  final String textoTemplate; // usar placeholders {{1}}, {{2}} para gaps
  final int orden;
  final List<CompletionGap> gaps;

  CompletionSentence({
    required this.id,
    required this.preguntaId,
    required this.textoTemplate,
    required this.orden,
    required this.gaps,
  });

  /// Construye a partir de JSON; acepta claves alternativas para compatibilidad.
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

  /// Serializa la oración de completion incluyendo sus gaps.
  Map<String, dynamic> toJson() => {
        'id': id,
        'id_pregunta': preguntaId,
        'texto_template': textoTemplate,
        'orden': orden,
        'gaps': gaps.map((e) => e.toJson()).toList(),
      };
}

/// Gap de una oración de completion con el texto correcto.
class CompletionGap {
  final int id;
  final int sentenceId;
  final int gapIndex;
  final String correctText;

  CompletionGap({
    required this.id,
    required this.sentenceId,
    required this.gapIndex,
    required this.correctText,
  });

  /// Construye a partir de JSON con claves alternativas.
  factory CompletionGap.fromJson(Map<String, dynamic> json) => CompletionGap(
        id: json['id'] as int,
        sentenceId: (json['sentence_id'] ?? json['id_oracion']) as int,
        gapIndex: (json['gap_index'] ?? json['indice_gap']) as int,
        correctText: (json['correct_text'] ?? json['texto_correcto']) as String,
      );

  /// Serializa el gap al formato estándar.
  Map<String, dynamic> toJson() => {
        'id': id,
        'sentence_id': sentenceId,
        'gap_index': gapIndex,
        'correct_text': correctText,
      };
}
