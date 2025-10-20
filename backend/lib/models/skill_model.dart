/// Skill Model - Backend
class Skill {
  final int? id;
  final int cursoId;
  final String nombre;
  final String descripcion;
  final String? iconUrl;
  final int orden;

  Skill({
    this.id,
    required this.cursoId,
    required this.nombre,
    required this.descripcion,
    this.iconUrl,
    required this.orden,
  });

  /// Create Skill from database row
  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as int?,
      cursoId: map['curso_id'] as int,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      iconUrl: map['icon_url'] as String?,
      orden: map['orden'] as int,
    );
  }

  /// Convert Skill to database map (for INSERT/UPDATE)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'curso_id': cursoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'icon_url': iconUrl,
      'orden': orden,
    };
  }

  /// Convert Skill to JSON for API response
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

  /// Create Skill from JSON request
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as int?,
      cursoId: json['curso_id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      iconUrl: json['icon_url'] as String?,
      orden: json['orden'] as int,
    );
  }
}
