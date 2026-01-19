/// Representa una habilidad (ej. Reading, Writing, Listening, Speaking) dentro de un curso.
///
/// Cada curso se desglosa en varias habilidades, y este modelo define
/// las características de cada una.
class SkillModel {
  /// El identificador único de la habilidad.
  final int id;

  /// El ID del curso al que pertenece esta habilidad.
  final int cursoId;

  /// El nombre de la habilidad (ej. 'Reading', 'Writing', 'Listening', 'Speaking').
  final String nombre;

  /// Una descripción de la habilidad.
  final String descripcion;

  /// La URL del icono asociado a la habilidad (opcional).
  final String? iconUrl;

  /// El orden de visualización de la habilidad dentro de su curso.
  final int orden;

  /// Crea una instancia de [SkillModel].
  ///
  /// @param id El identificador único.
  /// @param cursoId El ID del curso asociado.
  /// @param nombre El nombre de la habilidad.
  /// @param descripcion La descripción de la habilidad.
  /// @param iconUrl La URL del icono (opcional).
  /// @param orden El orden de visualización.
  SkillModel({
    required this.id,
    required this.cursoId,
    required this.nombre,
    required this.descripcion,
    this.iconUrl,
    required this.orden,
  });

  /// Crea un [SkillModel] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica maneja variaciones en las claves JSON
  /// para proporcionar un análisis robusto de diferentes fuentes de datos.
  ///
  /// @param json Un mapa que contiene los datos de la habilidad.
  /// @return Una nueva instancia de [SkillModel].
  factory SkillModel.fromJson(Map<String, dynamic> json) {
    /// Convierte de forma segura un valor dinámico a un entero.
    ///
    /// @param v El valor a convertir.
    /// @param defaultValue El valor por defecto a retornar si la conversión falla.
    /// @return El valor convertido a entero o el valor por defecto.
    int toInt(dynamic v, {int defaultValue = 0}) {
      if (v == null) return defaultValue;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? defaultValue;
      return defaultValue;
    }

    return SkillModel(
      id: toInt(json['id'] ?? json['id_habilidad'] ?? json['ID_Habilidad']),
      cursoId: toInt(json['curso_id'] ?? json['ID_Curso']),
      nombre:
          (json['nombre'] ??
                  json['nombre_habilidad'] ??
                  json['Nombre_Habilidad'] ??
                  '')
              .toString(),
      descripcion: (json['descripcion'] ?? json['Descripcion'] ?? '')
          .toString(),
      iconUrl: (json['icon_url'] ?? json['Icon_Url']) as String?,
      orden: toInt(json['orden'] ?? json['Orden'], defaultValue: 1),
    );
  }

  /// Convierte esta instancia de [SkillModel] en un mapa JSON.
  ///
  /// @return Una representación en mapa de la habilidad.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'curso_id': cursoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'icon_url': iconUrl,
      'orden': orden,
    };
  }

  /// Verifica si la habilidad es 'Reading'.
  bool get isReading => nombre.toLowerCase() == 'reading';

  /// Verifica si la habilidad es 'Writing'.
  bool get isWriting => nombre.toLowerCase() == 'writing';

  /// Verifica si la habilidad es 'Listening'.
  bool get isListening => nombre.toLowerCase() == 'listening';

  /// Verifica si la habilidad es 'Speaking'.
  bool get isSpeaking => nombre.toLowerCase() == 'speaking';

  /// Verifica si la habilidad requiere retroalimentación manual (Writing o Speaking).
  bool get requiresManualFeedback => isWriting || isSpeaking;

  /// Crea una copia de este [SkillModel] con los valores especificados
  /// reemplazando los valores actuales.
  ///
  /// @param id Nuevo ID de la habilidad.
  /// @param cursoId Nuevo ID del curso asociado.
  /// @param nombre Nuevo nombre de la habilidad.
  /// @param descripcion Nueva descripción.
  /// @param iconUrl Nueva URL del icono.
  /// @param orden Nuevo orden de visualización.
  /// @return Una nueva instancia de [SkillModel] con los valores actualizados.
  SkillModel copyWith({
    int? id,
    int? cursoId,
    String? nombre,
    String? descripcion,
    String? iconUrl,
    int? orden,
  }) {
    return SkillModel(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      iconUrl: iconUrl ?? this.iconUrl,
      orden: orden ?? this.orden,
    );
  }

  @override
  /// Devuelve una representación en cadena de este [SkillModel].
  String toString() {
    return 'SkillModel(id: $id, nombre: $nombre, cursoId: $cursoId)';
  }

  @override
  /// Compara si este [SkillModel] es igual a otro objeto.
  ///
  /// @param other El otro objeto a comparar.
  /// @return `true` si los objetos son idénticos o tienen los mismos valores en todas sus propiedades, `false` en caso contrario.
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SkillModel &&
        other.id == id &&
        other.cursoId == cursoId &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.iconUrl == iconUrl &&
        other.orden == orden;
  }

  @override
  /// Devuelve el código hash para este [SkillModel].
  ///
  /// @return Un entero que representa el código hash.
  int get hashCode {
    return id.hashCode ^
        cursoId.hashCode ^
        nombre.hashCode ^
        descripcion.hashCode ^
        iconUrl.hashCode ^
        orden.hashCode;
  }
}
