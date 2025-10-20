/// Payment Model - Backend
/// Matches Pagos table schema
class Payment {
  final int? id;
  final int usuarioId;
  final int planId;
  final double monto;
  final String metodoPago; // 'Stripe', 'PayPal', etc.
  final String estado; // 'Pendiente', 'Completado', 'Fallido', 'Reembolsado'
  final String? stripePaymentIntentId;
  final String? stripeCustomerId;
  final DateTime? fechaPago;
  final DateTime? fechaCreacion;

  Payment({
    this.id,
    required this.usuarioId,
    required this.planId,
    required this.monto,
    this.metodoPago = 'Stripe',
    this.estado = 'Pendiente',
    this.stripePaymentIntentId,
    this.stripeCustomerId,
    this.fechaPago,
    this.fechaCreacion,
  });

  /// Create Payment from database row
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id_pago'] as int?,
      usuarioId: map['id_usuario'] as int,
      planId: map['id_plan'] as int,
      monto: (map['monto'] as num).toDouble(),
      metodoPago: map['metodo_pago'] as String? ?? 'Stripe',
      estado: map['estado'] as String? ?? 'Pendiente',
      stripePaymentIntentId: map['stripe_payment_intent_id'] as String?,
      stripeCustomerId: map['stripe_customer_id'] as String?,
      fechaPago: map['fecha_pago'] != null
          ? DateTime.parse(map['fecha_pago'] as String)
          : null,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
    );
  }

  /// Convert Payment to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_pago': id,
      'id_usuario': usuarioId,
      'id_plan': planId,
      'monto': monto,
      'metodo_pago': metodoPago,
      'estado': estado,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_customer_id': stripeCustomerId,
      if (fechaPago != null) 'fecha_pago': fechaPago!.toIso8601String(),
      if (fechaCreacion != null)
        'fecha_creacion': fechaCreacion!.toIso8601String(),
    };
  }

  /// Convert Payment to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'plan_id': planId,
      'monto': monto,
      'metodo_pago': metodoPago,
      'estado': estado,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_customer_id': stripeCustomerId,
      'fecha_pago': fechaPago?.toIso8601String(),
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }

  /// Create Payment from JSON request
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int?,
      usuarioId: json['usuario_id'] as int,
      planId: json['plan_id'] as int,
      monto: (json['monto'] as num).toDouble(),
      metodoPago: json['metodo_pago'] as String? ?? 'Stripe',
      estado: json['estado'] as String? ?? 'Pendiente',
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      fechaPago: json['fecha_pago'] != null
          ? DateTime.parse(json['fecha_pago'] as String)
          : null,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  Payment copyWith({
    int? id,
    int? usuarioId,
    int? planId,
    double? monto,
    String? metodoPago,
    String? estado,
    String? stripePaymentIntentId,
    String? stripeCustomerId,
    DateTime? fechaPago,
    DateTime? fechaCreacion,
  }) {
    return Payment(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      planId: planId ?? this.planId,
      monto: monto ?? this.monto,
      metodoPago: metodoPago ?? this.metodoPago,
      estado: estado ?? this.estado,
      stripePaymentIntentId:
          stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      fechaPago: fechaPago ?? this.fechaPago,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

/// Subscription Model
/// Represents active subscriptions
class Subscription {
  final int? id;
  final int usuarioId;
  final int planId;
  final String estado; // 'Activa', 'Cancelada', 'Vencida', 'Pausada'
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool renovacionAutomatica;
  final String? stripeSubscriptionId;
  final DateTime? proximaFacturacion;

  Subscription({
    this.id,
    required this.usuarioId,
    required this.planId,
    this.estado = 'Activa',
    required this.fechaInicio,
    this.fechaFin,
    this.renovacionAutomatica = true,
    this.stripeSubscriptionId,
    this.proximaFacturacion,
  });

  /// Create Subscription from database row
  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id_suscripcion'] as int?,
      usuarioId: map['id_usuario'] as int,
      planId: map['id_plan'] as int,
      estado: map['estado'] as String? ?? 'Activa',
      fechaInicio: DateTime.parse(map['fecha_inicio'] as String),
      fechaFin: map['fecha_fin'] != null
          ? DateTime.parse(map['fecha_fin'] as String)
          : null,
      renovacionAutomatica: map['renovacion_automatica'] as bool? ?? true,
      stripeSubscriptionId: map['stripe_subscription_id'] as String?,
      proximaFacturacion: map['proxima_facturacion'] != null
          ? DateTime.parse(map['proxima_facturacion'] as String)
          : null,
    );
  }

  /// Convert Subscription to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_suscripcion': id,
      'id_usuario': usuarioId,
      'id_plan': planId,
      'estado': estado,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'renovacion_automatica': renovacionAutomatica,
      'stripe_subscription_id': stripeSubscriptionId,
      'proxima_facturacion': proximaFacturacion?.toIso8601String(),
    };
  }

  /// Convert Subscription to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'plan_id': planId,
      'estado': estado,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'renovacion_automatica': renovacionAutomatica,
      'stripe_subscription_id': stripeSubscriptionId,
      'proxima_facturacion': proximaFacturacion?.toIso8601String(),
    };
  }

  /// Create Subscription from JSON request
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int?,
      usuarioId: json['usuario_id'] as int,
      planId: json['plan_id'] as int,
      estado: json['estado'] as String? ?? 'Activa',
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      renovacionAutomatica: json['renovacion_automatica'] as bool? ?? true,
      stripeSubscriptionId: json['stripe_subscription_id'] as String?,
      proximaFacturacion: json['proxima_facturacion'] != null
          ? DateTime.parse(json['proxima_facturacion'] as String)
          : null,
    );
  }

  /// Check if subscription is active
  bool get isActive => estado == 'Activa' && (fechaFin == null || fechaFin!.isAfter(DateTime.now()));

  /// Create a copy with updated fields
  Subscription copyWith({
    int? id,
    int? usuarioId,
    int? planId,
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? renovacionAutomatica,
    String? stripeSubscriptionId,
    DateTime? proximaFacturacion,
  }) {
    return Subscription(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      planId: planId ?? this.planId,
      estado: estado ?? this.estado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      renovacionAutomatica: renovacionAutomatica ?? this.renovacionAutomatica,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      proximaFacturacion: proximaFacturacion ?? this.proximaFacturacion,
    );
  }
}
