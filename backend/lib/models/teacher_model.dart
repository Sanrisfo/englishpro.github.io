class Teacher {
  final int? id;
  final int usuarioId;
  final String especialidad;
  final String? certificaciones;
  final int aniosExperiencia;
  final bool activo;
  final DateTime? fechaRegistro;

  Teacher({
    this.id,
    required this.usuarioId,
    required this.especialidad,
    this.certificaciones,
    this.aniosExperiencia = 0,
    this.activo = true,
    this.fechaRegistro,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id_docente'] as int?,
      usuarioId: json['id_usuario'] as int,
      especialidad: json['especialidad'] as String,
      certificaciones: json['certificaciones'] as String?,
      aniosExperiencia: json['anios_experiencia'] as int? ?? 0,
      activo: json['activo'] as bool? ?? true,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id_docente': id,
      'id_usuario': usuarioId,
      'especialidad': especialidad,
      if (certificaciones != null) 'certificaciones': certificaciones,
      'anios_experiencia': aniosExperiencia,
      'activo': activo,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro!.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id_usuario': usuarioId,
      'especialidad': especialidad,
      if (certificaciones != null) 'certificaciones': certificaciones,
      'anios_experiencia': aniosExperiencia,
      'activo': activo,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    };
  }
}
