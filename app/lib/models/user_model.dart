/// [LEGACY] Representa un usuario en el sistema.
///
/// **Nota:** Este modelo es considerado *legacy* y, en la implementación actual,
/// se prefiere el uso de [User] (definido en `user.dart`) para la compatibilidad
/// directa con Supabase. Sin embargo, se mantiene aquí por motivos de
/// compatibilidad con versiones anteriores o módulos específicos.
class UserModel {
  /// El identificador único del usuario.
  final int id;

  /// El nombre completo del usuario.
  final String nombre;

  /// El correo electrónico del usuario.
  final String email;

  /// La profesión del usuario (opcional).
  final String? profesion;

  /// El ID del plan de suscripción al que pertenece el usuario.
  final int planId;

  /// La fecha de registro del usuario en el sistema.
  final DateTime fechaRegistro;

  /// La URL de la foto de perfil del usuario (opcional).
  final String? photoUrl;

  /// Indica si el usuario tiene rol de docente.
  final bool esDocente;

  /// Crea una instancia de [UserModel].
  ///
  /// @param id El identificador único del usuario.
  /// @param nombre El nombre completo del usuario.
  /// @param email El correo electrónico del usuario.
  /// @param profesion La profesión del usuario (opcional).
  /// @param planId El ID del plan de suscripción.
  /// @param fechaRegistro La fecha de registro.
  /// @param photoUrl La URL de la foto de perfil (opcional).
  /// @param esDocente Indica si es docente (por defecto `false`).
  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.profesion,
    required this.planId,
    required this.fechaRegistro,
    this.photoUrl,
    this.esDocente = false,
  });

  /// Crea un [UserModel] a partir de un mapa JSON.
  ///
  /// @param json Un mapa que contiene los datos del usuario.
  /// @return Una nueva instancia de [UserModel].
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      profesion: json['profesion'] as String?,
      planId: json['plan_id'] as int,
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
      photoUrl: json['photo_url'] as String?,
      esDocente: json['es_docente'] as bool? ?? false,
    );
  }

  /// Convierte esta instancia de [UserModel] en un mapa JSON.
  ///
  /// @return Una representación en mapa del usuario.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'profesion': profesion,
      'plan_id': planId,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'photo_url': photoUrl,
      'es_docente': esDocente,
    };
  }

  /// Crea una copia de este [UserModel] con los valores especificados
  /// reemplazando los valores actuales.
  ///
  /// @param id Nuevo ID del usuario.
  /// @param nombre Nuevo nombre.
  /// @param email Nuevo email.
  /// @param profesion Nueva profesión.
  /// @param planId Nuevo ID del plan.
  /// @param fechaRegistro Nueva fecha de registro.
  /// @param photoUrl Nueva URL de la foto.
  /// @param esDocente Nuevo estado de docente.
  /// @return Una nueva instancia de [UserModel] con los valores actualizados.
  UserModel copyWith({
    int? id,
    String? nombre,
    String? email,
    String? profesion,
    int? planId,
    DateTime? fechaRegistro,
    String? photoUrl,
    bool? esDocente,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      profesion: profesion ?? this.profesion,
      planId: planId ?? this.planId,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      photoUrl: photoUrl ?? this.photoUrl,
      esDocente: esDocente ?? this.esDocente,
    );
  }

  @override
  /// Devuelve una representación en cadena de este [UserModel].
  String toString() {
    return 'UserModel(id: $id, nombre: $nombre, email: $email, planId: $planId, esDocente: $esDocente)';
  }

  @override
  /// Compara si este [UserModel] es igual a otro objeto.
  ///
  /// @param other El otro objeto a comparar.
  /// @return `true` si los objetos son idénticos o tienen los mismos valores en todas sus propiedades, `false` en caso contrario.
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.nombre == nombre &&
        other.email == email &&
        other.profesion == profesion &&
        other.planId == planId &&
        other.fechaRegistro == fechaRegistro &&
        other.photoUrl == photoUrl &&
        other.esDocente == esDocente;
  }

  @override
  /// Devuelve el código hash para este [UserModel].
  ///
  /// @return Un entero que representa el código hash.
  int get hashCode {
    return id.hashCode ^
        nombre.hashCode ^
        email.hashCode ^
        profesion.hashCode ^
        planId.hashCode ^
        fechaRegistro.hashCode ^
        photoUrl.hashCode ^
        esDocente.hashCode;
  }
}
