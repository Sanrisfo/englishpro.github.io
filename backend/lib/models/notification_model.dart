class Notification {
  final int? idNotificacion;
  final int idUsuario;
  final String titulo;
  final String mensaje;
  final String? tipo; // 'Info', 'Retroalimentacion', 'Pago', 'Sistema'
  final bool leida;
  final DateTime? fechaCreacion;

  Notification({
    this.idNotificacion,
    required this.idUsuario,
    required this.titulo,
    required this.mensaje,
    this.tipo = 'Info',
    this.leida = false,
    this.fechaCreacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_notificacion': idNotificacion,
      'id_usuario': idUsuario,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'leida': leida,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return null;
    }

    return Notification(
      idNotificacion: json['id_notificacion'] as int?,
      idUsuario: json['id_usuario'] as int,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      tipo: json['tipo'] as String? ?? 'Info',
      leida: json['leida'] as bool? ?? false,
      fechaCreacion: parseDateTime(json['fecha_creacion']),
    );
  }

  Notification copyWith({
    int? idNotificacion,
    int? idUsuario,
    String? titulo,
    String? mensaje,
    String? tipo,
    bool? leida,
    DateTime? fechaCreacion,
  }) {
    return Notification(
      idNotificacion: idNotificacion ?? this.idNotificacion,
      idUsuario: idUsuario ?? this.idUsuario,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      leida: leida ?? this.leida,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
