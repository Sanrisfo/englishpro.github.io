import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_teacher_service.dart';
import '../config/supabase_config.dart';
import 'manual_grading_screen.dart';
import 'teacher_materials_screen.dart';
import 'pending_reviews_screen.dart';
import 'student_roster_screen.dart';
import 'teacher_courses_screen.dart';
import 'login_screen.dart';

/// Panel principal para docentes: métricas, acciones rápidas y pendientes.
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

  /// Carga datos del docente, estadísticas y pendientes desde Supabase.
  Future<void> _loadTeacherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      int? userId = authProvider.user?.idUsuario;

      // Fallback: recover userId from Supabase session if provider is empty
      if (userId == null) {
        try {
          final current = supabase.auth.currentUser;
          if (current != null) {
            final data = await supabase
                .from('usuarios')
                .select('id_usuario, es_docente, rol')
                .eq('supabase_uid', current.id)
                .single();
            userId = data['id_usuario'] as int?;

            final isTeacher = (data['es_docente'] as bool?) ?? false;
            if (userId == null) {
              setState(() {
                _errorMessage = 'Usuario no autenticado';
                _isLoading = false;
              });
              return;
            }
            if (!isTeacher) {
              setState(() {
                _errorMessage = 'Este usuario no es docente';
                _isLoading = false;
              });
              return;
            }
          }
        } catch (_) {}
      }
      if (userId == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
        return;
      }

      final teacherData = await SupabaseTeacherService.getTeacherByUserId(userId);

      if (teacherData != null) {
        _teacherData = teacherData;
        final teacherId = _teacherData!['id_docente'] as int;

        _teacherStats = await SupabaseTeacherService.getTeacherStats(teacherId);
        _pendingFeedbacks = await SupabaseTeacherService.getPendingFeedbacks();
      } else {
        _errorMessage = 'No se encontró información de docente para este usuario. '
            'Por favor contacte al administrador para que lo registre como docente.';
      }
    } catch (e) {
      _errorMessage = 'Error al cargar datos: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Cierra sesión y retorna a la pantalla de login.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_is_teacher');

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFD9232A),
            strokeWidth: 5.0,
          ),
        )
            : _errorMessage != null
            ? _buildErrorView()
            : RefreshIndicator(
          onRefresh: _loadTeacherData,
          color: const Color(0xFFD9232A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado (saludo y burbuja)
                _buildTeacherHeader(context, textTheme),
                const SizedBox(height: 32),

                // Modulos
                _buildModulesSection(context, textTheme),
                const SizedBox(height: 32),

                // --- SECCIÓN "MY MATERIALS" COMENTADA PARA V1 ---
                /*
                          // Acciones rapidas
                          _buildQuickActionsSection(context, textTheme),
                          const SizedBox(height: 32),
                          */
                // -----------------------------------------------

                // Estadisticas
                _buildStatsSection(textTheme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Encabezado (saludo y burbuja)
  Widget _buildTeacherHeader(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¡Welcome!",
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Teacher",
                style: GoogleFonts.ptSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD9232A),
                ),
              ),
            ],
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            offset: const Offset(0, 60),
            color: Color(0xFFFBFBFB),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Color(0xFFD9232A)),
                    SizedBox(width: 8),
                    Text("Sign Out", style: TextStyle(color: Color(0xFFD9232A))),
                  ],
                ),
              ),
            ],
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFF9E8E8),
              backgroundImage: AssetImage('assets/images/avatar_teacher.png'),
            ),
          ),
        ],
      ),
    );
  }

  // Modulos
  Widget _buildModulesSection(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Barra
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 0.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD9232A),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              'Control measures',
              style: GoogleFonts.ptSans(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),

        //Tarjetas
        const SizedBox(height: 16),
        _skillTile(
          title: 'My courses',
          subtitle: 'Manage modules and materials',
          icon: Icons.dashboard_customize_rounded,
          color: const Color(0xFFD9232A),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherCoursesScreen()));
          },
        ),
        const SizedBox(height: 12),
        _skillTile(
          title: 'Manual review',
          subtitle: 'View pending submissions',
          icon: Icons.remove_red_eye_rounded,
          color: const Color(0xFFD9232A),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingReviewsScreen()));
          },
        ),
        const SizedBox(height: 12),
        _skillTile(
          title: 'Student roster',
          subtitle: 'View student list and progress',
          icon: Icons.group_rounded,
          color: const Color(0xFFD9232A),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentRosterScreen()));
          },
        ),
      ],
    );
  }

  // Acciones rapidas (Mantenemos la función por si se reactiva en V2, pero no se llama)
  Widget _buildQuickActionsSection(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Barra
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 0.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD9232A),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              'Quick actions',
              style: GoogleFonts.ptSans(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),

        // Pestaña
        const SizedBox(height: 16),
        _skillTile(
          title: 'My materials',
          subtitle: 'Manage files and resources',
          icon: Icons.folder_copy,
          color: const Color(0xFFD9232A),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherMaterialsScreen()));
          },
        ),
      ],
    );
  }

  // stats
  Widget _buildStatsSection(TextTheme textTheme) {
    if (_teacherStats == null) return const SizedBox.shrink();

    // Obtenemos los valores de las estadísticas
    final int total = _teacherStats!['total_calificaciones'] ?? 0;
    final int calificadas = _teacherStats!['calificadas'] ?? 0;
    final int pendientes = _teacherStats!['pendientes'] ?? 0;
    final double promedio = (_teacherStats!['promedio_puntuacion'] ?? 0.0).toDouble();

    final double calificadasPct = (total == 0) ? 0.0 : calificadas / total;
    final double pendientesPct = (total == 0) ? 0.0 : pendientes / total;
    final double promedioPct = (promedio == 0) ? 0.0 : promedio / 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 85.0,
              vertical: 0.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD9232A),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              'Stats',
              style: GoogleFonts.ptSans(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Barras de progreso
        _buildStatProgressBar(
          label: 'Pending',
          value: pendientes.toString(),
          percentage: pendientesPct,
          color: const Color(0xFFD9232A),
          textTheme: textTheme,
        ),
        const SizedBox(height: 16),
        _buildStatProgressBar(
          label: 'Graded',
          value: calificadas.toString(),
          percentage: calificadasPct,
          color: const Color(0xFF23408E),
          textTheme: textTheme,
        ),
        const SizedBox(height: 16),
        _buildStatProgressBar(
          label: 'Average',
          value: promedio.toStringAsFixed(1),
          percentage: promedioPct,
          color: const Color(0xFFD9232A),
          textTheme: textTheme,
        ),
        const SizedBox(height: 16),
        _buildStatProgressBar(
          label: 'Total',
          value: total.toString(),
          percentage: 1.0,
          color: const Color(0xFF23408E),
          textTheme: textTheme,
        ),
      ],
    );
  }

  Widget _buildStatProgressBar({
    required String label,
    required String value,
    required double percentage,
    required Color color,
    required TextTheme textTheme,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percentage.isNaN ? 0.0 : percentage),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, animatedPercentage, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: animatedPercentage,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _skillTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9232A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
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
    ).then((_) => _loadTeacherData());
  }
}