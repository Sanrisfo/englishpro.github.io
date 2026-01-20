import 'package:flutter/material.dart';
import '../services/supabase_teacher_service.dart';
import 'manual_grading_screen.dart';
import '../config/supabase_config.dart';

/// Pantalla que muestra una lista de envíos de estudiantes que están
/// pendientes de revisión manual por parte de un docente.
///
/// Este widget `Stateful` obtiene los datos de [SupabaseTeacherService.getPendingFeedbacks]
/// y los presenta en una lista. Permite al docente navegar a la pantalla
/// de calificación [ManualGradingScreen] para cada envío.
class PendingReviewsScreen extends StatefulWidget {
  /// Crea una instancia de la pantalla de revisiones pendientes.
  const PendingReviewsScreen({Key? key}) : super(key: key);

  @override
  State<PendingReviewsScreen> createState() => _PendingReviewsScreenState();
}

class _PendingReviewsScreenState extends State<PendingReviewsScreen> {
  /// Indica si los datos se están cargando.
  bool _isLoading = true;

  /// Almacena un mensaje de error si la carga falla.
  String? _errorMessage;

  /// Lista de revisiones pendientes, donde cada elemento es un mapa de datos.
  List<Map<String, dynamic>> _pending = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Carga la lista de revisiones pendientes desde el servicio.
  ///
  /// Utiliza [SupabaseTeacherService.getPendingFeedbacks] para obtener los datos
  /// y actualiza el estado de la UI para reflejar el estado de carga,
  /// error o éxito.
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await SupabaseTeacherService.getPendingFeedbacks();
      if (mounted) {
        setState(() => _pending = items);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error loading pending reviews: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
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
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9232A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                color: const Color(0xFFD9232A),
                child: _pending.isEmpty
                    ? _buildEmptyState(textTheme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: _pending.length,
                        itemBuilder: (context, index) {
                          final f = _pending[index];
                          return _buildFeedbackCard(f, textTheme);
                        },
                      ),
              ),
      ),
    );
  }

  /// Construye el widget que se muestra cuando no hay revisiones pendientes.
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
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.indigo,
                    size: 28,
                  ),
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

  /// Construye una tarjeta individual para una revisión pendiente.
  ///
  /// @param feedback El mapa de datos de la revisión pendiente.
  /// @param textTheme El tema de texto actual para el estilo.
  Widget _buildFeedbackCard(
    Map<String, dynamic> feedback,
    TextTheme textTheme,
  ) {
    final q = (feedback['preguntas'] as Map?)?.cast<String, dynamic>();
    final tipoDb = (q?['tipo_pregunta'] as String?)?.toLowerCase();
    final tipoRespuesta =
        (feedback['tipo_respuesta'] as String?) ??
        (tipoDb == 'write_text'
            ? 'Writing'
            : tipoDb == 'record_audio'
            ? 'Speaking'
            : null);
    final preguntaId = feedback['id_pregunta'] as int?;
    final fechaRespuesta = feedback['fecha_respuesta'] as String?;
    final bool isWriting = tipoRespuesta == 'Writing';

    final color = isWriting ? const Color(0xFF23408E) : const Color(0xFFD9232A);
    final icon = isWriting ? Icons.text_snippet_rounded : Icons.mic_rounded;
    final breadcrumb = (feedback['path_breadcrumb'] as String?) ?? '';
    final sent = 'Submitted: ${_formatDate(fechaRespuesta ?? '')}';

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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review of $tipoRespuesta (#$preguntaId)',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (breadcrumb.isNotEmpty)
                    Text(
                      breadcrumb,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  Text(
                    sent,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD9232A)),
              onPressed: () {
                final responseId = (feedback['id_respuesta'] as num?)?.toInt();
                if (responseId != null) {
                  _deleteSubmission(responseId);
                }
              },
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Formatea una cadena de fecha a un formato de tiempo relativo (ej. "hace 2d").
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
        return 'Now';
      }
    } catch (e) {
      return dateStr;
    }
  }

  /// Navega a la pantalla de calificación [ManualGradingScreen].
  ///
  /// Cuando la navegación se completa (al volver de la pantalla de calificación),
  /// se vuelve a cargar la lista de pendientes para reflejar los cambios.
  ///
  /// @param feedback El mapa de datos de la revisión a calificar.
  void _navigateToGrading(Map<String, dynamic> feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualGradingScreen(feedback: feedback),
      ),
    ).then((_) => _load());
  }

  Future<void> _deleteSubmission(int responseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this submission? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9232A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('respuestas_usuario').delete().eq('id_respuesta', responseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Submission deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting submission: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
