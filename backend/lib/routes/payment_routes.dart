import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/payment_service.dart';

class PaymentRoutes {
  final PaymentService _paymentService;
  final Router router = Router();

  PaymentRoutes(this._paymentService) {
    // Payment Intent routes
    router.post('/create-intent', _createPaymentIntent);
    router.post('/confirm/<paymentId>', _confirmPayment);

    // Payment routes
    router.get('/<paymentId>', _getPaymentById);
    router.get('/user/<userId>', _getPaymentsByUser);

    // Subscription routes
    router.get('/subscriptions/user/<userId>', _getUserSubscriptions);
    router.get('/subscriptions/user/<userId>/active', _getActiveSubscription);
    router.post('/subscriptions/<subscriptionId>/cancel', _cancelSubscription);

    // Webhook route (for Stripe webhooks in production)
    router.post('/webhook', _handleWebhook);
  }

  // POST /api/payments/create-intent
  Future<Response> _createPaymentIntent(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final userId = payload['usuario_id'] as int;
      final planId = payload['plan_id'] as int;
      final amount = (payload['monto'] as num).toDouble();

      final result = await _paymentService.createPaymentIntent(
        userId: userId,
        planId: planId,
        amount: amount,
      );

      if (result['success'] == true) {
        return Response(201,
          body: jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/payments/confirm/:paymentId
  Future<Response> _confirmPayment(Request request, String paymentId) async {
    try {
      final id = int.tryParse(paymentId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid payment ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final paymentIntentId = payload['payment_intent_id'] as String;

      final result = await _paymentService.confirmPayment(
        paymentId: id,
        paymentIntentId: paymentIntentId,
      );

      if (result['success'] == true) {
        return Response.ok(
          jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/payments/:paymentId
  Future<Response> _getPaymentById(Request request, String paymentId) async {
    try {
      final id = int.tryParse(paymentId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid payment ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payment = await _paymentService.getPaymentById(id);

      if (payment == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Payment not found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': payment.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/payments/user/:userId
  Future<Response> _getPaymentsByUser(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid user ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payments = await _paymentService.getPaymentsByUser(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': payments.map((p) => p.toJson()).toList(),
          'count': payments.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/payments/subscriptions/user/:userId
  Future<Response> _getUserSubscriptions(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid user ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final subscriptions = await _paymentService.getSubscriptionsByUser(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': subscriptions.map((s) => s.toJson()).toList(),
          'count': subscriptions.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/payments/subscriptions/user/:userId/active
  Future<Response> _getActiveSubscription(Request request, String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid user ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final subscription = await _paymentService.getActiveSubscription(id);

      if (subscription == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'No active subscription found',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': subscription.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/payments/subscriptions/:subscriptionId/cancel
  Future<Response> _cancelSubscription(Request request, String subscriptionId) async {
    try {
      final id = int.tryParse(subscriptionId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid subscription ID',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final success = await _paymentService.cancelSubscription(id);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Subscription cancelled successfully',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to cancel subscription',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/payments/webhook
  Future<Response> _handleWebhook(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final result = await _paymentService.processWebhook(payload);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
