import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../config/supabase_config.dart';

class ManualGradingScreen extends StatefulWidget {
  final Map<String, dynamic> feedback;

  const ManualGradingScreen({Key? key, required this.feedback}) : super(key: key);

  @override
  State<ManualGradingScreen> createState() => _ManualGradingScreenState();
}

class _ManualGradingScreenState extends State<ManualGradingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _puntuacionController = TextEditingController();
  final _comentariosController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = false;
  bool _isPlaying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _puntuacionController.dispose();
    _comentariosController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reproducir audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitGrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.idUsuario;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener datos del docente
      final teacherResponse = await ApiService.getTeacherByUserId(userId);
      if (teacherResponse['success'] != true || teacherResponse['teacher'] == null) {
        throw Exception('No se encontró información de docente');
      }

      final teacherData = teacherResponse['teacher'] as Map<String, dynamic>;
      final teacherId = teacherData['id_docente'] as int;

      // Enviar calificación
      final feedbackId = widget.feedback['id_feedback'] as int;
      final puntuacion = double.parse(_puntuacionController.text);
      final comentarios = _comentariosController.text.trim();

      final result = await ApiService.gradeFeedback(
        feedbackId: feedbackId,
        teacherId: teacherId,
        puntuacion: puntuacion,
        comentarios: comentarios.isNotEmpty ? comentarios : null,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Calificación guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(result['message'] ?? 'Error al guardar calificación');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Derivar tipo y contenido
    final Map<String, dynamic>? q = (widget.feedback['preguntas'] as Map?)?.cast<String, dynamic>();
    final tipoPreguntaDb = (q?['tipo_pregunta'] as String?)?.toLowerCase();

    final String? tipoRespuesta = widget.feedback['tipo_respuesta'] as String? ?? (
        tipoPreguntaDb == 'write_text' ? 'Writing' : tipoPreguntaDb == 'record_audio' ? 'Speaking' : null
    );

    final String? respuestaTexto = (widget.feedback['respuesta_texto'] as String?) ?? (widget.feedback['texto_ensayo'] as String?);
    final String? respuestaAudioUrl = (widget.feedback['respuesta_audio_url'] as String?) ?? (widget.feedback['url_grabacion'] as String?);
    final preguntaId = widget.feedback['id_pregunta'] as int?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar Respuesta'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(tipoRespuesta, preguntaId),
              const SizedBox(height: 20),
              _buildResponseSection(tipoRespuesta, respuestaTexto, respuestaAudioUrl),
              const SizedBox(height: 20),
              _buildStudentInfo(), // Aquí está la función corregida
              const SizedBox(height: 24),
              _buildReviewedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String? tipoRespuesta, int? preguntaId) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tipoRespuesta == 'Writing'
                    ? Colors.blue.shade100
                    : Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tipoRespuesta == 'Writing' ? Icons.edit : Icons.mic,
                color: tipoRespuesta == 'Writing' ? Colors.blue : Colors.purple,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pregunta #${preguntaId ?? "?"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tipo: $tipoRespuesta',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseSection(String? tipoRespuesta, String? respuestaTexto, String? respuestaAudioUrl) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Respuesta del Estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (tipoRespuesta == 'Writing' && respuestaTexto != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  respuestaTexto,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              )
            else if (tipoRespuesta == 'Speaking' && respuestaAudioUrl != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.audiotrack, size: 48, color: Colors.purple),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _playAudio(respuestaAudioUrl),
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pausar Audio' : 'Reproducir Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'No hay respuesta disponible',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- FUNCIÓN CORREGIDA ---
  Widget _buildStudentInfo() {
    final u = (widget.feedback['usuarios'] as Map?)?.cast<String, dynamic>();
    final nombre = (u?['nombre_completo'] as String?) ?? 'Estudiante';
    final email = (u?['email'] as String?) ?? '';
    final bc = widget.feedback['path_breadcrumb'] as String?;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF23408E)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0,
                    children: [
                      if (email.isNotEmpty)
                        Text(email, style: TextStyle(color: Colors.grey[700])),
                      _buildPlanChip(u), // Chip del plan
                    ],
                  ),
                  if (bc != null && bc.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      bc,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NUEVA FUNCIÓN PARA EL CHIP DEL PLAN ---
  Widget _buildPlanChip(Map<String, dynamic>? user) {
    // Lógica simple para mostrar el plan. Ajusta los IDs según tu DB.
    final planId = user?['id_plan'];
    String label = 'Plan';
    Color color = Colors.grey;

    if (planId == 1) { label = 'Freemium'; color = Colors.grey; }
    else if (planId == 2) { label = 'Básico'; color = Colors.blue; }
    else if (planId == 3) { label = 'Pro'; color = Colors.orange; }
    else if (planId == 4) { label = 'Premium'; color = Colors.purple; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReviewedButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _markReviewed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF23408E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        )
            : const Text('Marcar como revisado'),
      ),
    );
  }

  Future<void> _markReviewed() async {
    setState(() => _isLoading = true);
    try {
      final responseId = (widget.feedback['id_respuesta'] as num?)?.toInt();
      if (responseId == null) throw Exception('ID de respuesta no disponible');

      await supabase
          .from('respuestas_usuario')
          .update({'requiere_revision': false})
          .eq('id_respuesta', responseId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marcado como revisado')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

}