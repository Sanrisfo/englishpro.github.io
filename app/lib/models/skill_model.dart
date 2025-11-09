/// Skill Model - Representa una habilidad (Reading, Writing, Listening, Speaking)
class SkillModel {
  final int id;
  final int cursoId;
  final String nombre; // Reading, Writing, Listening, Speaking
  final String descripcion;
  final String? iconUrl;
  final int orden;

  SkillModel({
    required this.id,
    required this.cursoId,
    required this.nombre,
    required this.descripcion,
    this.iconUrl,
    required this.orden,
  });

  /// Crear SkillModel desde JSON
  factory SkillModel.fromJson(Map<String, dynamic> json) {
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
      nombre: (json['nombre'] ?? json['nombre_habilidad'] ?? json['Nombre_Habilidad'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? json['Descripcion'] ?? '').toString(),
      iconUrl: (json['icon_url'] ?? json['Icon_Url']) as String?,
      orden: toInt(json['orden'] ?? json['Orden'], defaultValue: 1),
    );
  }

  /// Convertir SkillModel a JSON
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

  /// Verificar si es Reading
  bool get isReading => nombre.toLowerCase() == 'reading';

  /// Verificar si es Writing
  bool get isWriting => nombre.toLowerCase() == 'writing';

  /// Verificar si es Listening
  bool get isListening => nombre.toLowerCase() == 'listening';

  /// Verificar si es Speaking
  bool get isSpeaking => nombre.toLowerCase() == 'speaking';

  /// Verificar si requiere retroalimentación manual (Writing o Speaking)
  bool get requiresManualFeedback => isWriting || isSpeaking;

  /// Crear copia del modelo con cambios
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
  String toString() {
    return 'SkillModel(id: $id, nombre: $nombre, cursoId: $cursoId)';
  }

  @override
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
  int get hashCode {
    return id.hashCode ^
        cursoId.hashCode ^
        nombre.hashCode ^
        descripcion.hashCode ^
        iconUrl.hashCode ^
        orden.hashCode;
  }
}
