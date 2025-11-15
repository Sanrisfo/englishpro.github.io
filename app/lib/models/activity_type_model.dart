class ActivityTypeModel {
  final int id;
  final int habilidadId;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool activo;

  ActivityTypeModel({
    required this.id,
    required this.habilidadId,
    required this.nombre,
    this.descripcion,
    this.orden = 1,
    this.activo = true,
  });

  factory ActivityTypeModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int d = 0}) {
      if (v == null) return d;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? d;
      return d;
    }

    return ActivityTypeModel(
      id: toInt(json['id'] ?? json['id_tipo_actividad']),
      habilidadId: toInt(json['id_habilidad'] ?? json['habilidad_id'] ?? json['ID_Habilidad']),
      nombre: (json['nombre'] ?? json['nombre_tipo'] ?? '').toString(),
      descripcion: (json['descripcion'] as String?) ?? (json['Descripcion'] as String?),
      orden: toInt(json['orden'] ?? 1, d: 1),
      activo: (json['activo'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_habilidad': habilidadId,
        'nombre': nombre,
        'descripcion': descripcion,
        'orden': orden,
        'activo': activo,
      };
}

