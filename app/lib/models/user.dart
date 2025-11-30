/// Modelo de usuario de la plataforma (tabla `usuarios`).
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

  /// Crea una instancia a partir de un mapa JSON proveniente de Supabase.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Supabase usa mayúsculas en columnas (Nombre_Completo)
      // Pero también acepta minúsculas por compatibilidad
      idUsuario: json['ID_Usuario'] ?? json['id_usuario'] as int,
      nombreCompleto: json['Nombre_Completo'] ?? json['nombre_completo'] as String,
      email: json['Email'] ?? json['email'] as String,
      profesion: json['Profesion'] ?? json['profesion'] as String?,
      idPlan: (json['ID_Plan'] ?? json['id_plan'] as int?) ?? 1,
      esDocente: (json['Es_Docente'] ?? json['es_docente'] as bool?) ?? false,
      rol: (json['Rol'] ?? json['rol'] as String?) ?? 'Estudiante',
      fechaRegistro: json['Fecha_Registro'] != null || json['fecha_registro'] != null
          ? DateTime.parse((json['Fecha_Registro'] ?? json['fecha_registro']) as String)
          : null,
      ultimoAcceso: json['Ultimo_Acceso'] != null || json['ultimo_acceso'] != null
          ? DateTime.parse((json['Ultimo_Acceso'] ?? json['ultimo_acceso']) as String)
          : null,
      firebaseUid: json['Firebase_UID'] ?? json['firebase_uid'] as String?,
      emailVerificado: (json['Email_Verificado'] ?? json['email_verificado'] as bool?) ?? false,
    );
  }

  /// Serializa la entidad al formato esperado por la API/BD.
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
