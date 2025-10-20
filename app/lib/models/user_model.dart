/// User Model - Representa un usuario en el sistema
class UserModel {
  final int id;
  final String nombre;
  final String email;
  final String? profesion;
  final int planId;
  final DateTime fechaRegistro;
  final String? photoUrl;
  final bool esDocente;

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

  /// Crear UserModel desde JSON
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

  /// Convertir UserModel a JSON
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

  /// Crear copia del modelo con cambios
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
  String toString() {
    return 'UserModel(id: $id, nombre: $nombre, email: $email, planId: $planId, esDocente: $esDocente)';
  }

  @override
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
