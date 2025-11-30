/// Módulo de contenido perteneciente a una habilidad.
class ModuleModel {
  final int id;
  final int habilidadId;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool activo;
  final DateTime fechaCreacion;

  ModuleModel({
    required this.id,
    required this.habilidadId,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.activo,
    required this.fechaCreacion,
  });

  /// Construye el módulo a partir de JSON con claves alternativas.
  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? def;
      return def;
    }

    bool toBool(dynamic v) {
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }

    DateTime toDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return ModuleModel(
      id: toInt(json['id_modulo'] ?? json['id'] ?? json['ID_Modulo']),
      habilidadId: toInt(json['id_habilidad'] ?? json['habilidad_id'] ?? json['ID_Habilidad']),
      nombre: (json['nombre_modulo'] ?? json['nombre'] ?? json['Nombre_Modulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? json['Descripcion']) as String?,
      orden: toInt(json['orden'] ?? json['Orden'], def: 1),
      activo: toBool(json['activo'] ?? json['Activo'] ?? true),
      fechaCreacion: toDate(json['fecha_creacion'] ?? json['Fecha_Creacion']),
    );
  }
}
