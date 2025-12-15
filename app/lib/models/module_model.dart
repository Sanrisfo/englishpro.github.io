/// Representa un módulo de contenido perteneciente a una habilidad.
///
/// Los módulos organizan el contenido educativo dentro de una habilidad,
/// como lecciones, secciones o unidades temáticas.
class ModuleModel {
  /// El identificador único del módulo.
  final int id;

  /// El ID de la habilidad a la que pertenece este módulo.
  final int habilidadId;

  /// El nombre del módulo (ej. "Introducción a los verbos", "Vocabulario de Viaje").
  final String nombre;

  /// Una descripción opcional del contenido del módulo.
  final String? descripcion;

  /// El orden de visualización de este módulo dentro de una habilidad.
  final int orden;

  /// Indica si el módulo está activo y disponible para los usuarios.
  final bool activo;

  /// La fecha en que el módulo fue creado.
  final DateTime fechaCreacion;

  /// Crea una instancia de [ModuleModel].
  ///
  /// @param id El identificador único.
  /// @param habilidadId El ID de la habilidad asociada.
  /// @param nombre El nombre del módulo.
  /// @param descripcion Una descripción opcional.
  /// @param orden El orden de visualización.
  /// @param activo Indica si está activo.
  /// @param fechaCreacion La fecha de creación.
  ModuleModel({
    required this.id,
    required this.habilidadId,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.activo,
    required this.fechaCreacion,
  });

  /// Construye un [ModuleModel] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica maneja variaciones en las claves JSON
  /// (ej., `id_modulo`, `id`, `ID_Modulo`) para proporcionar un análisis robusto
  /// de diferentes fuentes de datos. Incluye funciones de utilidad
  /// `toInt`, `toBool` y `toDate` para la conversión segura de tipos.
  ///
  /// @param json Un mapa que contiene los datos del módulo.
  /// @return Una nueva instancia de [ModuleModel].
  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    /// Convierte de forma segura un valor dinámico a un entero.
    ///
    /// @param v El valor a convertir.
    /// @param def El valor por defecto a retornar si la conversión falla.
    /// @return El valor convertido a entero o el valor por defecto.
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? def;
      return def;
    }

    /// Convierte de forma segura un valor dinámico a un booleano.
    ///
    /// @param v El valor a convertir.
    /// @return El valor convertido a booleano.
    bool toBool(dynamic v) {
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }

    /// Convierte de forma segura un valor dinámico a un DateTime.
    ///
    /// @param v El valor a convertir.
    /// @return El valor convertido a DateTime o la fecha y hora actual si falla.
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
