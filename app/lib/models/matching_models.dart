/// Respuesta posible en ejercicios de relación (Matching).
class MatchingAnswer {
  final int id;
  final int preguntaId;
  final String texto;
  final int orden;

  MatchingAnswer({
    required this.id,
    required this.preguntaId,
    required this.texto,
    required this.orden,
  });

  /// Construye a partir de JSON; acepta claves alternativas.
  factory MatchingAnswer.fromJson(Map<String, dynamic> json) => MatchingAnswer(
        id: json['id'] as int,
        preguntaId: (json['id_pregunta'] ?? json['pregunta_id']) as int,
        texto: json['texto'] as String,
        orden: (json['orden'] as num?)?.toInt() ?? 1,
      );

  /// Serializa la respuesta al formato estándar.
  Map<String, dynamic> toJson() => {
        'id': id,
        'id_pregunta': preguntaId,
        'texto': texto,
        'orden': orden,
      };
}

/// Enunciado a relacionar con una respuesta correcta.
class MatchingStatement {
  final int id;
  final int preguntaId;
  final String texto;
  final int orden;
  final int correctAnswerId;

  MatchingStatement({
    required this.id,
    required this.preguntaId,
    required this.texto,
    required this.orden,
    required this.correctAnswerId,
  });

  /// Construye a partir de JSON; acepta claves alternativas.
  factory MatchingStatement.fromJson(Map<String, dynamic> json) => MatchingStatement(
        id: json['id'] as int,
        preguntaId: (json['id_pregunta'] ?? json['pregunta_id']) as int,
        texto: json['texto'] as String,
        orden: (json['orden'] as num?)?.toInt() ?? 1,
        correctAnswerId: (json['correct_answer_id'] ?? json['id_respuesta_correcta']) as int,
      );

  /// Serializa el enunciado al formato estándar.
  Map<String, dynamic> toJson() => {
        'id': id,
        'id_pregunta': preguntaId,
        'texto': texto,
        'orden': orden,
        'correct_answer_id': correctAnswerId,
      };
}
