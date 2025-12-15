import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/supabase_config.dart';

/// Pantalla para la calificación manual de una respuesta de un estudiante.
///
/// Este widget `Stateful` recibe los datos de una respuesta específica y muestra
/// el contenido (texto o audio) para que el docente pueda revisarlo.
/// Ofrece funcionalidades para reproducir audio y marcar la revisión como completada.
class ManualGradingScreen extends StatefulWidget {
  /// Un mapa que contiene los datos de la respuesta a calificar.
  ///
  /// Incluye información del estudiante, la pregunta y la respuesta misma.
  final Map<String, dynamic> feedback;

  /// Crea una instancia de la pantalla de calificación manual.
  const ManualGradingScreen({Key? key, required this.feedback}) : super(key: key);

  @override
  State<ManualGradingScreen> createState() => _ManualGradingScreenState();
}

class _ManualGradingScreenState extends State<ManualGradingScreen> {
  /// Controlador para la reproducción de audio.
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Indica si una acción (como "Marcar como revisado") está en progreso.
  bool _isLoadingAction = false;

  /// Indica si el audio se está cargando/bufferizando.
  bool _isAudioLoading = false;

  /// Indica si el audio se está reproduciendo actualmente.
  bool _isPlaying = false;

  /// Almacena un mensaje de error si ocurre un problema.
  String? _errorMessage;

  /// Color principal de la UI para esta pantalla.
  final Color _primaryColor = const Color(0xFF23408E);

  @override
  void initState() {
    super.initState();
    _setupAudioPlayerListeners();
  }

  /// Configura los listeners del reproductor de audio para manejar los cambios de estado.
  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.playing || state == PlayerState.paused) {
            _isAudioLoading = false;
          }
        });
      }
    });

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

  /// Inicia o pausa la reproducción de un audio desde una URL.
  ///
  /// @param audioUrl La URL del archivo de audio a reproducir.
  Future<void> _playAudio(String audioUrl) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    setState(() {
      _isAudioLoading = true;
    });

    try {
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      if(mounted) {
        setState(() {
          _isAudioLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Marca la revisión como completada en la base de datos.
  ///
  /// Actualiza la columna `requiere_revision` a `false` en la tabla `respuestas_usuario`
  /// para que ya no aparezca en la lista de pendientes.
  Future<void> _markAsReviewed() async {
    setState(() { _isLoadingAction = true; _errorMessage = null; });

    try {
      final responseId = (widget.feedback['id_respuesta'] as num?)?.toInt();
      if (responseId == null) throw Exception("Falta el ID de la respuesta");

      await supabase
          .from('respuestas_usuario')
          .update({'requiere_revision': false})
          .eq('id_respuesta', responseId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marcado como revisado'), backgroundColor: Color(0xFF23408E)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if(mounted) {
        setState(() => _errorMessage = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentInfo(),
                    const SizedBox(height: 20),
                    _buildQuestionCard(preguntaId, tipoRespuesta, respuestaTexto, respuestaAudioUrl),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS INTERNOS DE CONSTRUCCIÓN DE UI ---

  /// Construye el encabezado de la pantalla con el botón de retroceso y el título.
  Widget _buildHeader() {
    return Padding(
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
            'Revisar Envío',
            style: GoogleFonts.ptSans(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryColor),
          ),
        ],
      ),
    );
  }

  /// Construye la sección con la información del estudiante.
  Widget _buildStudentInfo() {
    final u = (widget.feedback['usuarios'] as Map?)?.cast<String, dynamic>();
    final nombre = (u?['nombre_completo'] as String?) ?? 'Estudiante';
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

  /// Construye la tarjeta principal que contiene la respuesta del estudiante.
  Widget _buildQuestionCard(int? preguntaId, String tipoRespuesta, String? respuestaTexto, String? respuestaAudioUrl) {
    return Container(
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
              Text("Pregunta #$preguntaId", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
              _infoChip(tipoRespuesta, tipoRespuesta == 'Writing' ? Icons.edit_rounded : Icons.mic_rounded),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Respuesta del Estudiante:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildResponseContent(tipoRespuesta, respuestaTexto, respuestaAudioUrl),
        ],
      ),
    );
  }

  /// Construye el botón inferior para marcar la revisión como completada.
  Widget _buildBottomButton() {
    return Container(
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
              : const Text('Marcar como Revisado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  /// Renderiza el contenido de la respuesta según su tipo (texto o audio).
  Widget _buildResponseContent(String type, String? text, String? audioUrl) {
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
            Icon(
              _isPlaying ? Icons.graphic_eq_rounded : Icons.audiotrack_rounded,
              size: 48,
              color: _primaryColor,
            ),
            const SizedBox(height: 16),
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
                icon: _isAudioLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                label: Text(_isAudioLoading
                    ? 'Cargando...'
                    : _isPlaying
                    ? 'Pausar Audio'
                    : 'Reproducir Audio'),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        "No se proporcionó contenido.",
        style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic),
      ),
    );
  }

  /// Construye un chip informativo con un ícono y una etiqueta.
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
}