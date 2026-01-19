/// Modelo de usuario de la plataforma (tabla `usuarios`).
///
/// Representa una fila de la tabla `usuarios` y está diseñada para sincronizarse
/// con el sistema de autenticación de Supabase. El modelo contempla variaciones
/// en la capitalización de las claves JSON para asegurar compatibilidad con
/// posibles migraciones o diferentes formatos de API.
class User {
  /// El identificador interno único del usuario, que corresponde a `id_usuario` en la base de datos.
  final int idUsuario;

  /// El nombre completo del usuario.
  final String nombreCompleto;

  /// El correo electrónico del usuario, que también es su identificador de inicio de sesión.
  final String email;

  /// La profesión declarada por el usuario (opcional).
  final String? profesion;

  /// El identificador del plan de suscripción al que está suscrito el usuario.
  final int idPlan;

  /// Un booleano que indica si el usuario tiene el rol de docente.
  final bool esDocente;

  /// El rol asignado al usuario (e.g., 'Estudiante', 'Docente', 'Admin').
  final String rol;

  /// La fecha y hora de registro del usuario (opcional).
  final DateTime? fechaRegistro;

  /// La fecha y hora del último acceso del usuario a la aplicación (opcional).
  final DateTime? ultimoAcceso;

  /// El UID previo de Firebase, utilizado si hubo una migración desde un sistema de autenticación Firebase.
  final String? firebaseUid;

  /// Un booleano que indica si el correo electrónico del usuario ha sido verificado.
  final bool emailVerificado;

  /// Crea una instancia del modelo [User].
  ///
  /// @param idUsuario El ID único del usuario.
  /// @param nombreCompleto El nombre completo del usuario.
  /// @param email El correo electrónico del usuario.
  /// @param profesion La profesión del usuario (opcional).
  /// @param idPlan El ID del plan de suscripción.
  /// @param esDocente Indica si es docente (por defecto `false`).
  /// @param rol El rol del usuario (por defecto 'Estudiante').
  /// @param fechaRegistro La fecha de registro (opcional).
  /// @param ultimoAcceso La fecha del último acceso (opcional).
  /// @param firebaseUid El UID de Firebase (opcional).
  /// @param emailVerificado Indica si el email está verificado (por defecto `false`).
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

  /// Crea una instancia [User] a partir de un mapa JSON.
  ///
  /// Este constructor de fábrica es capaz de parsear JSON donde las claves
  /// pueden estar en mayúsculas (como en algunas respuestas de Supabase)
  /// o en minúsculas, asegurando la robustez.
  ///
  /// @param json Un mapa que contiene los datos del usuario.
  /// @return Una nueva instancia de [User].
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Supabase a veces usa mayúsculas en columnas (Nombre_Completo),
      // pero también puede retornar en minúsculas por compatibilidad.
      idUsuario: json['ID_Usuario'] ?? json['id_usuario'] as int,
      nombreCompleto:
          json['Nombre_Completo'] ?? json['nombre_completo'] as String,
      email: json['Email'] ?? json['email'] as String,
      profesion: json['Profesion'] ?? json['profesion'] as String?,
      idPlan: (json['ID_Plan'] ?? json['id_plan'] as int?) ?? 1,
      esDocente: (json['Es_Docente'] ?? json['es_docente'] as bool?) ?? false,
      rol: (json['Rol'] ?? json['rol'] as String?) ?? 'Estudiante',
      fechaRegistro:
          json['Fecha_Registro'] != null || json['fecha_registro'] != null
          ? DateTime.parse(
              (json['Fecha_Registro'] ?? json['fecha_registro']) as String,
            )
          : null,
      ultimoAcceso:
          json['Ultimo_Acceso'] != null || json['ultimo_acceso'] != null
          ? DateTime.parse(
              (json['Ultimo_Acceso'] ?? json['ultimo_acceso']) as String,
            )
          : null,
      firebaseUid: json['Firebase_UID'] ?? json['firebase_uid'] as String?,
      emailVerificado:
          (json['Email_Verificado'] ?? json['email_verificado'] as bool?) ??
          false,
    );
  }

  /// Convierte esta instancia de [User] en un mapa JSON.
  ///
  /// Los nombres de las claves en el JSON de salida están en minúsculas
  /// para una consistencia estándar en las comunicaciones con la API o la base de datos.
  ///
  /// @return Una representación en mapa del usuario.
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
