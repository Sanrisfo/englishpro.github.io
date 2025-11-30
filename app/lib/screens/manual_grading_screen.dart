import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/supabase_config.dart'; // Asegúrate de tener esto
// import '../providers/auth_provider.dart'; // No lo usamos si hacemos update directo

class ManualGradingScreen extends StatefulWidget {
  final Map<String, dynamic> feedback;

  const ManualGradingScreen({Key? key, required this.feedback}) : super(key: key);

  @override
  State<ManualGradingScreen> createState() => _ManualGradingScreenState();
}

class _ManualGradingScreenState extends State<ManualGradingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoadingAction = false; // Para el botón de "Marcar como revisado"
  bool _isAudioLoading = false;  // Para el buffer del audio
  bool _isPlaying = false;       // Para el estado de reproducción
  String? _errorMessage;

  // Color Azul Corporativo
  final Color _primaryColor = const Color(0xFF23408E);

  @override
  void initState() {
    super.initState();

    // Escuchar cambios en el reproductor
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          // Si está reproduciendo o pausado, ya no está cargando
          if (state == PlayerState.playing || state == PlayerState.paused) {
            _isAudioLoading = false;
          }
        });
      }
    });

    // Escuchar cuando el audio termina
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isAudioLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioUrl) async {
    // Si ya está sonando, lo pausamos
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    // Si le damos play, mostramos carga primero
    setState(() {
      _isAudioLoading = true;
    });

    try {
      // Usamos UrlSource para reproducir
      await _audioPlayer.play(UrlSource(audioUrl));
      // El listener onPlayerStateChanged se encargará de poner _isAudioLoading en false
      // cuando empiece a sonar realmente.
    } catch (e) {
      setState(() {
        _isAudioLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markAsReviewed() async {
    setState(() { _isLoadingAction = true; _errorMessage = null; });

    try {
      final responseId = (widget.feedback['id_respuesta'] as num?)?.toInt();
      if (responseId == null) throw Exception("Response ID missing");

      // Actualizamos directamente en Supabase
      // Quitamos el flag 'requiere_revision' para que salga de la lista de pendientes
      await supabase
          .from('respuestas_usuario')
          .update({
        'requiere_revision': false,
        // Opcional: Si quieres guardar que fue revisado sin nota, o poner una nota por defecto
        // 'puntaje_obtenido': 10,
      })
          .eq('id_respuesta', responseId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as reviewed'), backgroundColor: Color(0xFF23408E)),
        );
        Navigator.pop(context, true); // Retorna true para recargar la lista anterior
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  // --- HELPERS DE DISEÑO ---

  // Chip de estado o tipo
  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Datos
    final Map<String, dynamic>? q = (widget.feedback['preguntas'] as Map?)?.cast<String, dynamic>();
    final tipoPreguntaDb = (q?['tipo_pregunta'] as String?)?.toLowerCase();

    final tipoRespuesta = widget.feedback['tipo_respuesta'] as String? ??
        (tipoPreguntaDb == 'write_text' ? 'Writing' : 'Speaking');

    final respuestaTexto = (widget.feedback['respuesta_texto'] as String?) ?? (widget.feedback['texto_ensayo'] as String?);
    final respuestaAudioUrl = (widget.feedback['respuesta_audio_url'] as String?) ?? (widget.feedback['url_grabacion'] as String?);
    final preguntaId = widget.feedback['id_pregunta'] as int?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ENCABEZADO
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Review Submission',
                    style: GoogleFonts.ptSans(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryColor),
                  ),
                ],
              ),
            ),

            // 2. CONTENIDO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info del Estudiante
                    _buildStudentInfo(),
                    const SizedBox(height: 20),

                    // Tarjeta de la Pregunta
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Question #$preguntaId", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
                              _infoChip(tipoRespuesta, tipoRespuesta == 'Writing' ? Icons.edit_rounded : Icons.mic_rounded),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Student Response:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),

                          // --- RENDERIZADO DE RESPUESTA ---
                          _buildResponseContent(tipoRespuesta, respuestaTexto, respuestaAudioUrl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. BOTÓN INFERIOR
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoadingAction ? null : _markAsReviewed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoadingAction
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Mark as Reviewed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS INTERNOS ---

  Widget _buildStudentInfo() {
    final u = (widget.feedback['usuarios'] as Map?)?.cast<String, dynamic>();
    final nombre = (u?['nombre_completo'] as String?) ?? 'Student';
    final email = (u?['email'] as String?) ?? '';

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _primaryColor.withOpacity(0.1),
          child: Icon(Icons.person_rounded, color: _primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (email.isNotEmpty) Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponseContent(String type, String? text, String? audioUrl) {
    // 1. Caso WRITING
    if (type == 'Writing' && text != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          text,
          style: GoogleFonts.ptSans(fontSize: 16, height: 1.5, color: Colors.black87),
        ),
      );
    }
    // 2. Caso SPEAKING (Audio)
    else if (type == 'Speaking' && audioUrl != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryColor.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            // Visualización
            Icon(
              _isPlaying ? Icons.graphic_eq_rounded : Icons.audiotrack_rounded,
              size: 48,
              color: _primaryColor,
            ),
            const SizedBox(height: 16),

            // Botón de Acción
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isAudioLoading ? null : () => _playAudio(audioUrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                // Lógica del ícono y texto del botón
                icon: _isAudioLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                label: Text(_isAudioLoading
                    ? 'Loading...'
                    : _isPlaying
                    ? 'Pause Audio'
                    : 'Play Audio'),
              ),
            ),
          ],
        ),
      );
    }

    // Caso Vacío
    return Center(
      child: Text(
        "No content provided.",
        style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic),
      ),
    );
  }
}