import 'package:flutter/material.dart';
import '../services/supabase_teacher_service.dart';
import 'manual_grading_screen.dart';

/// Listado de envíos pendientes de revisión manual (docente).
class PendingReviewsScreen extends StatefulWidget {
  const PendingReviewsScreen({Key? key}) : super(key: key);

  @override
  State<PendingReviewsScreen> createState() => _PendingReviewsScreenState();
}

class _PendingReviewsScreenState extends State<PendingReviewsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _pending = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await SupabaseTeacherService.getPendingFeedbacks();
      setState(() => _pending = items);
    } catch (e) {
      setState(() => _errorMessage = 'Error al cargar pendientes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,

      // Boton flotante rojo (EstÃ¡ndar)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: const Color(0xFFD9232A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_back_ios_new),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFD9232A),
            strokeWidth: 5.0,
          ),
        )
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9232A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                )
              ],
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _load,
          color: const Color(0xFFD9232A),
          child: _pending.isEmpty
              ? _buildEmptyState(textTheme) // Nuevo estado vacÃ­o
              : ListView.builder(
            padding: const EdgeInsets.all(24.0), // Padding consistente
            itemCount: _pending.length,
            itemBuilder: (context, index) {
              final f = _pending[index];
              return _buildFeedbackCard(f, textTheme); // Nueva tarjeta
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Estado VacÃ­o Estilizado ---
  Widget _buildEmptyState(TextTheme textTheme) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.indigo, size: 28),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'No pending submissions',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET: Tarjeta de Feedback Estilizada (EstÃ¡ndar Dashboard) ---
  Widget _buildFeedbackCard(Map<String, dynamic> feedback, TextTheme textTheme) {
    final q = (feedback['preguntas'] as Map?)?.cast<String, dynamic>();
final tipoDb = (q?['tipo_pregunta'] as String?)?.toLowerCase();
final tipoRespuesta = (feedback['tipo_respuesta'] as String?) ?? (tipoDb == 'write_text' ? 'Writing' : tipoDb == 'record_audio' ? 'Speaking' : null);
    final preguntaId = feedback['id_pregunta'] as int?;
    final fechaRespuesta = feedback['fecha_respuesta'] as String?;
    final bool isWriting = tipoRespuesta == 'Writing';

    // Colores estÃ¡ndar: Writing = Azul, Speaking = Rojo
    final color = isWriting ? const Color(0xFF23408E) : const Color(0xFFD9232A);
    final icon = isWriting ? Icons.text_snippet_rounded : Icons.mic_rounded;
    final breadcrumb = (feedback['path_breadcrumb'] as String?) ?? '';
    final sent = 'Sent: ${_formatDate(fechaRespuesta ?? '')}';

    return InkWell(
      onTap: () => _navigateToGrading(feedback),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            // Icono con fondo de color
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revision $tipoRespuesta (#$preguntaId)',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (breadcrumb.isNotEmpty) Text(breadcrumb, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(sent, style: TextStyle(color: Colors.grey[600], fontSize: 14)),

                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- Helper para formatear fecha ---
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Ahora';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _navigateToGrading(Map<String, dynamic> feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualGradingScreen(feedback: feedback),
      ),
    ).then((_) => _load());
  }
}


