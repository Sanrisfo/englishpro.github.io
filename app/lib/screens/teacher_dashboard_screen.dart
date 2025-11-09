import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_teacher_service.dart';
import 'manual_grading_screen.dart';
import 'teacher_materials_screen.dart';
import 'pending_reviews_screen.dart';
import 'student_roster_screen.dart';
import 'teacher_courses_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _teacherData;
  Map<String, dynamic>? _teacherStats;
  List<dynamic> _pendingFeedbacks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.idUsuario;

      // Debug: check what we have in provider
      print('DEBUG TeacherDashboard: user = ${authProvider.user}, userId = $userId');
      if (authProvider.user != null) {
        print('DEBUG TeacherDashboard: user.idUsuario = ${authProvider.user!.idUsuario}, user.rol = ${authProvider.user!.rol}');
      }

      if (userId == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
        return;
      }

      // Get teacher info from Supabase
      final teacherData = await SupabaseTeacherService.getTeacherByUserId(userId);

      if (teacherData != null) {
        _teacherData = teacherData;
        final teacherId = _teacherData!['id_docente'] as int;

        print('DEBUG TeacherDashboard: Found teacher with ID $teacherId');

        // Get teacher stats
        _teacherStats = await SupabaseTeacherService.getTeacherStats(teacherId);
        print('DEBUG TeacherDashboard: Stats = $_teacherStats');

        // Get pending feedbacks
        _pendingFeedbacks = await SupabaseTeacherService.getPendingFeedbacks();
        print('DEBUG TeacherDashboard: Pending feedbacks count = ${_pendingFeedbacks.length}');
      } else {
        _errorMessage = 'No se encontró información de docente para este usuario. '
            'Por favor contacte al administrador para que lo registre como docente.';
      }
    } catch (e) {
      print('ERROR TeacherDashboard: $e');
      _errorMessage = 'Error al cargar datos: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Docente'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeacherData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTeacherData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTeacherData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeCard(user?.nombreCompleto ?? 'Docente'),
                        const SizedBox(height: 20),
                        _buildModulesGrid(context),
                        const SizedBox(height: 20),
                        _buildStatsCards(),
                        const SizedBox(height: 20),
                        _buildQuickActionsCard(),
                        const SizedBox(height: 20),
                        _buildPendingFeedbacksSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildModulesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Módulos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildModuleTile(
              context,
              title: 'Módulos',
              icon: Icons.dashboard_customize,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherCoursesScreen(),
                  ),
                );
              },
            ),
            _buildModuleTile(
              context,
              title: 'Revisión',
              icon: Icons.rate_review,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingReviewsScreen(),
                  ),
                );
              },
            ),
            _buildModuleTile(
              context,
              title: 'Control de Estudiantes',
              icon: Icons.group,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentRosterScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.school, size: 48, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, $name',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _teacherData?['especialidad'] ?? 'Docente',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
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

  Widget _buildStatsCards() {
    if (_teacherStats == null) {
      return const SizedBox.shrink();
    }

    final totalCalificaciones = _teacherStats!['total_calificaciones'] ?? 0;
    final calificadas = _teacherStats!['calificadas'] ?? 0;
    final pendientes = _teacherStats!['pendientes'] ?? 0;
    final promedioPuntuacion = (_teacherStats!['promedio_puntuacion'] ?? 0.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                totalCalificaciones.toString(),
                Icons.assignment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Calificadas',
                calificadas.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pendientes',
                pendientes.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Promedio',
                promedioPuntuacion.toStringAsFixed(1),
                Icons.star,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeacherMaterialsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.folder),
                    label: const Text('Mis Materiales'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingFeedbacksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Respuestas Pendientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_pendingFeedbacks.isNotEmpty)
              Chip(
                label: Text('${_pendingFeedbacks.length}'),
                backgroundColor: Colors.orange,
                labelStyle: const TextStyle(color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _pendingFeedbacks.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay respuestas pendientes',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pendingFeedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = _pendingFeedbacks[index] as Map<String, dynamic>;
                  return _buildFeedbackCard(feedback);
                },
              ),
      ],
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    final tipoRespuesta = feedback['tipo_respuesta'] as String?;
    final fechaRespuesta = feedback['fecha_respuesta'] as String?;
    final usuarioId = feedback['id_usuario'] as int?;
    final preguntaId = feedback['id_pregunta'] as int?;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToGrading(feedback),
        borderRadius: BorderRadius.circular(12),
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
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pregunta #$preguntaId',
                      style: const TextStyle(
                        fontSize: 16,
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
                    if (fechaRespuesta != null)
                      Text(
                        'Enviado: ${_formatDate(fechaRespuesta)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Ahora';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _navigateToGrading(Map<String, dynamic> feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualGradingScreen(feedback: feedback),
      ),
    ).then((_) => _loadTeacherData()); // Reload data after grading
  }
}
