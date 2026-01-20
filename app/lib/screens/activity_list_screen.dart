import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Asegúrate de tener esto importado
import '../config/supabase_config.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'activity_player_screen.dart';

/// Lista de cuestionarios disponibles para un tipo de actividad.
class ActivityListScreen extends StatefulWidget {
  final int skillId;
  final int activityTypeId;
  final String skillName;
  final String courseName;
  final String activityTypeName;

  const ActivityListScreen({
    super.key,
    required this.skillId,
    required this.activityTypeId,
    required this.skillName,
    required this.courseName,
    required this.activityTypeName,
  });

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _quizzes = [];
  late final Color _courseColor;

  @override
  void initState() {
    super.initState();
    _courseColor = _getCourseColor(widget.courseName);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final qs = await supabase
          .from('cuestionarios')
          .select(
            'id_cuestionario, titulo, tiempo_limite_minutos, tipo_evaluacion, activo, descripcion',
          ) // Agregué descripción
          .eq('id_tipo_actividad', widget.activityTypeId)
          .eq('activo', true)
          .order('id_cuestionario', ascending: true);
      _quizzes = List<Map<String, dynamic>>.from(qs as List);
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) return const Color(0xFFD9232A);
    if (lower.contains('ielts')) return const Color(0xFF23408E);
    if (lower.contains('business')) return const Color(0xFFB02224);
    return const Color(0xFF1F3A89);
  }

  @override
  Widget build(BuildContext context) {
    final String breadcrumb =
        '... > ${widget.skillName} > ${widget.activityTypeName}';

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: const Color(0xFFD9232A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_back_ios_new),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: _courseColor,
                  strokeWidth: 5.0,
                ),
              )
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ENCABEZADO ESTÁNDAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/images/logo_completo.png',
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40.0,
                                vertical: 0.0,
                              ),
                              decoration: BoxDecoration(
                                color: _courseColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                widget.activityTypeName,
                                style: GoogleFonts.ptSans(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          breadcrumb,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // lista de actividades
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      color: _courseColor,
                      child: Builder(
                        builder: (context) {
                          final user = context.read<AuthProvider>().user;
                          final planId = user?.idPlan ?? 1;

                          // Premium plan has no limit
                          final isPremium = planId == 4;

                          int limit;
                          if (isPremium) {
                            limit = _quizzes.length; // No limit
                          } else if (planId <= 1) {
                            limit = 1; // Freemium
                          } else if (planId == 2) {
                            limit = 3; // Básico
                          } else {
                            limit = 5; // Pro
                          }
                          final display = _quizzes;
                          if (display.isEmpty) {
                            return const Center(
                              child: Text('No activities found yet'),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 0,
                              bottom: 100,
                            ),
                            itemCount: display.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final q = display[index];
                              final locked = !isPremium && index >= limit;
                              return _buildActivityTile(q, locked: locked);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  //Tarjeta
  Widget _buildActivityTile(Map<String, dynamic> q, {bool locked = false}) {
    final title = q['titulo'] as String? ?? 'Actividad';
    final tipo = q['tipo_evaluacion'] as String? ?? '—';
    final minutos = q['tiempo_limite_minutos'] as int?;
    final quizId = q['id_cuestionario'] as int;
    final desc = q['descripcion'] as String? ?? '';

    return InkWell(
      onTap: () {
        if (locked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Actividad bloqueada por tu plan. Actualiza para acceder.',
              ),
            ),
          );
          return;
        }
        final user = context.read<AuthProvider>().user;
        final userId = user?.idUsuario;
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes iniciar sesión para realizar la actividad'),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityPlayerScreen(
              quizId: quizId,
              skillId: widget.skillId,
              skillName: widget.skillName,
              quizTitle: title,
            ),
          ),
        );
      },
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
            // Ícono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _courseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.assignment_outlined,
                color: _courseColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Textos
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
                  // Subtítulos
                  Text(
                    "Type: $tipo" +
                        (minutos != null ? "  •  Time: $minutos min" : ""),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (desc.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Flecha a la derecha
            locked
                ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
          ],
        ),
      ),
    );
  }
}