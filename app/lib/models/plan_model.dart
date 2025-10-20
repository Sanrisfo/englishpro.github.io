/// Plan Model - Representa un plan de suscripción
class PlanModel {
  final int id;
  final String nombre; // Freemium, Básico, Pro, Premium
  final String descripcion;
  final double precio;
  final int limitePreguntasPorTipo;
  final bool tieneRetroalimentacionManual;
  final int? sesionesEnVivo;
  final int? simulacrosCompletos;
  final bool accesoCompletoCursos;

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

  /// Crear PlanModel desde JSON
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

  /// Convertir PlanModel a JSON
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

  /// Verificar si es plan gratuito
  bool get isFreemium => nombre.toLowerCase() == 'freemium';

  /// Verificar si es plan premium
  bool get isPremium => nombre.toLowerCase() == 'premium';

  /// Crear copia del modelo con cambios
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
  String toString() {
    return 'PlanModel(id: $id, nombre: $nombre, precio: \$$precio, limite: $limitePreguntasPorTipo)';
  }

  @override
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
