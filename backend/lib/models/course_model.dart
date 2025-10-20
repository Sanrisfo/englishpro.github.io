/// Course Model - Backend
/// Matches Cursos table schema
class Course {
  final int? id;
  final String nombre;
  final String? descripcion;
  final String tipoCurso; // 'Examen' o 'Inmersivo'
  final String estiloProgreso; // 'Porcentaje' o 'Modular'
  final String? urlImagen;
  final DateTime? fechaCreacion;
  final bool activo;

  Course({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoCurso,
    required this.estiloProgreso,
    this.urlImagen,
    this.fechaCreacion,
    this.activo = true,
  });

  /// Create Course from database row
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      tipoCurso: map['tipo_curso'] as String,
      estiloProgreso: map['estilo_progreso'] as String,
      urlImagen: map['url_imagen'] as String?,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
      activo: map['activo'] as bool? ?? true,
    );
  }

  /// Convert Course to database map (for INSERT/UPDATE)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo_curso': tipoCurso,
      'estilo_progreso': estiloProgreso,
      'url_imagen': urlImagen,
      if (fechaCreacion != null)
        'fecha_creacion': fechaCreacion!.toIso8601String(),
      'activo': activo,
    };
  }

  /// Convert Course to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo_curso': tipoCurso,
      'estilo_progreso': estiloProgreso,
      'url_imagen': urlImagen,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'activo': activo,
    };
  }

  /// Create Course from JSON request
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      tipoCurso: json['tipo_curso'] as String,
      estiloProgreso: json['estilo_progreso'] as String,
      urlImagen: json['url_imagen'] as String?,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      activo: json['activo'] as bool? ?? true,
    );
  }
}
