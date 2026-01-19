import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/supabase_config.dart';
import '../models/material_model.dart';
import '../widgets/pdf_viewer_widget.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'activity_player_screen.dart';
import 'package:audioplayers/audioplayers.dart';

/// Materiales y actividades disponibles para una habilidad concreta.
class SkillMaterialsScreen extends StatefulWidget {
  final int skillId;
  final String skillName;
  final String courseName;
  final int? activityTypeId;
  final String? activityTypeName;

  const SkillMaterialsScreen({
    Key? key,
    required this.skillId,
    required this.skillName,
    required this.courseName,
    this.activityTypeId,
    this.activityTypeName,
  }) : super(key: key);

  @override
  State<SkillMaterialsScreen> createState() => _SkillMaterialsScreenState();
}

class _SkillMaterialsScreenState extends State<SkillMaterialsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<MaterialModel> _materials = [];
  List<Map<String, dynamic>> _quizzes = [];
  final _audioPlayer = AudioPlayer();

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
      final materialsRes = await ApiService.getMaterialsBySkill(widget.skillId);
      if (materialsRes['success'] == true) {
        _materials = (materialsRes['materials'] as List<MaterialModel>);
      } else {
        _errorMessage =
            materialsRes['message'] ?? 'No se pudieron cargar los materiales';
      }

      // Cargar actividades (cuestionarios) filtradas por tipo si aplica
      try {
        final base = supabase
            .from('cuestionarios')
            .select(
              'id_cuestionario, titulo, tiempo_limite_minutos, tipo_evaluacion, activo',
            );
        dynamic result;
        if (widget.activityTypeId != null) {
          result = await base
              .eq('id_tipo_actividad', widget.activityTypeId!)
              .eq('activo', true)
              .order('id_cuestionario');
        } else {
          result = await base
              .eq('id_habilidad', widget.skillId)
              .eq('activo', true)
              .order('id_cuestionario');
        }
        _quizzes = List<Map<String, dynamic>>.from(result as List);
      } catch (e) {
        // no bloquea la carga si falla solo actividades
      }

      setState(() {});
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  IconData _iconFor(MaterialModel m) {
    final t = m.tipoMaterial.toLowerCase();
    if (t == 'pdf') return Icons.picture_as_pdf;
    if (t == 'video') return Icons.video_library;
    if (t == 'audio') return Icons.audiotrack;
    if (t == 'text' || t == 'texto') return Icons.article;
    if (t == 'image' || t == 'imagen') return Icons.image;
    return Icons.description;
  }

  Future<void> _openMaterial(MaterialModel m) async {
    final t = m.tipoMaterial.toLowerCase();
    if (t == 'pdf' && (m.archivoUrl?.isNotEmpty ?? false)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PDFViewerWidget(pdfUrl: m.archivoUrl!, title: m.titulo),
        ),
      );
      return;
    }
    if ((t == 'image' || t == 'imagen') &&
        (m.archivoUrl?.isNotEmpty ?? false)) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: InteractiveViewer(
            child: Image.network(m.archivoUrl!, fit: BoxFit.contain),
          ),
        ),
      );
      return;
    }
    if (t == 'audio' && (m.archivoUrl?.isNotEmpty ?? false)) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(m.archivoUrl!));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reproduciendo audio: ${m.titulo}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo reproducir el audio: $e')),
        );
      }
      return;
    }
    if (t == 'text' || t == 'texto') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(m.titulo),
          content: SingleChildScrollView(child: Text(m.contenidoTexto ?? '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tipo de material no soportado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activityTypeName != null
              ? '${widget.courseName} > ${widget.skillName} > ${widget.activityTypeName}'
              : '${widget.courseName} > ${widget.skillName}',
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
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
                  const Text(
                    'Materiales',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_materials.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text('Aún no hay materiales para esta habilidad'),
                    )
                  else
                    ..._materials.map(
                      (m) => Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(_iconFor(m), color: Colors.indigo),
                          title: Text(m.titulo),
                          subtitle: Text(m.tipoMaterial),
                          onTap: () => _openMaterial(m),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Text(
                    'Actividades',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.assignment,
                            color: Colors.deepPurple,
                          ),
                          title: Text(title),
                          subtitle: Text(
                            minutos != null
                                ? 'Tipo: $tipo â€¢ Tiempo: $minutos min'
                                : 'Tipo: $tipo',
                          ),
                          onTap: () {
                            final user = context.read<AuthProvider>().user;
                            final userId = user?.idUsuario;
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Debes iniciar sesiÃ³n para realizar la actividad',
                                  ),
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
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
