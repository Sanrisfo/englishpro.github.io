import 'package:postgres/postgres.dart';
import 'database_service.dart';
import '../models/payment_model.dart';

/// Payment Service
/// Handles payment processing and subscription management
/// NOTE: This is a mock service for development. In production, integrate with Stripe API.
class PaymentService {
  final DatabaseService _dbService;

  PaymentService(this._dbService);

  /// Create a payment intent (mock)
  /// In production, this would create a Stripe PaymentIntent
  Future<Map<String, dynamic>> createPaymentIntent({
    required int userId,
    required int planId,
    required double amount,
  }) async {
    try {
      // Mock Stripe Payment Intent ID
      final paymentIntentId = 'pi_mock_${DateTime.now().millisecondsSinceEpoch}';
      final customerId = 'cus_mock_$userId';

      // Create payment record
      final payment = Payment(
        usuarioId: userId,
        planId: planId,
        monto: amount,
        metodoPago: 'Stripe',
        estado: 'Pendiente',
        stripePaymentIntentId: paymentIntentId,
        stripeCustomerId: customerId,
        fechaCreacion: DateTime.now(),
      );

      final createdPayment = await createPayment(payment);

      return {
        'success': true,
        'paymentIntentId': paymentIntentId,
        'clientSecret': 'mock_client_secret_${DateTime.now().millisecondsSinceEpoch}',
        'paymentId': createdPayment.id,
        'amount': amount,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Confirm payment (mock)
  /// In production, this would be called after Stripe confirms the payment
  Future<Map<String, dynamic>> confirmPayment({
    required int paymentId,
    required String paymentIntentId,
  }) async {
    try {
      final connection = await _dbService.connection;

      // Update payment status to completed
      await connection.execute(
        Sql.named(
          '''
          UPDATE Pagos
          SET estado = 'Completado',
              fecha_pago = @fechaPago
          WHERE id_pago = @paymentId
          ''',
        ),
        parameters: {
          'fechaPago': DateTime.now().toIso8601String(),
          'paymentId': paymentId,
        },
      );

      // Get payment details
      final paymentResult = await connection.execute(
        Sql.named(
          'SELECT * FROM Pagos WHERE id_pago = @paymentId',
        ),
        parameters: {'paymentId': paymentId},
      );

      if (paymentResult.isEmpty) {
        throw Exception('Payment not found');
      }

      final row = paymentResult.first;
      final payment = Payment.fromMap(row.toColumnMap());

      // Update user's plan
      await _updateUserPlan(payment.usuarioId, payment.planId);

      // Create or update subscription
      await _createSubscription(payment.usuarioId, payment.planId);

      return {
        'success': true,
        'payment': payment.toJson(),
        'message': 'Payment confirmed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Create payment record
  Future<Payment> createPayment(Payment payment) async {
    final connection = await _dbService.connection;

    final result = await connection.execute(
      Sql.named(
        '''
        INSERT INTO Pagos (
          id_usuario, id_plan, monto, metodo_pago, estado,
          stripe_payment_intent_id, stripe_customer_id, fecha_creacion
        )
        VALUES (
          @usuarioId, @planId, @monto, @metodoPago, @estado,
          @stripePaymentIntentId, @stripeCustomerId, @fechaCreacion
        )
        RETURNING *
        ''',
      ),
      parameters: {
        'usuarioId': payment.usuarioId,
        'planId': payment.planId,
        'monto': payment.monto,
        'metodoPago': payment.metodoPago,
        'estado': payment.estado,
        'stripePaymentIntentId': payment.stripePaymentIntentId,
        'stripeCustomerId': payment.stripeCustomerId,
        'fechaCreacion': (payment.fechaCreacion ?? DateTime.now()).toIso8601String(),
      },
    );

    return Payment.fromMap(result.first.toColumnMap());
  }

  /// Get payment by ID
  Future<Payment?> getPaymentById(int paymentId) async {
    final connection = await _dbService.connection;

    final result = await connection.execute(
      Sql.named('SELECT * FROM Pagos WHERE id_pago = @paymentId'),
      parameters: {'paymentId': paymentId},
    );

    if (result.isEmpty) return null;

    return Payment.fromMap(result.first.toColumnMap());
  }

  /// Get payments by user
  Future<List<Payment>> getPaymentsByUser(int userId) async {
    final connection = await _dbService.connection;

    final result = await connection.execute(
      Sql.named(
        '''
        SELECT * FROM Pagos
        WHERE id_usuario = @userId
        ORDER BY fecha_creacion DESC
        ''',
      ),
      parameters: {'userId': userId},
    );

    return result.map((row) => Payment.fromMap(row.toColumnMap())).toList();
  }

  /// Create subscription
  Future<Subscription> _createSubscription(int userId, int planId) async {
    final connection = await _dbService.connection;

    // Check if user already has an active subscription
    final existingResult = await connection.execute(
      Sql.named(
        '''
        SELECT * FROM Suscripciones
        WHERE id_usuario = @userId AND estado = 'Activa'
        ''',
      ),
      parameters: {'userId': userId},
    );

    // Cancel existing subscription if any
    if (existingResult.isNotEmpty) {
      await connection.execute(
        Sql.named(
          '''
          UPDATE Suscripciones
          SET estado = 'Cancelada',
              fecha_fin = @now
          WHERE id_usuario = @userId AND estado = 'Activa'
          ''',
        ),
        parameters: {
          'userId': userId,
          'now': DateTime.now().toIso8601String(),
        },
      );
    }

    // Create new subscription
    final now = DateTime.now();
    final nextBilling = now.add(const Duration(days: 30)); // Monthly subscription

    final result = await connection.execute(
      Sql.named(
        '''
        INSERT INTO Suscripciones (
          id_usuario, id_plan, estado, fecha_inicio,
          renovacion_automatica, proxima_facturacion,
          stripe_subscription_id
        )
        VALUES (
          @userId, @planId, 'Activa', @fechaInicio,
          true, @proximaFacturacion, @stripeSubscriptionId
        )
        RETURNING *
        ''',
      ),
      parameters: {
        'userId': userId,
        'planId': planId,
        'fechaInicio': now.toIso8601String(),
        'proximaFacturacion': nextBilling.toIso8601String(),
        'stripeSubscriptionId': 'sub_mock_${now.millisecondsSinceEpoch}',
      },
    );

    return Subscription.fromMap(result.first.toColumnMap());
  }

  /// Get user's active subscription
  Future<Subscription?> getActiveSubscription(int userId) async {
    final connection = await _dbService.connection;

    final result = await connection.execute(
      Sql.named(
        '''
        SELECT * FROM Suscripciones
        WHERE id_usuario = @userId AND estado = 'Activa'
        ORDER BY fecha_inicio DESC
        LIMIT 1
        ''',
      ),
      parameters: {'userId': userId},
    );

    if (result.isEmpty) return null;

    return Subscription.fromMap(result.first.toColumnMap());
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(int subscriptionId) async {
    final connection = await _dbService.connection;

    await connection.execute(
      Sql.named(
        '''
        UPDATE Suscripciones
        SET estado = 'Cancelada',
            fecha_fin = @now,
            renovacion_automatica = false
        WHERE id_suscripcion = @subscriptionId
        ''',
      ),
      parameters: {
        'subscriptionId': subscriptionId,
        'now': DateTime.now().toIso8601String(),
      },
    );

    return true;
  }

  /// Update user's plan
  Future<void> _updateUserPlan(int userId, int planId) async {
    final connection = await _dbService.connection;

    await connection.execute(
      Sql.named(
        '''
        UPDATE Usuarios
        SET ID_Plan = @planId,
            Ultimo_Acceso = @now
        WHERE ID_Usuario = @userId
        ''',
      ),
      parameters: {
        'planId': planId,
        'userId': userId,
        'now': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get all subscriptions for a user
  Future<List<Subscription>> getSubscriptionsByUser(int userId) async {
    final connection = await _dbService.connection;

    final result = await connection.execute(
      Sql.named(
        '''
        SELECT * FROM Suscripciones
        WHERE id_usuario = @userId
        ORDER BY fecha_inicio DESC
        ''',
      ),
      parameters: {'userId': userId},
    );

    return result.map((row) => Subscription.fromMap(row.toColumnMap())).toList();
  }

  /// Process webhook (mock)
  /// In production, this would handle Stripe webhooks
  Future<Map<String, dynamic>> processWebhook(Map<String, dynamic> event) async {
    try {
      final eventType = event['type'] as String;

      switch (eventType) {
        case 'payment_intent.succeeded':
          // Handle successful payment
          final paymentIntentId = event['data']['object']['id'] as String;
          // Update payment status
          break;

        case 'payment_intent.failed':
          // Handle failed payment
          break;

        case 'customer.subscription.updated':
          // Handle subscription update
          break;

        case 'customer.subscription.deleted':
          // Handle subscription cancellation
          break;

        default:
          // Unknown event type
          break;
      }

      return {
        'success': true,
        'message': 'Webhook processed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
