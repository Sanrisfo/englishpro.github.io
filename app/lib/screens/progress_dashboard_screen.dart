import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  Map<String, dynamic>? userStats;
  List<dynamic>? userProgress;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.idUsuario;

    if (userId == null) {
      setState(() {
        errorMessage = 'Usuario no autenticado';
        isLoading = false;
      });
      return;
    }

    try {
      // Cargar estadísticas y progreso en paralelo
      final results = await Future.wait([
        ApiService.getUserStats(userId),
        ApiService.getUserProgress(userId),
      ]);

      final statsResult = results[0];
      final progressResult = results[1];

      if (statsResult['success'] == true && progressResult['success'] == true) {
        setState(() {
          userStats = statsResult['stats'];
          userProgress = progressResult['progress'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = statsResult['message'] ?? progressResult['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar datos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(errorMessage!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _loadDashboardData();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsOverview(),
                        const SizedBox(height: 24),
                        _buildAccuracyChart(),
                        const SizedBox(height: 24),
                        _buildCoursesProgress(),
                        const SizedBox(height: 24),
                        _buildPointsChart(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatsOverview() {
    if (userStats == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.stars,
                  label: 'Puntos',
                  value: '${userStats!['totalPoints'] ?? 0}',
                  color: Colors.amber,
                ),
                _buildStatItem(
                  icon: Icons.quiz,
                  label: 'Preguntas',
                  value: '${userStats!['totalQuestionsAnswered'] ?? 0}',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Correctas',
                  value: '${userStats!['totalCorrectAnswers'] ?? 0}',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.school,
                  label: 'Cursos Iniciados',
                  value: '${userStats!['coursesStarted'] ?? 0}',
                  color: Colors.purple,
                ),
                _buildStatItem(
                  icon: Icons.done_all,
                  label: 'Cursos Completados',
                  value: '${userStats!['coursesCompleted'] ?? 0}',
                  color: Colors.teal,
                ),
                _buildStatItem(
                  icon: Icons.assignment_turned_in,
                  label: 'Cuestionarios',
                  value: '${userStats!['quizzesCompleted'] ?? 0}',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAccuracyChart() {
    if (userStats == null) return const SizedBox.shrink();

    final accuracy = (userStats!['accuracyPercentage'] ?? 0.0) as num;
    final accuracyDouble = accuracy.toDouble();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Precisión General',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      value: accuracyDouble,
                      title: '${accuracyDouble.toStringAsFixed(1)}%',
                      color: Colors.green,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 100 - accuracyDouble,
                      title: '${(100 - accuracyDouble).toStringAsFixed(1)}%',
                      color: Colors.red.withOpacity(0.3),
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Correctas', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('Incorrectas', Colors.red.withOpacity(0.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildCoursesProgress() {
    if (userProgress == null || userProgress!.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.info_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No hay progreso registrado',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso por Curso',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...userProgress!.map((progress) => _buildCourseProgressItem(progress)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgressItem(Map<String, dynamic> progress) {
    final courseId = progress['courseId'] ?? 0;
    final progressPercentage = (progress['progressPercentage'] ?? 0.0) as num;
    final totalPoints = progress['totalPoints'] ?? 0;
    final questionsAnswered = progress['questionsAnswered'] ?? 0;
    final correctAnswers = progress['correctAnswers'] ?? 0;

    // Nombres de cursos (deberías obtenerlos del backend o tenerlos mapeados)
    final courseNames = {
      1: 'TOEFL Preparation',
      2: 'IELTS Preparation',
      3: 'Business English',
      4: 'English in Action',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                courseNames[courseId] ?? 'Curso $courseId',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage.toDouble() / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$questionsAnswered preguntas | $correctAnswers correctas',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '$totalPoints pts',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsChart() {
    if (userProgress == null || userProgress!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Nombres de cursos
    final courseNames = {
      1: 'TOEFL',
      2: 'IELTS',
      3: 'Business',
      4: 'Action',
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Puntos por Curso',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxPoints() * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final progress = userProgress![groupIndex];
                        final courseId = progress['courseId'] ?? 0;
                        return BarTooltipItem(
                          '${courseNames[courseId]}\n${rod.toY.toInt()} pts',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= userProgress!.length) {
                            return const SizedBox.shrink();
                          }
                          final progress = userProgress![value.toInt()];
                          final courseId = progress['courseId'] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              courseNames[courseId] ?? 'C$courseId',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return userProgress!.asMap().entries.map((entry) {
      final index = entry.key;
      final progress = entry.value;
      final points = (progress['totalPoints'] ?? 0).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: points,
            color: const Color(0xFF6366F1),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxPoints() {
    if (userProgress == null || userProgress!.isEmpty) return 100;

    double max = 0;
    for (var progress in userProgress!) {
      final points = (progress['totalPoints'] ?? 0).toDouble();
      if (points > max) max = points;
    }
    return max > 0 ? max : 100;
  }
}
