/// Representa un material de estudio en la aplicación EnglishPro.
///
/// Este modelo describe los diferentes tipos de recursos educativos
/// que pueden ser utilizados por los estudiantes, como PDFs, videos, audios o texto.
class MaterialModel {
  /// El identificador único del material.
  final int id;

  /// El ID de la habilidad a la que pertenece este material.
  final int habilidadId;

  /// El título del material de estudio.
  final String titulo;

  /// Una descripción del material de estudio.
  final String descripcion;

  /// El tipo de material (ej. 'pdf', 'video', 'audio', 'text', 'link').
  final String tipoMaterial;

  /// El contenido de texto si el tipo de material es 'text' (opcional).
  final String? contenidoTexto;

  /// La URL del archivo o recurso externo (ej. PDF, video, audio) (opcional).
  final String? archivoUrl;

  /// El orden de visualización del material dentro de la lista de una habilidad.
  final int orden;

  /// Indica si el material es exclusivo para usuarios premium.
  final bool esPremium;

  /// La fecha de creación del material.
  final DateTime fechaCreacion;

  /// Crea una instancia de [MaterialModel].
  ///
  /// @param id El identificador único.
  /// @param habilidadId El ID de la habilidad asociada.
  /// @param titulo El título del material.
  /// @param descripcion La descripción del material.
  /// @param tipoMaterial El tipo de material.
  /// @param contenidoTexto El contenido de texto (opcional).
  /// @param archivoUrl La URL del archivo (opcional).
  /// @param orden El orden de visualización.
  /// @param esPremium Indica si es premium.
  /// @param fechaCreacion La fecha de creación.
  MaterialModel({
    required this.id,
    required this.habilidadId,
    required this.titulo,
    required this.descripcion,
    required this.tipoMaterial,
    this.contenidoTexto,
    this.archivoUrl,
    required this.orden,
    required this.esPremium,
    required this.fechaCreacion,
  });

  /// Crea un [MaterialModel] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica maneja variaciones en las claves JSON
  /// para proporcionar un análisis robusto de diferentes fuentes de datos.
  /// Incluye funciones de utilidad para la conversión segura de tipos.
  ///
  /// @param json Un mapa que contiene los datos del material.
  /// @return Una nueva instancia de [MaterialModel].
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    /// Convierte de forma segura un valor dinámico a un entero.
    ///
    /// @param v El valor a convertir.
    /// @param defaultValue El valor por defecto a retornar si la conversión falla.
    /// @return El valor convertido a entero o el valor por defecto.
    int toInt(dynamic v, {int defaultValue = 0}) {
      if (v == null) return defaultValue;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? defaultValue;
      return defaultValue;
    }

    /// Convierte de forma segura un valor dinámico a un booleano.
    ///
    /// @param v El valor a convertir.
    /// @param defaultValue El valor por defecto a retornar si la conversión falla.
    /// @return El valor convertido a booleano o el valor por defecto.
    bool toBool(dynamic v, {bool defaultValue = false}) {
      if (v == null) return defaultValue;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return defaultValue;
    }

    /// Convierte de forma segura un valor dinámico a String, o `null` si no es posible.
    ///
    /// @param v El valor a convertir.
    /// @return El valor convertido a String o `null`.
    String? toStringOrNull(dynamic v) => v?.toString();

    /// Convierte de forma segura un valor dinámico a DateTime.
    ///
    /// @param v El valor a convertir.
    /// @return El valor convertido a DateTime o la fecha y hora actual si falla.
    DateTime toDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final id = toInt(json['id'] ?? json['id_material'] ?? json['ID_Material']);
    final habilidadId = toInt(
      json['habilidad_id'] ?? json['id_habilidad'] ?? json['ID_Habilidad'],
    );
    final titulo = (json['titulo'] ?? json['Titulo'] ?? '').toString();
    final descripcion = (json['descripcion'] ?? json['Descripcion'] ?? '')
        .toString();
    final tipoMaterial = (json['tipo_material'] ?? json['Tipo_Material'] ?? '')
        .toString();
    final contenidoTexto = toStringOrNull(
      json['contenido_texto'] ?? json['Contenido_Texto'],
    );
    final archivoUrl = toStringOrNull(
      json['url_recurso'] ?? json['archivo_url'] ?? json['URL_Recurso'],
    );
    final orden = toInt(json['orden'] ?? json['Orden'], defaultValue: 1);
    final esPremium = toBool(json['es_premium'] ?? json['Es_Premium']);
    final fechaCreacion = toDate(
      json['fecha_creacion'] ??
          json['Fecha_Creacion'] ??
          json['created_at'] ??
          json['Created_At'],
    );

