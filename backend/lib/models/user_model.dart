class User {
  final int? idUsuario;
  final String nombreCompleto;
  final String email;
  final String? passwordHash;
  final String? profesion;
  final int idPlan;
  final bool esDocente;
  final String rol;
  final DateTime? fechaRegistro;
  final DateTime? ultimoAcceso;
  final String? firebaseUid;
  final bool emailVerificado;

  User({
    this.idUsuario,
    required this.nombreCompleto,
    required this.email,
    this.passwordHash,
    this.profesion,
    this.idPlan = 1, // Default: Freemium
    this.esDocente = false,
    this.rol = 'Estudiante',
    this.fechaRegistro,
    this.ultimoAcceso,
    this.firebaseUid,
    this.emailVerificado = false,
  });

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

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return null;
    }

    return User(
      idUsuario: json['id_usuario'] as int?,
      nombreCompleto: json['nombre_completo'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String?,
      profesion: json['profesion'] as String?,
      idPlan: json['id_plan'] as int? ?? 1,
      esDocente: json['es_docente'] as bool? ?? false,
      rol: json['rol'] as String? ?? 'Estudiante',
      fechaRegistro: parseDateTime(json['fecha_registro']),
      ultimoAcceso: parseDateTime(json['ultimo_acceso']),
      firebaseUid: json['firebase_uid'] as String?,
      emailVerificado: json['email_verificado'] as bool? ?? false,
    );
  }

  User copyWith({
    int? idUsuario,
    String? nombreCompleto,
    String? email,
    String? passwordHash,
    String? profesion,
    int? idPlan,
    bool? esDocente,
    String? rol,
    DateTime? fechaRegistro,
    DateTime? ultimoAcceso,
    String? firebaseUid,
    bool? emailVerificado,
  }) {
    return User(
      idUsuario: idUsuario ?? this.idUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      profesion: profesion ?? this.profesion,
      idPlan: idPlan ?? this.idPlan,
      esDocente: esDocente ?? this.esDocente,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      emailVerificado: emailVerificado ?? this.emailVerificado,
    );
  }
}
