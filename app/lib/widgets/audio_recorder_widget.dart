import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/storage_service.dart';

/// Un widget completo para la grabación, reproducción y subida de audio.
///
/// Este widget encapsula la lógica para:
/// - Solicitar permisos de grabación.
/// - Iniciar, pausar, reanudar y detener la grabación de audio.
/// - Reproducir el audio grabado.
/// - Eliminar la grabación local.
/// - Subir automáticamente el archivo a un servicio de almacenamiento.
///
/// Utiliza los paquetes `record` para la grabación y `audioplayers` para la
/// reproducción. Expone callbacks como [onRecordingComplete] y [onUploadComplete]
/// para notificar a los widgets padres sobre estos eventos.
///
/// ### Nota de obsolescencia:
/// Este widget utiliza [StorageService], que está obsoleto. Para nuevo
/// desarrollo, se debería migrar a [SupabaseStorageService].
///
/// ### Uso básico:
/// ```dart
/// AudioRecorderWidget(
///   userId: '123',
///   onRecordingComplete: (path) => print('Grabado en: $path'),
///   onUploadComplete: (url) => print('Subido a: $url'),
/// )
/// ```
class AudioRecorderWidget extends StatefulWidget {
  /// Callback que se ejecuta cuando la grabación finaliza. Devuelve la ruta local del archivo.
  final Function(String audioPath) onRecordingComplete;

  /// Callback que se ejecuta cuando la subida del archivo se completa. Devuelve la URL del archivo en el almacenamiento.
  final Function(String firebaseUrl)? onUploadComplete;

  /// El ID del usuario, necesario para la subida automática del archivo.
  final String? userId;

  /// La duración máxima de la grabación en segundos. Por defecto, 120 segundos.
  final int? maxDurationSeconds;

  /// Si es `true`, el archivo se subirá automáticamente al finalizar la grabación.
  final bool autoUpload;

  /// Crea una instancia del widget de grabación de audio.
  const AudioRecorderWidget({
    Key? key,
    required this.onRecordingComplete,
    this.onUploadComplete,
    this.userId,
    this.maxDurationSeconds = 120, // 2 minutos por defecto
    this.autoUpload = true,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  /// Controlador para la grabación de audio del paquete `record`.
  final AudioRecorder _audioRecorder = AudioRecorder();

  /// Controlador para la reproducción de audio del paquete `audioplayers`.
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// [DEPRECATED] Instancia del servicio de almacenamiento legado.
  final StorageService _storageService = StorageService();

  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  bool _isPlaying = false;
  bool _isUploading = false;
  String? _recordingPath;
  String? _firebaseUrl;
  int _recordingDuration = 0;
  int _playbackDuration = 0;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Inicia el proceso de grabación de audio.
  ///
  /// Solicita permisos, define una ruta temporal y comienza a grabar.
  /// Actualiza el estado de la UI y empieza un temporizador para la duración.
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordingPath = path;
          _recordingDuration = 0;
        });

