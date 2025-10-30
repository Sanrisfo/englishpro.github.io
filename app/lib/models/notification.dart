class NotificationModel {
  final int idNotificacion;
  final int idUsuario;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final DateTime? fechaCreacion;

  NotificationModel({
    required this.idNotificacion,
    required this.idUsuario,
    required this.titulo,
    required this.mensaje,
    this.tipo = 'Info',
    this.leida = false,
    this.fechaCreacion,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotificacion: json['id_notificacion'] as int,
      idUsuario: json['id_usuario'] as int,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      tipo: json['tipo'] as String? ?? 'Info',
      leida: json['leida'] as bool? ?? false,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
    );
  }

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
}
