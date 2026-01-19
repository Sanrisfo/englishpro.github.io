import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// Un widget para reproducir video desde una URL de red o un asset local.
///
/// Utiliza los paquetes `video_player` para la reproducción base y `chewie`
/// para proporcionar una interfaz de usuario completa con controles de
/// reproducción, pausa, volumen, pantalla completa, etc.
///
/// El widget es `Stateful` para poder gestionar el ciclo de vida del
/// [VideoPlayerController] y el [ChewieController], incluyendo su inicialización
/// y liberación de recursos.
class VideoPlayerWidget extends StatefulWidget {
  /// La URL del video. Puede ser una URL remota (`http` o `https`) o una
  /// ruta a un asset local (ej. `assets/videos/intro.mp4`).
  final String videoUrl;

  /// Si es `true`, el video comenzará a reproducirse automáticamente.
  /// Por defecto es `false`.
  final bool autoPlay;

  /// Si es `true`, el video se repetirá en un bucle infinito.
  /// Por defecto es `false`.
  final bool looping;

  /// Crea una instancia del reproductor de video.
  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  /// Controlador del paquete `video_player` para la gestión del video base.
  late VideoPlayerController _videoPlayerController;

  /// Controlador del paquete `chewie` que envuelve a `_videoPlayerController`
  /// para añadirle una interfaz de usuario.
  ChewieController? _chewieController;

  /// Indica si el video se está inicializando.
  bool _isLoading = true;

  /// Almacena un mensaje de error si la inicialización falla.
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// Inicializa los controladores de video.
  ///
  /// Determina si la URL es de red o de un asset, inicializa el
  /// [VideoPlayerController] correspondiente y luego configura el
  /// [ChewieController] con las opciones deseadas.
  Future<void> _initializePlayer() async {
    try {
      if (widget.videoUrl.startsWith('http')) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        _videoPlayerController = VideoPlayerController.asset(widget.videoUrl);
      }

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    // Es crucial liberar los recursos de los controladores para evitar fugas de memoria.
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el video',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
