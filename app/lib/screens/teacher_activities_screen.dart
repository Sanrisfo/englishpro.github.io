import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/supabase_config.dart';
import '../services/supabase_storage_service.dart';
import '../services/api_service.dart';
import 'teacher_questions_screen.dart';
import 'teacher_modules_screen.dart';

class TeacherActivitiesScreen extends StatefulWidget {
  final int skillId;
  final String skillName;
  final String courseName;
  final int? activityTypeId;
  final String? activityTypeName;

  const TeacherActivitiesScreen({
    Key? key,
    required this.skillId,
    required this.skillName,
    required this.courseName,
    this.activityTypeId,
    this.activityTypeName,
  }) : super(key: key);

  @override
  State<TeacherActivitiesScreen> createState() => _TeacherActivitiesScreenState();
}

class _TeacherActivitiesScreenState extends State<TeacherActivitiesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _modules = [];

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
      var query = supabase
          .from('cuestionarios')
          .select('id_cuestionario, titulo, descripcion, tiempo_limite_minutos, tipo_evaluacion, activo');
      if (widget.activityTypeId != null) {
        query = query.eq('id_tipo_actividad', widget.activityTypeId!);
      } else {
        query = query.eq('id_habilidad', widget.skillId);
      }
      final response = await query.eq('activo', true).order('id_cuestionario');
      setState(() => _quizzes = List<Map<String, dynamic>>.from(response as List));
      // Load modules for this skill
      try {
        final ms = await supabase
            .from('modulos')
            .select('id_modulo, nombre_modulo, orden, activo')
            .eq('id_habilidad', widget.skillId)
            .eq('activo', true)
            .order('orden', ascending: true);
        _modules = List<Map<String, dynamic>>.from(ms as List);
      } catch (_) {}
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando actividades: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createQuizDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    String tipo = 'Practica';
    int? selectedModuleId = _modules.isNotEmpty ? _modules.first['id_modulo'] as int : null;

    // Material opcional
    bool addMaterial = false;
    final materialTitleCtrl = TextEditingController();
    final materialTextCtrl = TextEditingController();
    String materialType = 'pdf'; // pdf | text | image | audio
    File? selectedFile;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear Actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: timeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tiempo límite (minutos)'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo de evaluación'),
                  items: const [
                    DropdownMenuItem(value: 'Practica', child: Text('Práctica')),
                    DropdownMenuItem(value: 'Simulacro', child: Text('Simulacro')),
                    DropdownMenuItem(value: 'Examen', child: Text('Examen')),
                  ],
                  onChanged: (v) => tipo = v ?? 'Practica',
                ),
                const SizedBox(height: 8),
                // Módulo (opcional)
                DropdownButtonFormField<int>(
                  value: selectedModuleId,
                  decoration: const InputDecoration(labelText: 'Módulo (opcional)'),
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('Sin Módulo')),
                    ..._modules.map((m) => DropdownMenuItem<int>(
                          value: m['id_modulo'] as int,
                          child: Text(m['nombre_modulo'] as String? ?? 'Módulo'),
                        )),
                  ],
                  onChanged: (v) => selectedModuleId = v,
                ),
                const SizedBox(height: 12),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Agregar material (opcional)'),
                  value: addMaterial,
                  onChanged: (val) => setDialogState(() => addMaterial = val),
                ),
                if (addMaterial) ...[
                  TextField(
                    controller: materialTitleCtrl,
                    decoration: const InputDecoration(labelText: 'Título del material'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: materialType,
                    decoration: const InputDecoration(labelText: 'Tipo de material'),
                    items: const [
                      DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                      DropdownMenuItem(value: 'text', child: Text('Texto')),
                      DropdownMenuItem(value: 'image', child: Text('Imagen')),
                      DropdownMenuItem(value: 'audio', child: Text('Audio')),
                    ],
                    onChanged: (v) => setDialogState(() => materialType = v ?? 'pdf'),
                  ),
                  const SizedBox(height: 8),
                  if (materialType == 'text')
                    TextField(
                      controller: materialTextCtrl,
                      decoration: const InputDecoration(labelText: 'Contenido de texto'),
                      maxLines: 4,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedFile?.path.split('\\').last ?? 'Ningún archivo seleccionado',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final extensions = materialType == 'pdf'
                                ? ['pdf']
                                : materialType == 'image'
                                    ? ['png', 'jpg', 'jpeg']
                                    : ['mp3', 'm4a', 'wav'];
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: extensions,
                            );
                            if (result != null && result.files.single.path != null) {
                              setDialogState(() => selectedFile = File(result.files.single.path!));
                            }
                          },
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Seleccionar archivo'),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final titulo = titleCtrl.text.trim();
                  if (titulo.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Título requerido')));
                    return;
                  }
                  final tiempo = int.tryParse(timeCtrl.text.trim());

                  final payload = <String, dynamic>{
                    'titulo': titulo,
                    if (descCtrl.text.trim().isNotEmpty) 'descripcion': descCtrl.text.trim(),
                    if (tiempo != null) 'tiempo_limite_minutos': tiempo,
                    'tipo_evaluacion': tipo,
                    'activo': true,
                  };
                  if (widget.activityTypeId != null) {
                    payload['id_tipo_actividad'] = widget.activityTypeId;
                  } else {
                    payload['id_habilidad'] = widget.skillId;
                  }
                  final insertedQuiz = await supabase
                      .from('cuestionarios')
                      .insert(payload)
                      .select('id_cuestionario')
                      .single();
                  final insertedQuizId = insertedQuiz['id_cuestionario'] as int;

                  // Crear material si corresponde
                  if (addMaterial) {
                    final mTitle = (materialTitleCtrl.text.trim().isEmpty) ? titulo : materialTitleCtrl.text.trim();
                    String? publicUrl;
                    String? contenidoTexto;
                    if (materialType == 'text') {
                      contenidoTexto = materialTextCtrl.text.trim();
                      if (contenidoTexto.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contenido de texto requerido')));
                      } else {
                        await ApiService.createMaterial(
                          habilidadId: widget.skillId,
                          titulo: mTitle,
                          tipoMaterial: 'text',
                          contenidoTexto: contenidoTexto,
                          cuestionarioId: insertedQuizId,
                          esPremium: false,
                          orden: 1,
                        );
                      }
                    } else {
                      if (selectedFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un archivo para el material')));
                      } else {
                        final storage = SupabaseStorageService();
                        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split('\\').last}';
                        try {
                          if (materialType == 'pdf') {
                            final r = await storage.uploadPDF(pdfFile: selectedFile!, fileName: fileName);
                            if (r['success'] == true) publicUrl = r['url'] as String;
                          } else if (materialType == 'image') {
                            final r = await storage.uploadImage(imageFile: selectedFile!, fileName: fileName);
                            if (r['success'] == true) publicUrl = r['url'] as String;
                          } else if (materialType == 'audio') {
                            final path = 'materials/$fileName';
                            await supabase.storage.from('audios').upload(path, selectedFile!);
                            publicUrl = supabase.storage.from('audios').getPublicUrl(path);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error subiendo material: $e')));
                        }
                        if (publicUrl != null) {
                          await ApiService.createMaterial(
                            habilidadId: widget.skillId,
                            titulo: mTitle,
                            tipoMaterial: materialType,
                            archivoUrl: publicUrl,
                            cuestionarioId: insertedQuizId,
                            esPremium: false,
                            orden: 1,
                          );
                        }
                      }
                    }
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                  await _load();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actividad creada')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteQuiz(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('Â¿Eliminar "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await supabase.from('cuestionarios').delete().eq('id_cuestionario', id);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actividad eliminada')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activityTypeName != null
            ? '${widget.courseName} > ${widget.skillName} > ${widget.activityTypeName}'
            : '${widget.courseName} > ${widget.skillName}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
            tooltip: 'Módulos',
            icon: const Icon(Icons.folder),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherModulesScreen(
                    skillId: widget.skillId,
                    skillName: widget.skillName,
                    courseName: widget.courseName,
                  ),
                ),
              ).then((_) => _load());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _createQuizDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Crear Actividad'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _quizzes.isEmpty
                  ? const Center(child: Text('No hay actividades Aún'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _quizzes.length,
                        itemBuilder: (context, index) {
                          final q = _quizzes[index];
                          return _buildQuizCard(q);
                        },
                      ),
                    ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> q) {
    final title = q['titulo'] as String? ?? 'Actividad';
    final tipo = q['tipo_evaluacion'] as String? ?? 'â€”';
    final minutos = q['tiempo_limite_minutos'] as int?;
    final id = q['id_cuestionario'] as int;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment, color: Colors.deepPurple),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Tipo: $tipo'),
              if (minutos != null) Text('Tiempo límite: $minutos min'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Administrar preguntas',
                icon: const Icon(Icons.quiz, color: Colors.blueGrey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherQuestionsScreen(
                        quizId: id,
                        skillId: widget.skillId,
                        quizTitle: title,
                      ),
                    ),
                  ).then((_) => _load());
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteQuiz(id, title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
