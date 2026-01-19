import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuizResultsScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int totalScore;
  final int maxScore;
  final double percentage;
  final List<QuestionModel> questions;
  final Map<int, dynamic> userAnswers;

  const QuizResultsScreen({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPassingGrade = percentage >= 70;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados del Quiz'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      isPassingGrade ? Icons.emoji_events : Icons.info_outline,
                      size: 80,
                      color: isPassingGrade ? Colors.amber : Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPassingGrade ? 'Aprobado' : 'Sigue Practicando',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isPassingGrade ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStatRow(
                      'Porcentaje',
                      '${percentage.toStringAsFixed(1)}%',
                      Icons.percent,
                      isPassingGrade ? Colors.green : Colors.orange,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      'Puntaje',
                      '$totalScore / $maxScore',
                      Icons.stars,
                      Colors.blue,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      'Correctas',
                      '$correctAnswers / $totalQuestions',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      'Incorrectas',
                      '${totalQuestions - correctAnswers} / $totalQuestions',
                      Icons.cancel,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Review Section Header
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Revisión de Preguntas',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Questions Review
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionReview(context, question, index + 1);
            }).toList(),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Volver al Inicio'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Retry quiz
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReview(
    BuildContext context,
    QuestionModel question,
    int questionNumber,
  ) {
    final userAnswer = userAnswers[question.id];
    final correctOption = question.opciones?.firstWhere(
      (opt) => opt.esCorrecta,
      orElse: () => question.opciones!.first,
    );
    final isCorrect = userAnswer == correctOption?.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pregunta $questionNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${question.puntaje} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.textoPregunta,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            // Answer Options
            if (question.isMultipleChoice && question.opciones != null)
              ...question.opciones!.map((option) {
                final isUserAnswer = userAnswer == option.id;
                final isCorrectOption = option.esCorrecta;

                Color? backgroundColor;
                Color? borderColor;
                IconData? icon;

                if (isCorrectOption) {
                  backgroundColor = Colors.green.withOpacity(0.2);
                  borderColor = Colors.green;
                  icon = Icons.check_circle;
                } else if (isUserAnswer && !isCorrect) {
                  backgroundColor = Colors.red.withOpacity(0.2);
                  borderColor = Colors.red;
                  icon = Icons.cancel;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor ?? Colors.grey.withOpacity(0.3),
                      width: borderColor != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null)
                        Icon(icon, color: borderColor, size: 20),
                      if (icon != null) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option.textoOpcion,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCorrectOption || isUserAnswer
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

            // Explanation
            if (correctOption?.explicacion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        correctOption!.explicacion!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
