import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/storage_service.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String audioPath) onRecordingComplete;
  final Function(String firebaseUrl)? onUploadComplete;
  final String? userId;
  final int? maxDurationSeconds;
  final bool autoUpload;

  const AudioRecorderWidget({
    Key? key,
    required this.onRecordingComplete,
    this.onUploadComplete,
    this.userId,
    this.maxDurationSeconds = 120, // 2 minutes default
    this.autoUpload = true,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
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

  Future<void> _startRecording() async {
    try {
      // Request permission
      if (await _audioRecorder.hasPermission()) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Start recording
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

        // Update duration
        _updateDuration();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se requiere permiso para grabar audio'),
          ),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar grabación: $e')),
      );
    }
  }

  void _updateDuration() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && !_isPaused) {
        setState(() {
          _recordingDuration++;
        });

        // Check max duration
        if (widget.maxDurationSeconds != null &&
            _recordingDuration >= widget.maxDurationSeconds!) {
          _stopRecording();
        } else {
          _updateDuration();
        }
      }
    });
  }

  Future<void> _pauseRecording() async {
    try {
      await _audioRecorder.pause();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _audioRecorder.resume();
      setState(() {
        _isPaused = false;
      });
      _updateDuration();
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

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

        // Auto upload to Firebase if enabled
        if (widget.autoUpload && widget.userId != null) {
          await _uploadToFirebase(path);
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _uploadToFirebase(String filePath) async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User ID requerido para subir')),
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
          setState(() {
            _uploadProgress = progress;
          });
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

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_recordingPath!));
      setState(() {
        _isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
          _playbackDuration = 0;
        });
      });

      _audioPlayer.onPositionChanged.listen((duration) {
        setState(() {
          _playbackDuration = duration.inSeconds;
        });
      });
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _playbackDuration = 0;
      });
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

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
        });
      } catch (e) {
        print('Error deleting recording: $e');
      }
    }
  }

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
            // Microphone icon
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 80,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 16),

            // Status text
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

            // Upload progress indicator
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

            // Duration display
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

            // Control buttons
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
                      // Play/Stop button
                      IconButton(
                        onPressed: _isPlaying ? _stopPlayback : _playRecording,
                        icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                        iconSize: 48,
                        color: Colors.blue,
                      ),
                      // Re-record button
                      IconButton(
                        onPressed: () {
                          _deleteRecording();
                          _startRecording();
                        },
                        icon: const Icon(Icons.refresh),
                        iconSize: 48,
                        color: Colors.orange,
                      ),
                      // Delete button
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
