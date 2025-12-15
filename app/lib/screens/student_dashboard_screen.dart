import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_student_service.dart';
import '../config/supabase_config.dart';
import 'progress_dashboard_screen.dart';
import 'courses_list_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

/// Pantalla principal del panel de control para estudiantes.
///
/// Este widget `Stateful` muestra un resumen del progreso del estudiante,
/// sus cursos y accesos directos a las funcionalidades más importantes.
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _studentStats;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  /// Carga los datos del estudiante, incluyendo perfil y estadísticas.
  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      int? userId = authProvider.user?.idUsuario;

      if (userId == null) {
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          final data = await supabase
              .from('usuarios')
              .select('id_usuario')
              .eq('supabase_uid', currentUser.id)
              .single();
          userId = data['id_usuario'] as int?;
        }
      }

      if (userId == null) {
        throw Exception('Usuario no autenticado.');
      }

      _studentData = await SupabaseStudentService.getStudentByUserId(userId);
      if (_studentData != null) {
        _studentStats = await SupabaseStudentService.getStudentStats(userId);
      } else {
        throw Exception('No se encontró información del estudiante.');
      }
    } catch (e) {
      _errorMessage = 'Error al cargar datos: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Cierra la sesión del usuario y lo redirige a la pantalla de login.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia todos los datos de SharedPreferences

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF23408E)))
            : _errorMessage != null
                ? _buildErrorView()
                : RefreshIndicator(
                    onRefresh: _loadStudentData,
                    color: const Color(0xFF23408E),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStudentHeader(context),
                          const SizedBox(height: 32),
                          _buildModulesSection(context),
                          const SizedBox(height: 32),
                          _buildStatsSection(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  /// Construye el encabezado con el nombre del estudiante y el botón de logout.
  Widget _buildStudentHeader(BuildContext context) {
    final studentName = _studentData?['nombre_completo'] ?? 'Estudiante';

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "¡Hola de nuevo!",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  studentName,
                  style: GoogleFonts.ptSans(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF23408E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            offset: const Offset(0, 60),
            icon: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE8EAF6),
              backgroundImage: AssetImage('assets/images/avatar.png'),
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
          ),
        ],
      ),
    );
  }

  /// Construye la sección de "Módulos de Aprendizaje".
  Widget _buildModulesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Módulos de Aprendizaje'),
        const SizedBox(height: 16),
        _moduleTile(
          title: 'Mis Cursos',
          subtitle: 'Explorar y continuar cursos',
          icon: Icons.school_rounded,
          color: const Color(0xFF23408E),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CoursesListScreen()));
          },
        ),
        const SizedBox(height: 12),
        _moduleTile(
          title: 'Mi Progreso',
          subtitle: 'Ver estadísticas y avances',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF23408E),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressDashboardScreen()));
          },
        ),
        const SizedBox(height: 12),
        _moduleTile(
          title: 'Notificaciones',
          subtitle: 'Revisar retroalimentación',
          icon: Icons.notifications_rounded,
          color: const Color(0xFF23408E),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
          },
        ),
      ],
    );
  }

  /// Construye la sección de "Estadísticas Rápidas".
  Widget _buildStatsSection() {
    if (_studentStats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Estadísticas Rápidas'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statCard('Puntos Totales', _studentStats!['total_puntos']?.toString() ?? '0', Icons.star_rounded),
            _statCard('Cursos Iniciados', _studentStats!['cursos_iniciados']?.toString() ?? '0', Icons.book_rounded),
            _statCard('Feedback Recibido', _studentStats!['retroalimentaciones_recibidas']?.toString() ?? '0', Icons.feedback_rounded),
          ],
        ),
      ],
    );
  }

  /// Helper para construir los títulos de las secciones.
  Widget _buildSectionTitle(String title) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        decoration: BoxDecoration(
          color: const Color(0xFF23408E),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          title,
          style: GoogleFonts.ptSans(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  /// Helper para construir las tarjetas de los módulos.
  Widget _moduleTile({
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
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Helper para construir las tarjetas de estadísticas.
  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF23408E)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF23408E))),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la vista de error.
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStudentData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23408E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
