class User {
  final int idUsuario;
  final String nombreCompleto;
  final String email;
  final String? profesion;
  final int idPlan;
  final bool esDocente;
  final String rol;
  final DateTime? fechaRegistro;
  final DateTime? ultimoAcceso;
  final String? firebaseUid;
  final bool emailVerificado;

  User({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.email,
    this.profesion,
    required this.idPlan,
    this.esDocente = false,
    this.rol = 'Estudiante',
    this.fechaRegistro,
    this.ultimoAcceso,
    this.firebaseUid,
    this.emailVerificado = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsuario: json['id_usuario'] as int,
      nombreCompleto: json['nombre_completo'] as String,
      email: json['email'] as String,
      profesion: json['profesion'] as String?,
      idPlan: json['id_plan'] as int? ?? 1,
      esDocente: json['es_docente'] as bool? ?? false,
      rol: json['rol'] as String? ?? 'Estudiante',
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
      ultimoAcceso: json['ultimo_acceso'] != null
          ? DateTime.parse(json['ultimo_acceso'] as String)
          : null,
      firebaseUid: json['firebase_uid'] as String?,
      emailVerificado: json['email_verificado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre_completo': nombreCompleto,
      'email': email,
      'profesion': profesion,
      'id_plan': idPlan,
      'es_docente': esDocente,
      'rol': rol,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'ultimo_acceso': ultimoAcceso?.toIso8601String(),
      'firebase_uid': firebaseUid,
      'email_verificado': emailVerificado,
    };
  }
}