    return MaterialModel(
      id: id,
      habilidadId: habilidadId,
      titulo: titulo,
      descripcion: descripcion,
      tipoMaterial: tipoMaterial,
      contenidoTexto: contenidoTexto,
      archivoUrl: archivoUrl,
      orden: orden,
      esPremium: esPremium,
      fechaCreacion: fechaCreacion,
    );
  }

  /// Convierte esta instancia de [MaterialModel] en un mapa JSON.
  ///
  /// @return Una representación en mapa del material.
  Map<String, dynamic> toJson() {
    return {
      'id_material': id,
      'id_habilidad': habilidadId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo_material': tipoMaterial,
      'contenido_texto': contenidoTexto,
      'url_recurso': archivoUrl,
      'orden': orden,
      'es_premium': esPremium,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Verifica si el material es de tipo PDF.
  bool get isPdf => tipoMaterial.toLowerCase() == 'pdf';

  /// Verifica si el material es de tipo video.
  bool get isVideo => tipoMaterial.toLowerCase() == 'video';

  /// Verifica si el material es de tipo audio.
  bool get isAudio => tipoMaterial.toLowerCase() == 'audio';

  /// Verifica si el material es de tipo texto.
  bool get isText =>
      tipoMaterial.toLowerCase() == 'text' ||
      tipoMaterial.toLowerCase() == 'texto';

  /// Verifica si el material es un enlace externo.
  bool get isLink => tipoMaterial.toLowerCase() == 'link';

  /// Verifica si el material requiere ser descargado (PDF, Video, Audio).
  bool get requiresDownload => isPdf || isVideo || isAudio;

  /// Crea una copia de este [MaterialModel] con los valores especificados
  /// reemplazando los valores actuales.
  ///
  /// @param id Nuevo ID del material.
  /// @param habilidadId Nuevo ID de la habilidad.
  /// @param titulo Nuevo título.
  /// @param descripcion Nueva descripción.
  /// @param tipoMaterial Nuevo tipo de material.
  /// @param contenidoTexto Nuevo contenido de texto.
  /// @param archivoUrl Nueva URL del archivo.
  /// @param orden Nuevo orden de visualización.
  /// @param esPremium Nuevo estado premium.
  /// @param fechaCreacion Nueva fecha de creación.
  /// @return Una nueva instancia de [MaterialModel] con los valores actualizados.
  MaterialModel copyWith({
    int? id,
    int? habilidadId,
    String? titulo,
    String? descripcion,
    String? tipoMaterial,
    String? contenidoTexto,
    String? archivoUrl,
    int? orden,
    bool? esPremium,
    DateTime? fechaCreacion,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      habilidadId: habilidadId ?? this.habilidadId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipoMaterial: tipoMaterial ?? this.tipoMaterial,
      contenidoTexto: contenidoTexto ?? this.contenidoTexto,
      archivoUrl: archivoUrl ?? this.archivoUrl,
      orden: orden ?? this.orden,
      esPremium: esPremium ?? this.esPremium,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  /// Devuelve una representación en cadena de este [MaterialModel].
  String toString() {
    return 'MaterialModel(id: $id, titulo: $titulo, tipo: $tipoMaterial, premium: $esPremium)';
  }

  @override
  /// Compara si este [MaterialModel] es igual a otro objeto.
  ///
  /// @param other El otro objeto a comparar.
  /// @return `true` si los objetos son idénticos o tienen los mismos valores en todas sus propiedades, `false` en caso contrario.
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaterialModel &&
        other.id == id &&
        other.habilidadId == habilidadId &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.tipoMaterial == tipoMaterial &&
        other.contenidoTexto == contenidoTexto &&
        other.archivoUrl == archivoUrl &&
        other.orden == orden &&
        other.esPremium == esPremium &&
        other.fechaCreacion == fechaCreacion;
  }

  @override
  /// Devuelve el código hash para este [MaterialModel].
  ///
  /// @return Un entero que representa el código hash.
  int get hashCode {
    return id.hashCode ^
        habilidadId.hashCode ^
        titulo.hashCode ^
        descripcion.hashCode ^
        tipoMaterial.hashCode ^
        contenidoTexto.hashCode ^
        archivoUrl.hashCode ^
        orden.hashCode ^
        esPremium.hashCode ^
        fechaCreacion.hashCode;
  }
}
