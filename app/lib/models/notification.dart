/// Representa una notificación dirigida a un usuario, incluyendo su estado de lectura.
///
/// Este modelo es utilizado para gestionar los mensajes y alertas que recibe un usuario
/// dentro de la aplicación, como retroalimentación del docente, información del sistema,
/// o actualizaciones de pago.
class NotificationModel {
  /// El identificador único de la notificación.
  final int idNotificacion;

  /// El ID del usuario al que se dirige la notificación.
  final int idUsuario;

  /// El título de la notificación.
  final String titulo;

  /// El contenido principal o mensaje de la notificación.
  final String mensaje;

  /// El tipo de notificación (ej., 'Info', 'Retroalimentacion', 'Pago', 'Sistema').
  final String tipo;

  /// Indica si la notificación ha sido leída por el usuario.
  final bool leida;

  /// La fecha y hora en que la notificación fue creada.
  final DateTime? fechaCreacion;

  /// Crea una instancia de [NotificationModel].
  ///
  /// @param idNotificacion El identificador único de la notificación.
  /// @param idUsuario El ID del usuario receptor.
  /// @param titulo El título de la notificación.
  /// @param mensaje El contenido del mensaje.
  /// @param tipo El tipo de notificación. Por defecto es 'Info'.
  /// @param leida Indica si ha sido leída. Por defecto es `false`.
  /// @param fechaCreacion La fecha de creación.
  NotificationModel({
    required this.idNotificacion,
    required this.idUsuario,
    required this.titulo,
    required this.mensaje,
    this.tipo = 'Info',
    this.leida = false,
    this.fechaCreacion,
  });

  /// Crea un [NotificationModel] a partir de un mapa JSON.
  ///
  /// @param json Un mapa que contiene los datos de la notificación.
  /// @return Una nueva instancia de [NotificationModel].
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

  /// Convierte esta instancia de [NotificationModel] en un mapa JSON.
  ///
  /// @return Una representación en mapa de la notificación.
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
