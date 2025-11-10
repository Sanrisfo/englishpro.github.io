/// Course Model - Representa un curso (TOEFL, IELTS, Business English, English in Action)
class CourseModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String tipoCurso; // 'Examen' o 'Inmersivo'
  final String estiloProgreso; // 'Porcentaje' o 'Modular'
  final String? urlImagen;
  final DateTime? fechaCreacion;
  final bool activo;

  CourseModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipoCurso,
    required this.estiloProgreso,
    this.urlImagen,
    this.fechaCreacion,
    this.activo = true,
  });

  /// Crear CourseModel desde JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      tipoCurso: json['tipo_curso'] as String,
      estiloProgreso: json['estilo_progreso'] as String,
      urlImagen: json['url_imagen'] as String?,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      activo: json['activo'] as bool? ?? true,
    );
  }

  /// Convertir CourseModel a JSON
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

  /// Verificar si el curso mide progreso por porcentaje
  bool get isPercentageBased => estiloProgreso == 'Porcentaje';

  /// Verificar si el curso mide progreso por módulos
  bool get isModuleBased => estiloProgreso == 'Modular';

  /// Verificar si es curso de examen (TOEFL/IELTS)
  bool get isExamCourse => tipoCurso == 'Examen';

  /// Verificar si es curso inmersivo (Business/Action)
  bool get isImmersiveCourse => tipoCurso == 'Inmersivo';

  /// Obtener color basado en el nombre del curso
  String get colorHex {
    switch (nombre.toUpperCase()) {
      case 'TOEFL':
        return '#2563EB'; // Blue
      case 'IELTS':
        return '#10B981'; // Green
      case 'BUSINESS ENGLISH':
        return '#F59E0B'; // Orange
      case 'ENGLISH IN ACTION':
        return '#8B5CF6'; // Purple
      default:
        return '#6B7280'; // Gray
    }
  }

  /// Crear copia del modelo con cambios
  CourseModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? tipoCurso,
    String? estiloProgreso,
    String? urlImagen,
    DateTime? fechaCreacion,
    bool? activo,
  }) {
    return CourseModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipoCurso: tipoCurso ?? this.tipoCurso,
      estiloProgreso: estiloProgreso ?? this.estiloProgreso,
      urlImagen: urlImagen ?? this.urlImagen,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'CourseModel(id: $id, nombre: $nombre, tipoCurso: $tipoCurso, estiloProgreso: $estiloProgreso)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseModel &&
        other.id == id &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.tipoCurso == tipoCurso &&
        other.estiloProgreso == estiloProgreso &&
        other.urlImagen == urlImagen &&
        other.activo == activo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nombre.hashCode ^
        descripcion.hashCode ^
        tipoCurso.hashCode ^
        estiloProgreso.hashCode ^
        urlImagen.hashCode ^
        activo.hashCode;
  }
}