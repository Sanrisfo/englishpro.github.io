import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../widgets/audio_recorder_widget.dart';
import 'quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final String skillName;
  final int skillId;
  final int userId;
  final int? quizId;

  const QuizScreen({
    Key? key,
    required this.questions,
    required this.skillName,
    required this.skillId,
    required this.userId,
    this.quizId,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, dynamic> _answers = {}; // questionId -> answer (optionId or audioUrl)
  int? _selectedOptionId;
  String? _audioUrl; // Firebase URL for audio responses
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isAnswerSubmitted = false;
  int? _currentAttemptId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
    _startTimer();
  }

  Future<void> _initializeQuiz() async {
    if (widget.quizId != null) {
      setState(() => _isLoading = true);

      final result = await ApiService.createQuizAttempt(
        userId: widget.userId,
        quizId: widget.quizId!,
      );

      if (result['success'] == true && mounted) {
        setState(() {
          _currentAttemptId = result['attempt']['id'] as int;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final question = widget.questions[_currentQuestionIndex];
    if (question.hasTimeLimit) {
      _secondsRemaining = question.tiempoLimiteSegundos!;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _submitAnswer();
        }
      });
    }
  }

  Future<void> _submitAnswer() async {
    setState(() {
      _isAnswerSubmitted = true;
      _isLoading = true;
    });
    _timer?.cancel();

    final question = widget.questions[_currentQuestionIndex];

    // Save answer locally and submit to backend
    if (question.isMultipleChoice && _selectedOptionId != null) {
      _answers[question.id] = _selectedOptionId;

      await ApiService.submitAnswer(
        userId: widget.userId,
        preguntaId: question.id,
        opcionSeleccionadaId: _selectedOptionId,
      );
    } else if (question.isAudioResponse && _audioUrl != null) {
      _answers[question.id] = _audioUrl;

      await ApiService.submitAnswer(
        userId: widget.userId,
        preguntaId: question.id,
        audioUrl: _audioUrl,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }

    // Nota: ya no auto-avanzamos para permitir leer la retroalimentación
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionId = null;
        _audioUrl = null;
        _isAnswerSubmitted = false;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOptionId = null;
        _audioUrl = null;
        _isAnswerSubmitted = false;
      });
      _startTimer();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    setState(() => _isLoading = true);

    // Calculate score
    int correctAnswers = 0;
    int totalScore = 0;
    int maxScore = 0;

    for (var question in widget.questions) {
      maxScore += question.puntaje;
      if (_answers.containsKey(question.id) && question.isMultipleChoice) {
        final selectedOptionId = _answers[question.id];
        final correctOption = question.opciones?.firstWhere(
          (opt) => opt.esCorrecta,
          orElse: () => question.opciones!.first,
        );
        if (selectedOptionId == correctOption?.id) {
          correctAnswers++;
          totalScore += question.puntaje;
        }
      }
    }

    final porcentaje = maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0;

    // Update quiz attempt if exists
    if (_currentAttemptId != null) {
      await ApiService.updateQuizAttempt(
        attemptId: _currentAttemptId!,
        puntosObtenidos: totalScore,
        porcentaje: porcentaje,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);

      // Navigate to results screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            correctAnswers: correctAnswers,
            totalQuestions: widget.questions.length,
            totalScore: totalScore,
            maxScore: maxScore,
            percentage: porcentaje,
            questions: widget.questions,
            userAnswers: _answers,
          ),
        ),
      );
    }
  }

  Color _getTimerColor() {
    if (_secondsRemaining > 10) return Colors.green;
    if (_secondsRemaining > 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.skillName} Quiz'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),

          // Timer (if applicable)
          if (question.hasTimeLimit)
            Container(
              padding: const EdgeInsets.all(16),
              color: _getTimerColor().withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getTimerColor() == Colors.red ? Icons.warning : Icons.timer,
                      color: _getTimerColor()),
                  const SizedBox(width: 8),
                  Text(
                    'Tiempo restante: $_secondsRemaining segundos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getTimerColor(),
                    ),
                  ),
                ],
              ),
            ),

          // Question counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pregunta ${_currentQuestionIndex + 1} de ${widget.questions.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.textoPregunta,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Multimedia content (if any)
                  if (question.imagenUrl != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          question.imagenUrl!,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 100),
                        ),
                      ),
                    ),

                  if (question.audioUrl != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Play audio
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Reproducir Audio'),
                      ),
                    ),

                  // Answer options (for multiple choice)
                  if (question.isMultipleChoice && question.opciones != null)
                    ...question.opciones!.map((option) {
                      final isSelected = _selectedOptionId == option.id;
                      final isCorrect = option.esCorrecta;
                      final showCorrect = _isAnswerSubmitted && isCorrect;
                      final showIncorrect =
                          _isAnswerSubmitted && isSelected && !isCorrect;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: _isAnswerSubmitted
                              ? null
                              : () {
                                  setState(() {
                                    _selectedOptionId = option.id;
                                  });
                                },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: showCorrect
                                  ? Colors.green.withOpacity(0.2)
                                  : showIncorrect
                                      ? Colors.red.withOpacity(0.2)
                                      : isSelected
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: showCorrect
                                    ? Colors.green
                                    : showIncorrect
                                        ? Colors.red
                                        : isSelected
                                            ? Colors.blue
                                            : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  showCorrect
                                      ? Icons.check_circle
                                      : showIncorrect
                                          ? Icons.cancel
                                          : isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                  color: showCorrect
                                      ? Colors.green
                                      : showIncorrect
                                          ? Colors.red
                                          : isSelected
                                              ? Colors.blue
                                              : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.textoOpcion,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                  // Feedback text after answer submission (general)
                  if (_isAnswerSubmitted &&
                      (question.explicacionGeneral != null && question.explicacionGeneral!.trim().isNotEmpty))
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.explicacionGeneral!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Open text answer
                  if (question.isOpenText)
                    TextField(
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu respuesta aquí...',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isAnswerSubmitted,
                    ),

                  // Audio response
                  if (question.isAudioResponse)
                    AudioRecorderWidget(
                      userId: widget.userId.toString(),
                      maxDurationSeconds: question.tiempoLimiteSegundos,
                      autoUpload: true,
                      onRecordingComplete: (path) {
                        // Local path saved
                      },
                      onUploadComplete: (firebaseUrl) {
                        setState(() {
                          _audioUrl = firebaseUrl;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed:
                      _currentQuestionIndex > 0 && !_isAnswerSubmitted
                          ? _previousQuestion
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Anterior'),
                ),
                if (!_isAnswerSubmitted)
                  ElevatedButton(
                    onPressed: _selectedOptionId != null ||
                            question.isOpenText ||
                            (question.isAudioResponse && _audioUrl != null)
                        ? _submitAnswer
                        : null,
                    child: const Text('Enviar'),
                  )
                else
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentQuestionIndex < widget.questions.length - 1
                          ? 'Siguiente'
                          : 'Finalizar',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
