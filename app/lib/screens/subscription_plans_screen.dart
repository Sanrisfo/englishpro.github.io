import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plan_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final List<PlanModel> plans = [
    // Freemium
    PlanModel(
      id: 1,
      nombre: 'Freemium',
      descripcion: 'Plan gratuito ideal para empezar',
      precio: 0.0,
      limitePreguntasPorTipo: 50,
      tieneRetroalimentacionManual: false,
      sesionesEnVivo: 0,
      simulacrosCompletos: 0,
      accesoCompletoCursos: false,
    ),
    // Básico
    PlanModel(
      id: 2,
      nombre: 'Básico',
      descripcion: 'Acceso a más cuestionarios',
      precio: 9.99,
      limitePreguntasPorTipo: 200,
      tieneRetroalimentacionManual: false,
      sesionesEnVivo: 0,
      simulacrosCompletos: 1,
      accesoCompletoCursos: false,
    ),
    // Pro
    PlanModel(
      id: 3,
      nombre: 'Pro',
      descripcion: 'Para estudiantes serios',
      precio: 19.99,
      limitePreguntasPorTipo: 1000,
      tieneRetroalimentacionManual: true,
      sesionesEnVivo: 2,
      simulacrosCompletos: 5,
      accesoCompletoCursos: true,
    ),
    // Premium
    PlanModel(
      id: 4,
      nombre: 'Premium',
      descripcion: 'Acceso ilimitado y completo',
      precio: 29.99,
      limitePreguntasPorTipo: 999999,
      tieneRetroalimentacionManual: true,
      sesionesEnVivo: 10,
      simulacrosCompletos: 999999,
      accesoCompletoCursos: true,
    ),
  ];

  int? selectedPlanIndex;

  get authProvider => null;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserPlan = authProvider.user?.idPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Elige el plan perfecto para ti',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mejora tu experiencia y alcanza tus metas',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                if (currentUserPlan != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Plan Actual: $currentUserPlan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isCurrentPlan =
                    currentUserPlan?.toLowerCase() == plan.nombre.toLowerCase();
                final isSelected = selectedPlanIndex == index;

                return _buildPlanCard(
                  plan: plan,
                  isCurrentPlan: isCurrentPlan,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedPlanIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          if (selectedPlanIndex != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => _selectPlan(plans[selectedPlanIndex!]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    plans[selectedPlanIndex!].precio == 0
                        ? 'Continuar con plan gratuito'
                        : 'Suscribirse por \$${plans[selectedPlanIndex!].precio.toStringAsFixed(2)}/mes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required PlanModel plan,
    required bool isCurrentPlan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color cardColor;
    Color accentColor;
    IconData planIcon;

    switch (plan.nombre.toLowerCase()) {
      case 'freemium':
        cardColor = Colors.grey.shade50;
        accentColor = Colors.grey.shade600;
        planIcon = Icons.free_breakfast;
        break;
      case 'básico':
        cardColor = Colors.blue.shade50;
        accentColor = Colors.blue;
        planIcon = Icons.star_border;
        break;
      case 'pro':
        cardColor = Colors.purple.shade50;
        accentColor = Colors.purple;
        planIcon = Icons.star_half;
        break;
      case 'premium':
        cardColor = Colors.amber.shade50;
        accentColor = Colors.amber.shade700;
        planIcon = Icons.stars;
        break;
      default:
        cardColor = Colors.grey.shade50;
        accentColor = Colors.grey.shade600;
        planIcon = Icons.card_membership;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : isCurrentPlan
                ? Colors.green
                : Colors.transparent,
            width: isSelected || isCurrentPlan ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(planIcon, color: accentColor, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.nombre,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          if (isCurrentPlan)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Plan Actual',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.precio == 0
                            ? 'GRATIS'
                            : '\$${plan.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      if (plan.precio > 0)
                        const Text(
                          '/mes',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan.descripcion,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildFeature(
                icon: Icons.quiz,
                label: plan.limitePreguntasPorTipo == 999999
                    ? 'Cuestionarios ilimitados'
                    : '${plan.limitePreguntasPorTipo} preguntas por tipo',
                accentColor: accentColor,
              ),
              if (plan.accesoCompletoCursos)
                _buildFeature(
                  icon: Icons.school,
                  label: 'Acceso a todos los cursos',
                  accentColor: accentColor,
                ),
              if (plan.tieneRetroalimentacionManual)
                _buildFeature(
                  icon: Icons.feedback,
                  label: 'Retroalimentación personalizada',
                  accentColor: accentColor,
                ),
              if (plan.sesionesEnVivo != null && plan.sesionesEnVivo! > 0)
                _buildFeature(
                  icon: Icons.video_call,
                  label: plan.sesionesEnVivo == 999999
                      ? 'Sesiones en vivo ilimitadas'
                      : '${plan.sesionesEnVivo} sesiones en vivo/mes',
                  accentColor: accentColor,
                ),
              if (plan.simulacrosCompletos != null &&
                  plan.simulacrosCompletos! > 0)
                _buildFeature(
                  icon: Icons.assignment,
                  label: plan.simulacrosCompletos == 999999
                      ? 'Simulacros ilimitados'
                      : '${plan.simulacrosCompletos} simulacros completos',
                  accentColor: accentColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _selectPlan(PlanModel plan) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.idUsuario;

    if (userId == null) {
      _showErrorDialog('Debes iniciar sesión para suscribirte a un plan');
      return;
    }

    if (plan.precio == 0) {
      // Plan gratuito - solo mostrar confirmación
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Plan Freemium'),
          content: const Text(
            'Ya estás usando el plan gratuito. Puedes actualizarlo en cualquier momento para acceder a más funciones.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else {
      // Plan de pago - procesar pago
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Suscribirse a ${plan.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estás a punto de suscribirte al plan ${plan.nombre} por \$${plan.precio.toStringAsFixed(2)}/mes.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Modo de desarrollo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Este es un pago simulado para desarrollo. En producción se integrará con Stripe.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar Pago'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _processPlanPurchase(userId, plan);
      }
    }
  }

  Future<void> _processPlanPurchase(int userId, PlanModel plan) async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Paso 1: Crear intención de pago
      final paymentIntent = await ApiService.createPaymentIntent(
        userId: userId,
        planId: plan.id,
        amount: plan.precio,
      );

      if (paymentIntent['success'] != true) {
        Navigator.pop(context); // Cerrar loading
        _showErrorDialog(paymentIntent['message'] ?? 'Error al crear pago');
        return;
      }

      // Paso 2: Confirmar pago (simulado)
      final paymentId = paymentIntent['paymentId'] as int;
      final paymentIntentId = paymentIntent['paymentIntentId'] as String;

      final confirmation = await ApiService.confirmPayment(
        paymentId: paymentId,
        paymentIntentId: paymentIntentId,
      );

      Navigator.pop(context); // Cerrar loading

      if (confirmation['success'] == true) {
        // Actualizar el usuario en el provider
        await authProvider.refreshUser();

        _showSuccessDialog(
          'Suscripción exitosa',
          'Te has suscrito exitosamente al plan ${plan.nombre}. Ya puedes disfrutar de todos sus beneficios.',
        );
      } else {
        _showErrorDialog(confirmation['message'] ?? 'Error al confirmar pago');
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      _showErrorDialog('Error: $e');
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Recargar la pantalla para mostrar el nuevo plan
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'La integración con Stripe para pagos estará disponible en la siguiente fase del desarrollo (Sprint 4 Día 9-12).',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

extension on int? {
  toLowerCase() {}
}
