/// Representa un plan de suscripción de la aplicación EnglishPro.
///
/// Define las características y límites asociados a cada tipo de plan,
/// como 'Freemium', 'Básico', 'Pro' o 'Premium'.
class PlanModel {
  /// El identificador único del plan.
  final int id;

  /// El nombre del plan (ej. 'Freemium', 'Básico', 'Pro', 'Premium').
  final String nombre;

  /// Una descripción detallada del plan.
  final String descripcion;

  /// El precio mensual del plan.
  final double precio;

  /// El límite de preguntas que el usuario puede responder por tipo de actividad.
  final int limitePreguntasPorTipo;

  /// Indica si el plan incluye retroalimentación manual por parte de un docente.
  final bool tieneRetroalimentacionManual;

  /// El número de sesiones en vivo incluidas en el plan, si aplica.
  final int? sesionesEnVivo;

  /// El número de simulacros completos de examen incluidos en el plan, si aplica.
  final int? simulacrosCompletos;

  /// Indica si el plan otorga acceso completo a todos los cursos.
  final bool accesoCompletoCursos;

  /// Crea una instancia de [PlanModel].
  ///
  /// @param id El identificador único.
  /// @param nombre El nombre del plan.
  /// @param descripcion La descripción del plan.
  /// @param precio El precio del plan.
  /// @param limitePreguntasPorTipo El límite de preguntas por tipo de actividad.
  /// @param tieneRetroalimentacionManual Indica si tiene retroalimentación manual.
  /// @param sesionesEnVivo El número de sesiones en vivo.
  /// @param simulacrosCompletos El número de simulacros.
  /// @param accesoCompletoCursos Indica si tiene acceso completo a cursos.
  PlanModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.limitePreguntasPorTipo,
    required this.tieneRetroalimentacionManual,
    this.sesionesEnVivo,
    this.simulacrosCompletos,
    required this.accesoCompletoCursos,
  });

  /// Crea un [PlanModel] a partir de un mapa JSON.
  ///
  /// @param json Un mapa que contiene los datos del plan.
  /// @return Una nueva instancia de [PlanModel].
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      limitePreguntasPorTipo: json['limite_preguntas_por_tipo'] as int,
      tieneRetroalimentacionManual:
          json['tiene_retroalimentacion_manual'] as bool,
      sesionesEnVivo: json['sesiones_en_vivo'] as int?,
      simulacrosCompletos: json['simulacros_completos'] as int?,
      accesoCompletoCursos: json['acceso_completo_cursos'] as bool,
    );
  }

  /// Convierte esta instancia de [PlanModel] en un mapa JSON.
  ///
  /// @return Una representación en mapa del plan.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'limite_preguntas_por_tipo': limitePreguntasPorTipo,
      'tiene_retroalimentacion_manual': tieneRetroalimentacionManual,
      'sesiones_en_vivo': sesionesEnVivo,
      'simulacros_completos': simulacrosCompletos,
      'acceso_completo_cursos': accesoCompletoCursos,
    };
  }

  /// Verifica si el plan es el plan "Freemium".
  ///
  /// @return `true` si el nombre del plan (ignorando mayúsculas/minúsculas) es 'freemium', `false` en caso contrario.
  bool get isFreemium => nombre.toLowerCase() == 'freemium';

  /// Verifica si el plan es el plan "Premium".
  ///
  /// @return `true` si el nombre del plan (ignorando mayúsculas/minúsculas) es 'premium', `false` en caso contrario.
  bool get isPremium => nombre.toLowerCase() == 'premium';

  /// Crea una copia de este [PlanModel] con los valores especificados
  /// reemplazando los valores actuales.
  ///
  /// @param id Nuevo ID del plan.
  /// @param nombre Nuevo nombre del plan.
  /// @param descripcion Nueva descripción.
  /// @param precio Nuevo precio.
  /// @param limitePreguntasPorTipo Nuevo límite de preguntas por tipo.
  /// @param tieneRetroalimentacionManual Nueva bandera de retroalimentación manual.
  /// @param sesionesEnVivo Nuevo número de sesiones en vivo.
  /// @param simulacrosCompletos Nuevo número de simulacros completos.
  /// @param accesoCompletoCursos Nueva bandera de acceso completo a cursos.
  /// @return Una nueva instancia de [PlanModel] con los valores actualizados.
  PlanModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    int? limitePreguntasPorTipo,
    bool? tieneRetroalimentacionManual,
    int? sesionesEnVivo,
    int? simulacrosCompletos,
    bool? accesoCompletoCursos,
  }) {
    return PlanModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      limitePreguntasPorTipo:
          limitePreguntasPorTipo ?? this.limitePreguntasPorTipo,
      tieneRetroalimentacionManual:
          tieneRetroalimentacionManual ?? this.tieneRetroalimentacionManual,
      sesionesEnVivo: sesionesEnVivo ?? this.sesionesEnVivo,
      simulacrosCompletos: simulacrosCompletos ?? this.simulacrosCompletos,
      accesoCompletoCursos: accesoCompletoCursos ?? this.accesoCompletoCursos,
    );
  }

  @override
  /// Devuelve una representación en cadena de este [PlanModel].
  String toString() {
    return 'PlanModel(id: $id, nombre: $nombre, precio: \$$precio, limite: $limitePreguntasPorTipo)';
  }

  @override
  /// Compara si este [PlanModel] es igual a otro objeto.
  ///
  /// @param other El otro objeto a comparar.
  /// @return `true` si los objetos son idénticos o tienen los mismos valores en todas sus propiedades, `false` en caso contrario.
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlanModel &&
        other.id == id &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.precio == precio &&
        other.limitePreguntasPorTipo == limitePreguntasPorTipo &&
        other.tieneRetroalimentacionManual == tieneRetroalimentacionManual &&
        other.sesionesEnVivo == sesionesEnVivo &&
        other.simulacrosCompletos == simulacrosCompletos &&
        other.accesoCompletoCursos == accesoCompletoCursos;
  }

  @override
  /// Devuelve el código hash para este [PlanModel].
  ///
  /// @return Un entero que representa el código hash.
  int get hashCode {
    return id.hashCode ^
        nombre.hashCode ^
        descripcion.hashCode ^
        precio.hashCode ^
        limitePreguntasPorTipo.hashCode ^
        tieneRetroalimentacionManual.hashCode ^
        sesionesEnVivo.hashCode ^
        simulacrosCompletos.hashCode ^
        accesoCompletoCursos.hashCode;
  }
}

