/// Representa un curso educativo en la aplicación EnglishPro.
///
/// Los cursos pueden ser de diferentes tipos (ej. 'Examen' o 'Inmersivo')
/// y tener distintos estilos de progreso ('Porcentaje' o 'Modular').
class CourseModel {
  /// El identificador único del curso.
  final int id;

  /// El nombre del curso (ej. "TOEFL", "IELTS", "Business English").
  final String nombre;

  /// Una descripción detallada del curso.
  final String descripcion;

  /// El tipo de curso. Puede ser 'Examen' (para preparación de exámenes)
  /// o 'Inmersivo' (para aprendizaje general de habilidades).
  final String tipoCurso;

  /// El estilo en que se mide el progreso del usuario en este curso.
  /// Puede ser 'Porcentaje' (para cursos basados en puntuación)
  /// o 'Modular' (para cursos basados en la finalización de módulos).
  final String estiloProgreso;

  /// La URL de la imagen que representa el curso (opcional).
  final String? urlImagen;

  /// La fecha de creación del curso (opcional).
  final DateTime? fechaCreacion;

  /// Indica si el curso está activo y disponible para los usuarios.
  final bool activo;

  /// Crea una instancia de [CourseModel].
  ///
  /// @param id El identificador único del curso.
  /// @param nombre El nombre del curso.
  /// @param descripcion La descripción del curso.
  /// @param tipoCurso El tipo de curso ('Examen' o 'Inmersivo').
  /// @param estiloProgreso El estilo de progreso ('Porcentaje' o 'Modular').
  /// @param urlImagen La URL de la imagen del curso (opcional).
  /// @param fechaCreacion La fecha de creación del curso (opcional).
  /// @param activo Indica si el curso está activo. Por defecto es `true`.
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

  /// Crea un [CourseModel] a partir de un mapa JSON (Supabase/PostgREST).
  ///
  /// @param json Un mapa que contiene los datos del curso.
  /// @return Una nueva instancia de [CourseModel].
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

  /// Convierte esta instancia de [CourseModel] en un mapa JSON
  /// compatible con la API/base de datos.
  ///
  /// @return Una representación en mapa del curso.
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

  /// Verifica si el curso mide el progreso basándose en un porcentaje.
  ///
  /// @return `true` si `estiloProgreso` es 'Porcentaje', `false` en caso contrario.
  bool get isPercentageBased => estiloProgreso == 'Porcentaje';

  /// Verifica si el curso mide el progreso basándose en módulos.
  ///
  /// @return `true` si `estiloProgreso` es 'Modular', `false` en caso contrario.
  bool get isModuleBased => estiloProgreso == 'Modular';

  /// Verifica si el curso es de tipo "Examen" (ej. TOEFL, IELTS).
  ///
  /// @return `true` si `tipoCurso` es 'Examen', `false` en caso contrario.
  bool get isExamCourse => tipoCurso == 'Examen';

  /// Verifica si el curso es de tipo "Inmersivo" (ej. Business English, English in Action).
  ///
  /// @return `true` si `tipoCurso` es 'Inmersivo', `false` en caso contrario.
  bool get isImmersiveCourse => tipoCurso == 'Inmersivo';

  /// Obtiene un código de color hexadecimal asociado al nombre del curso.
  ///
  /// @return Un String que representa un código de color hexadecimal.
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

  /// Crea una copia de este [CourseModel] con los valores especificados
  /// reemplazando los valores actuales.
  ///
  /// @param id Nuevo ID del curso.
  /// @param nombre Nuevo nombre del curso.
  /// @param descripcion Nueva descripción.
  /// @param tipoCurso Nuevo tipo de curso.
  /// @param estiloProgreso Nuevo estilo de progreso.
  /// @param urlImagen Nueva URL de imagen.
  /// @param fechaCreacion Nueva fecha de creación.
  /// @param activo Nuevo estado activo.
  /// @return Una nueva instancia de [CourseModel] con los valores actualizados.
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
  /// Devuelve una representación en cadena de este [CourseModel].
  String toString() {
    return 'CourseModel(id: $id, nombre: $nombre, tipoCurso: $tipoCurso, estiloProgreso: $estiloProgreso)';
  }

  @override
  /// Compara si este [CourseModel] es igual a otro objeto.
  ///
  /// @param other El otro objeto a comparar.
  /// @return `true` si los objetos son idénticos o tienen los mismos valores en todas sus propiedades, `false` en caso contrario.
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
  /// Devuelve el código hash para este [CourseModel].
  ///
  /// @return Un entero que representa el código hash.
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
