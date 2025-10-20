/// Material Model - Representa un material de estudio
class MaterialModel {
  final int id;
  final int habilidadId;
  final String titulo;
  final String descripcion;
  final String tipoMaterial; // 'pdf', 'video', 'audio', 'text', 'link'
  final String? contenidoTexto;
  final String? archivoUrl;
  final int orden;
  final bool esPremium;
  final DateTime fechaCreacion;

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

  /// Crear MaterialModel desde JSON
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int,
      habilidadId: json['habilidad_id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipoMaterial: json['tipo_material'] as String,
      contenidoTexto: json['contenido_texto'] as String?,
      archivoUrl: json['archivo_url'] as String?,
      orden: json['orden'] as int,
      esPremium: json['es_premium'] as bool,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }

  /// Convertir MaterialModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habilidad_id': habilidadId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo_material': tipoMaterial,
      'contenido_texto': contenidoTexto,
      'archivo_url': archivoUrl,
      'orden': orden,
      'es_premium': esPremium,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Verificar si es material PDF
  bool get isPdf => tipoMaterial == 'pdf';

  /// Verificar si es material de video
  bool get isVideo => tipoMaterial == 'video';

  /// Verificar si es material de audio
  bool get isAudio => tipoMaterial == 'audio';

  /// Verificar si es material de texto
  bool get isText => tipoMaterial == 'text';

  /// Verificar si es enlace externo
  bool get isLink => tipoMaterial == 'link';

  /// Verificar si requiere descarga
  bool get requiresDownload => isPdf || isVideo || isAudio;

  /// Crear copia del modelo con cambios
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
  String toString() {
    return 'MaterialModel(id: $id, titulo: $titulo, tipo: $tipoMaterial, premium: $esPremium)';
  }

  @override
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
