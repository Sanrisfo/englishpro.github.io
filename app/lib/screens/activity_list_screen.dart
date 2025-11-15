import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'activity_player_screen.dart';

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

  @override
  void initState() {
    super.initState();
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
          .select('id_cuestionario, titulo, tiempo_limite_minutos, tipo_evaluacion, activo')
          .eq('id_tipo_actividad', widget.activityTypeId)
          .eq('activo', true)
          .order('id_cuestionario');
      _quizzes = List<Map<String, dynamic>>.from(qs as List);
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseName} > ${widget.skillName} > ${widget.activityTypeName}'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Actividades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_quizzes.isEmpty)
                        const Text('Aún no hay actividades para esta habilidad')
                      else
                        ..._quizzes.map((q) {
                          final title = q['titulo'] as String? ?? 'Actividad';
                          final tipo = q['tipo_evaluacion'] as String? ?? '';
                          final minutos = q['tiempo_limite_minutos'] as int?;
                          final quizId = q['id_cuestionario'] as int;
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.assignment, color: Colors.deepPurple),
                              title: Text(title),
                              subtitle: Text(minutos != null ? 'Tipo: $tipo · Tiempo: $minutos min' : 'Tipo: $tipo'),
                              onTap: () {
                                final user = context.read<AuthProvider>().user;
                                final userId = user?.idUsuario;
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Debes iniciar sesión para realizar la actividad')),
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
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

