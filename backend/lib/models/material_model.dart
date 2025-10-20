/// Material Model - Backend
/// Matches Materiales_Estudio table schema
class Material {
  final int? id;
  final int habilidadId;
  final String titulo;
  final String tipoMaterial; // 'PDF', 'Video', 'Audio', 'Texto', 'Imagen'
  final String? urlRecurso;
  final String? contenidoTexto;
  final int? duracionMinutos;
  final int orden;
  final String nivelAcceso; // 'Freemium', 'Basico', 'Pro', 'Premium'
  final DateTime? fechaCreacion;
  final int? creadoPor;

  Material({
    this.id,
    required this.habilidadId,
    required this.titulo,
    required this.tipoMaterial,
    this.urlRecurso,
    this.contenidoTexto,
    this.duracionMinutos,
    this.orden = 1,
    this.nivelAcceso = 'Freemium',
    this.fechaCreacion,
    this.creadoPor,
  });

  /// Create Material from database row
  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      id: map['id'] as int?,
      habilidadId: map['habilidad_id'] as int,
      titulo: map['titulo'] as String,
      tipoMaterial: map['tipo_material'] as String,
      urlRecurso: map['url_recurso'] as String?,
      contenidoTexto: map['contenido_texto'] as String?,
      duracionMinutos: map['duracion_minutos'] as int?,
      orden: map['orden'] as int? ?? 1,
      nivelAcceso: map['nivel_acceso'] as String? ?? 'Freemium',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
      creadoPor: map['creado_por'] as int?,
    );
  }

  /// Convert Material to database map (for INSERT/UPDATE)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habilidad_id': habilidadId,
      'titulo': titulo,
      'tipo_material': tipoMaterial,
      'url_recurso': urlRecurso,
      'contenido_texto': contenidoTexto,
      'duracion_minutos': duracionMinutos,
      'orden': orden,
      'nivel_acceso': nivelAcceso,
      if (fechaCreacion != null)
        'fecha_creacion': fechaCreacion!.toIso8601String(),
      if (creadoPor != null) 'creado_por': creadoPor,
    };
  }

  /// Convert Material to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habilidad_id': habilidadId,
      'titulo': titulo,
      'tipo_material': tipoMaterial,
      'url_recurso': urlRecurso,
      'contenido_texto': contenidoTexto,
      'duracion_minutos': duracionMinutos,
      'orden': orden,
      'nivel_acceso': nivelAcceso,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'creado_por': creadoPor,
    };
  }

  /// Create Material from JSON request
  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as int?,
      habilidadId: json['habilidad_id'] as int,
      titulo: json['titulo'] as String,
      tipoMaterial: json['tipo_material'] as String,
      urlRecurso: json['url_recurso'] as String?,
      contenidoTexto: json['contenido_texto'] as String?,
      duracionMinutos: json['duracion_minutos'] as int?,
      orden: json['orden'] as int? ?? 1,
      nivelAcceso: json['nivel_acceso'] as String? ?? 'Freemium',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      creadoPor: json['creado_por'] as int?,
    );
  }
}
