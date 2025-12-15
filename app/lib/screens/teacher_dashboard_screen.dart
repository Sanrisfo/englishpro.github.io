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

/// Pantalla principal del panel de control para docentes.
///
/// Este widget `Stateful` actúa como el centro de operaciones para los usuarios
/// con rol de docente, mostrando métricas clave, acciones rápidas y
/// notificaciones sobre tareas pendientes.
class TeacherDashboardScreen extends StatefulWidget {
  /// Crea una instancia de la pantalla del panel de control del docente.
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  /// Indica si los datos se están cargando.
  bool _isLoading = true;

  /// Almacena los datos del perfil del docente.
  Map<String, dynamic>? _teacherData;

  /// Almacena las estadísticas del docente (calificaciones, pendientes, etc.).
  Map<String, dynamic>? _teacherStats;

  /// Lista de retroalimentaciones pendientes de revisión.
  List<dynamic> _pendingFeedbacks = [];

  /// Mensaje de error a mostrar si la carga de datos falla.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  /// Carga todos los datos necesarios para el panel del docente.
  ///
  /// Obtiene el ID del usuario del [AuthProvider] y lo utiliza para
  /// obtener el perfil del docente, sus estadísticas y la lista de
  /// revisiones pendientes a través de [SupabaseTeacherService].
  /// Maneja los estados de carga y error.
  Future<void> _loadTeacherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      int? userId = authProvider.user?.idUsuario;

      // Fallback: recupera el userId de la sesión de Supabase si el provider está vacío.
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
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Cierra la sesión del usuario.
  ///
  /// Limpia los datos de sesión de `SharedPreferences` y navega a la
  /// [LoginScreen], eliminando todas las rutas anteriores.
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
                _buildTeacherHeader(context, textTheme),
                const SizedBox(height: 32),
                _buildModulesSection(context, textTheme),
                const SizedBox(height: 32),
                _buildStatsSection(textTheme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el encabezado de la pantalla con el saludo y el avatar del docente.
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
                "¡Bienvenido!",
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Docente",
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
            color: const Color(0xFFFBFBFB),
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
                    Text("Cerrar Sesión", style: TextStyle(color: Color(0xFFD9232A))),
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

  /// Construye la sección de "Módulos de Control" con accesos directos.
  Widget _buildModulesSection(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
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
              'Módulos de Control',
              style: GoogleFonts.ptSans(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _skillTile(
          title: 'Mis Cursos',
          subtitle: 'Gestionar módulos y materiales',
          icon: Icons.dashboard_customize_rounded,
          color: const Color(0xFFD9232A),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherCoursesScreen()));
          },
        ),
        const SizedBox(height: 12),
        _skillTile(
          title: 'Revisión Manual',
          subtitle: 'Ver envíos pendientes',
          icon: Icons.remove_red_eye_rounded,
          color: const Color(0xFFD9232A),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingReviewsScreen()));
          },
        ),
        const SizedBox(height: 12),
        _skillTile(
          title: 'Lista de Estudiantes',
          subtitle: 'Ver lista y progreso de estudiantes',
          icon: Icons.group_rounded,
          color: const Color(0xFFD9232A),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentRosterScreen()));
          },
        ),
      ],
    );
  }

  /// Construye la sección de estadísticas del docente con barras de progreso.
  Widget _buildStatsSection(TextTheme textTheme) {
    if (_teacherStats == null) return const SizedBox.shrink();

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
              'Estadísticas',
              style: GoogleFonts.ptSans(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStatProgressBar(
          label: 'Pendientes',
          value: pendientes.toString(),
          percentage: pendientesPct,
          color: const Color(0xFFD9232A),
          textTheme: textTheme,
        ),
        const SizedBox(height: 16),
        _buildStatProgressBar(
          label: 'Calificadas',
          value: calificadas.toString(),
          percentage: calificadasPct,
          color: const Color(0xFF23408E),
          textTheme: textTheme,
        ),
        const SizedBox(height: 16),
        _buildStatProgressBar(
          label: 'Promedio',
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

  /// Construye una barra de progreso individual para una estadística.
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

  /// Construye una tarjeta de navegación para las secciones del panel.
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

  /// Construye la vista de error que se muestra cuando falla la carga de datos.
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

  /// Formatea una fecha para mostrar el tiempo transcurrido.
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

  /// Navega a la pantalla de calificación manual.
  void _navigateToGrading(Map<String, dynamic> feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualGradingScreen(feedback: feedback),
      ),
    ).then((_) => _loadTeacherData());
  }
}