        _updateDuration();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se requiere permiso para grabar audio'),
          ),
        );
      }
    } catch (e) {
      print('Error al iniciar grabación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar grabación: $e')),
      );
    }
  }

  /// Actualiza el contador de duración de la grabación cada segundo.
  ///
  /// Si se alcanza la duración máxima definida en [widget.maxDurationSeconds],
  /// detiene la grabación automáticamente.
  void _updateDuration() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_isRecording && !_isPaused) {
        setState(() {
          _recordingDuration++;
        });

        if (widget.maxDurationSeconds != null &&
            _recordingDuration >= widget.maxDurationSeconds!) {
          _stopRecording();
        } else {
          _updateDuration();
        }
      }
    });
  }

  /// Pausa la grabación de audio en curso.
  Future<void> _pauseRecording() async {
    try {
      await _audioRecorder.pause();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      print('Error al pausar grabación: $e');
    }
  }

  /// Reanuda una grabación de audio que estaba en pausa.
  Future<void> _resumeRecording() async {
    try {
      await _audioRecorder.resume();
      setState(() {
        _isPaused = false;
      });
      _updateDuration();
    } catch (e) {
      print('Error al reanudar grabación: $e');
    }
  }

  /// Detiene la grabación de audio.
  ///
  /// Llama al callback [onRecordingComplete] y, si [autoUpload] es `true`,
  /// inicia el proceso de subida del archivo.
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _hasRecording = path != null;
        _recordingPath = path;
      });

      if (path != null) {
        widget.onRecordingComplete(path);

        if (widget.autoUpload && widget.userId != null) {
          await _uploadToFirebase(path);
        }
      }
    } catch (e) {
      print('Error al detener grabación: $e');
    }
  }

  /// Sube el archivo grabado a Firebase Storage.
  ///
  /// Este método utiliza el [StorageService] legado. Actualiza el estado de la UI
  /// para mostrar el progreso de la subida y notifica el resultado mediante
  /// un `SnackBar` y el callback [onUploadComplete].
  ///
  /// @param filePath La ruta local del archivo a subir.
  Future<void> _uploadToFirebase(String filePath) async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Se requiere User ID para subir')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final file = File(filePath);
      final fileName = 'speaking_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final result = await _storageService.uploadAudio(
        userId: widget.userId!,
        audioFile: file,
        fileName: fileName,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (result['success'] == true) {
        setState(() {
          _firebaseUrl = result['url'];
          _isUploading = false;
        });

        if (widget.onUploadComplete != null) {
          widget.onUploadComplete!(result['url']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Audio subido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al subir: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Reproduce la grabación de audio desde su ruta local.
  Future<void> _playRecording() async {
    if (_recordingPath == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_recordingPath!));
      setState(() {
        _isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _playbackDuration = 0;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _playbackDuration = duration.inSeconds;
          });
        }
      });
    } catch (e) {
      print('Error al reproducir grabación: $e');
    }
  }

  /// Detiene la reproducción del audio.
  Future<void> _stopPlayback() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _playbackDuration = 0;
      });
    } catch (e) {
      print('Error al detener reproducción: $e');
    }
  }

  /// Elimina el archivo de grabación local.
  Future<void> _deleteRecording() async {
    if (_recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
        setState(() {
          _recordingPath = null;
          _hasRecording = false;
          _recordingDuration = 0;
          _playbackDuration = 0;
          _firebaseUrl = null;
        });
      } catch (e) {
        print('Error al eliminar grabación: $e');
      }
    }
  }

  /// Formatea una duración en segundos al formato `MM:SS`.
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de micrófono
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 80,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 16),

            // Texto de estado
            Text(
              _isUploading
                  ? 'Subiendo audio...'
                  : _isRecording
                      ? (_isPaused ? 'Grabación pausada' : 'Grabando...')
                      : _hasRecording
                          ? (_firebaseUrl != null
                              ? 'Audio subido ✓'
                              : 'Grabación completada')
                          : 'Listo para grabar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isUploading
                    ? Colors.orange
                    : _isRecording
                        ? Colors.red
                        : _firebaseUrl != null
                            ? Colors.green
                            : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),

            // Indicador de progreso de subida
            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 8),
                  Text(
                    '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            // Muestra de duración
            if (_isRecording || _hasRecording)
              Text(
                _isPlaying
                    ? _formatDuration(_playbackDuration)
                    : _formatDuration(_recordingDuration),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (widget.maxDurationSeconds != null)
              Text(
                'Máximo: ${_formatDuration(widget.maxDurationSeconds!)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

            const SizedBox(height: 24),

            // Botones de control
            if (!_isRecording && !_hasRecording)
              ElevatedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.fiber_manual_record),
                label: const Text('Iniciar Grabación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),

            if (_isRecording)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isPaused)
                    IconButton(
                      onPressed: _pauseRecording,
                      icon: const Icon(Icons.pause_circle_filled),
                      iconSize: 48,
                      color: Colors.orange,
                    )
                  else
                    IconButton(
                      onPressed: _resumeRecording,
                      icon: const Icon(Icons.play_circle_filled),
                      iconSize: 48,
                      color: Colors.green,
                    ),
                  IconButton(
                    onPressed: _stopRecording,
                    icon: const Icon(Icons.stop_circle),
                    iconSize: 48,
                    color: Colors.red,
                  ),
                ],
              ),

            if (_hasRecording && !_isRecording)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón de reproducir/detener
                      IconButton(
                        onPressed: _isPlaying ? _stopPlayback : _playRecording,
                        icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                        iconSize: 48,
                        color: Colors.blue,
                      ),
                      // Botón de re-grabar
                      IconButton(
                        onPressed: () {
                          _deleteRecording();
                          _startRecording();
                        },
                        icon: const Icon(Icons.refresh),
                        iconSize: 48,
                        color: Colors.orange,
                      ),
                      // Botón de eliminar
                      IconButton(
                        onPressed: _deleteRecording,
                        icon: const Icon(Icons.delete),
                        iconSize: 48,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Puedes escuchar, re-grabar o eliminar',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
