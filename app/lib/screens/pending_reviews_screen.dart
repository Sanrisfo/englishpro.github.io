import 'package:flutter/material.dart';
import '../services/supabase_teacher_service.dart';
import 'manual_grading_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión - Pendientes'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          child: const Text('Reintentar'),
                        )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _pending.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No hay respuestas pendientes')),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12.0),
                          itemCount: _pending.length,
                          itemBuilder: (context, index) {
                            final f = _pending[index];
                            return _buildItem(f);
                          },
                        ),
                ),
    );
  }

  Widget _buildItem(Map<String, dynamic> feedback) {
    final tipoRespuesta = feedback['tipo_respuesta'] as String?;
    final fechaRespuesta = feedback['fecha_respuesta'] as String?;
    final preguntaId = feedback['id_pregunta'] as int?;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _openGrading(feedback),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (tipoRespuesta == 'Writing' ? Colors.blue : Colors.purple).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            tipoRespuesta == 'Writing' ? Icons.edit : Icons.mic,
            color: tipoRespuesta == 'Writing' ? Colors.blue : Colors.purple,
          ),
        ),
        title: Text('Pregunta #$preguntaId', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Tipo: ${tipoRespuesta ?? 'N/A'}'),
            if (fechaRespuesta != null) Text('Enviado: $fechaRespuesta'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  void _openGrading(Map<String, dynamic> feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualGradingScreen(feedback: feedback),
      ),
    ).then((_) => _load());
  }
}

