/// Representa un tipo de actividad específico asociado a una habilidad.
///
/// Este modelo corresponde a la tabla `tipos_actividad` en la base de datos
/// y define diferentes categorías de tareas que un usuario puede realizar
/// dentro de una habilidad, como 'Opción Múltiple', 'Completar Espacios'
/// o 'Práctica de Pronunciación'.
class ActivityTypeModel {
  /// El identificador único para el tipo de actividad.
  /// Corresponde a la columna `id` en la base de datos.
  final int id;

  /// La clave foránea que vincula este tipo de actividad a una [SkillModel] específica.
  /// Corresponde a la columna `id_habilidad`.
  final int habilidadId;

  /// El nombre del tipo de actividad (ej. "Quiz", "Emparejamiento").
  /// Corresponde a la columna `nombre`.
  final String nombre;

  /// Una descripción opcional detallada del tipo de actividad.
  /// Corresponde a la columna `descripcion`.
  final String? descripcion;

  /// El orden de visualización de este tipo de actividad dentro de una lista.
  /// Corresponde a la columna `orden`.
  final int orden;

  /// Indica si este tipo de actividad está activo y disponible para los usuarios.
  /// Corresponde a la columna `activo`.
  final bool activo;

  /// Crea una instancia de [ActivityTypeModel].
  ///
  /// Todos los parámetros son requeridos excepto [descripcion], [orden] y [activo],
  /// los cuales tienen valores por defecto.
  ActivityTypeModel({
    required this.id,
    required this.habilidadId,
    required this.nombre,
    this.descripcion,
    this.orden = 1,
    this.activo = true,
  });

  /// Crea un [ActivityTypeModel] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica maneja variaciones en las claves JSON
  /// (ej. `id` vs. `id_tipo_actividad`) para proporcionar un análisis robusto
  /// de diferentes fuentes de datos. También incluye una función de utilidad
  /// `toInt` para la conversión segura de tipos.
  ///
  /// @param json Un mapa que contiene los datos del tipo de actividad.
  /// @return Una nueva instancia de [ActivityTypeModel].
  factory ActivityTypeModel.fromJson(Map<String, dynamic> json) {
    /// Convierte de forma segura un valor dinámico a un entero.
    ///
    /// @param v El valor a convertir.
    /// @param d El valor por defecto a retornar si la conversión falla.
    /// @return El valor convertido a entero o el valor por defecto.
    int toInt(dynamic v, {int d = 0}) {
      if (v == null) return d;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? d;
      return d;
    }

    return ActivityTypeModel(
      id: toInt(json['id'] ?? json['id_tipo_actividad']),
      habilidadId: toInt(
        json['id_habilidad'] ?? json['habilidad_id'] ?? json['ID_Habilidad'],
      ),
      nombre: (json['nombre'] ?? json['nombre_tipo'] ?? '').toString(),
      descripcion:
          (json['descripcion'] as String?) ?? (json['Descripcion'] as String?),
      orden: toInt(json['orden'] ?? 1, d: 1),
      activo: (json['activo'] as bool?) ?? true,
    );
  }

  /// Convierte esta instancia de [ActivityTypeModel] en un mapa JSON.
  ///
  /// Este método serializa el modelo a un formato que es consistente
  /// con el esquema de la base de datos y puede ser utilizado fácilmente
  /// para solicitudes de API.
  ///
  /// @return Una representación en mapa del tipo de actividad.
  Map<String, dynamic> toJson() => {
    'id': id,
    'id_habilidad': habilidadId,
    'nombre': nombre,
    'descripcion': descripcion,
    'orden': orden,
    'activo': activo,
  };
}
