/// Representa una posible respuesta en ejercicios de relación (Matching).
///
/// Cada [MatchingAnswer] es un elemento que el usuario debe emparejar
/// con un [MatchingStatement] correcto.
class MatchingAnswer {
  /// El identificador único de la respuesta.
  final int id;

  /// El ID de la pregunta de tipo "Matching" a la que pertenece esta respuesta.
  final int preguntaId;

  /// El texto de la respuesta que se mostrará al usuario.
  final String texto;

  /// El orden de visualización de la respuesta dentro de la lista de opciones.
  final int orden;

  /// Crea una instancia de [MatchingAnswer].
  ///
  /// @param id El identificador único.
  /// @param preguntaId El ID de la pregunta asociada.
  /// @param texto El texto de la respuesta.
  /// @param orden El orden de visualización.
  MatchingAnswer({
    required this.id,
    required this.preguntaId,
    required this.texto,
    required this.orden,
  });

  /// Crea un [MatchingAnswer] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica acepta claves JSON alternativas para
  /// compatibilidad con diferentes formatos de datos.
  ///
  /// @param json Un mapa que contiene los datos de la respuesta.
  /// @return Una nueva instancia de [MatchingAnswer].
  factory MatchingAnswer.fromJson(Map<String, dynamic> json) => MatchingAnswer(
        id: json['id'] as int,
        preguntaId: (json['id_pregunta'] ?? json['pregunta_id']) as int,
        texto: json['texto'] as String,
        orden: (json['orden'] as num?)?.toInt() ?? 1,
      );

  /// Convierte esta instancia de [MatchingAnswer] en un mapa JSON.
  ///
  /// Este método serializa la respuesta al formato estándar para su
  /// almacenamiento o transmisión.
  ///
  /// @return Una representación en mapa de la respuesta.
  Map<String, dynamic> toJson() => {
        'id': id,
        'id_pregunta': preguntaId,
        'texto': texto,
        'orden': orden,
      };
}

/// Representa un enunciado que el usuario debe relacionar con una respuesta correcta
/// en ejercicios de tipo "Matching".
class MatchingStatement {
  /// El identificador único del enunciado.
  final int id;

  /// El ID de la pregunta de tipo "Matching" a la que pertenece este enunciado.
  final int preguntaId;

  /// El texto del enunciado que se mostrará al usuario.
  final String texto;

  /// El orden de visualización del enunciado dentro de la lista de enunciados.
  final int orden;

  /// El ID de la [MatchingAnswer] correcta para este enunciado.
  final int correctAnswerId;

  /// Crea una instancia de [MatchingStatement].
  ///
  /// @param id El identificador único.
  /// @param preguntaId El ID de la pregunta asociada.
  /// @param texto El texto del enunciado.
  /// @param orden El orden de visualización.
  /// @param correctAnswerId El ID de la respuesta correcta.
  MatchingStatement({
    required this.id,
    required this.preguntaId,
    required this.texto,
    required this.orden,
    required this.correctAnswerId,
  });

  /// Crea un [MatchingStatement] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica acepta claves JSON alternativas para
  /// compatibilidad con diferentes formatos de datos.
  ///
  /// @param json Un mapa que contiene los datos del enunciado.
  /// @return Una nueva instancia de [MatchingStatement].
  factory MatchingStatement.fromJson(Map<String, dynamic> json) => MatchingStatement(
        id: json['id'] as int,
        preguntaId: (json['id_pregunta'] ?? json['pregunta_id']) as int,
        texto: json['texto'] as String,
        orden: (json['orden'] as num?)?.toInt() ?? 1,
        correctAnswerId: (json['correct_answer_id'] ?? json['id_respuesta_correcta']) as int,
      );

  /// Convierte esta instancia de [MatchingStatement] en un mapa JSON.
  ///
  /// Este método serializa el enunciado al formato estándar para su
  /// almacenamiento o transmisión.
  ///
  /// @return Una representación en mapa del enunciado.
  Map<String, dynamic> toJson() => {
        'id': id,
        'id_pregunta': preguntaId,
        'texto': texto,
        'orden': orden,
        'correct_answer_id': correctAnswerId,
      };
}
