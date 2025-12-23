import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../widgets/rich_text_field.dart';
import '../config/supabase_config.dart';
import '../services/supabase_storage_service.dart';
import '../services/api_service.dart';
import 'teacher_questions_screen.dart';
import 'create_activity_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gestión de actividades/cuestionarios por parte del docente.
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
  // List<Map<String, dynamic>> _modules = []; // Eliminado
  late final Color _courseColor; // Color del tema

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
      var query = supabase
          .from('cuestionarios')
          .select('id_cuestionario, titulo, descripcion, tiempo_limite_minutos, tipo_evaluacion, activo');
      if (widget.activityTypeId != null) {
        query = query.eq('id_tipo_actividad', widget.activityTypeId!);
      } else {
        query = query.eq('id_habilidad', widget.skillId);
      }
      final response = await query.eq('activo', true).order('id_cuestionario', ascending: true);
      setState(() => _quizzes = List<Map<String, dynamic>>.from(response as List));

    } catch (e) {
      setState(() => _errorMessage = 'Error loading activities: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _dialogTextFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF23408E).withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  ButtonStyle _dialogButtonStyle({bool isDestructive = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isDestructive ? const Color(0xFFD9232A) : _courseColor.withOpacity(0.1),
      foregroundColor: isDestructive ? Colors.white : _courseColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,

    );
  }

  Future<void> _createQuizDialog({Map<String, dynamic>? quizToEdit}) async {
    final isEdit = quizToEdit != null;
    final titleCtrl = TextEditingController(text: isEdit ? quizToEdit!['titulo'] : '');
    final descCtrl = TextEditingController(text: isEdit ? quizToEdit!['descripcion'] : '');
    final timeCtrl = TextEditingController(text: isEdit ? (quizToEdit!['tiempo_limite_minutos']?.toString() ?? '') : '');
    String tipo = isEdit ? (quizToEdit!['tipo_evaluacion'] ?? 'Practica') : 'Practica';

    // Material logic (Editing material is complex, for MVP we might only allow creating new material or keep existing)
    // For now, in Edit mode, we won't show the "Add material" toggle to avoid complexity if one already exists, 
    // or we leave it as "Add NEW material". 
    // Simplifying: Hide material section in Edit mode for this iteration OR allow adding new.
    // Let's hide it for now to prevent confusion/data loss, as requested "Edit Activity" usually means metadata.
    bool addMaterial = false;
    final materialTitleCtrl = TextEditingController();
    final materialTextCtrl = TextEditingController();
    String materialType = 'pdf'; 
    File? selectedFile;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Activity' : 'Create Activity',
            style: GoogleFonts.ptSans(color: _courseColor, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: _dialogTextFieldDecoration('Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: _dialogTextFieldDecoration('Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: timeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _dialogTextFieldDecoration('Time limit (minutes)'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: _dialogTextFieldDecoration('Evaluation type'),
                  items: const [
                    DropdownMenuItem(value: 'Practica', child: Text('Practice')),
                    DropdownMenuItem(value: 'Simulacro', child: Text('Mock Test')),
                    DropdownMenuItem(value: 'Examen', child: Text('Exam')),
                  ],
                  onChanged: (v) => tipo = v ?? 'Practica',
                ),

                if (!isEdit) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Add material (optional)'),
                    value: addMaterial,
                    onChanged: (val) => setDialogState(() => addMaterial = val),
                    activeColor: _courseColor,
                  ),
                  if (addMaterial) ...[
                    TextField(
                      controller: materialTitleCtrl,
                      decoration: _dialogTextFieldDecoration('Material title'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: materialType,
                      decoration: _dialogTextFieldDecoration('Material type'),
                      items: const [
                        DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                        DropdownMenuItem(value: 'text', child: Text('Text')),
                        DropdownMenuItem(value: 'image', child: Text('Image')),
                        DropdownMenuItem(value: 'audio', child: Text('Audio')),
                      ],
                      onChanged: (v) => setDialogState(() => materialType = v ?? 'pdf'),
                    ),
                    const SizedBox(height: 8),
                    if (materialType == 'text')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichTextField(
                            controller: materialTextCtrl,
                            label: 'Text content (Supports Markdown)',
                            maxLines: 6,
                            decoration: _dialogTextFieldDecoration('Text content (Supports Markdown)'),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedFile?.path.split(Platform.pathSeparator).last ?? 'No file selected',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: _dialogButtonStyle(),
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
                            child: const Icon(Icons.attach_file),
                          ),
                        ],
                      ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: _dialogButtonStyle(),
              onPressed: () async {
                try {
                  final titulo = titleCtrl.text.trim();
                  if (titulo.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
                    return;
                  }
                  final tiempo = int.tryParse(timeCtrl.text.trim());

                  final payload = <String, dynamic>{
                    'titulo': titulo,
                    'descripcion': descCtrl.text.trim(),
                    'tiempo_limite_minutos': tiempo,
                    'tipo_evaluacion': tipo,
                    'activo': true,
                  };
                  
                  if (isEdit) {
                     // UPDATE
                     await supabase.from('cuestionarios')
                        .update(payload)
                        .eq('id_cuestionario', quizToEdit!['id_cuestionario']);
                     
                     if (!mounted) return;
                     Navigator.pop(context);
                     await _load();
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity updated')));
                  } else {
                    // INSERT
                    if (widget.activityTypeId != null) {
                      payload['id_tipo_actividad'] = widget.activityTypeId;
                    } else {
                      payload['id_habilidad'] = widget.skillId;
                    }
                    if (descCtrl.text.trim().isEmpty) payload.remove('descripcion'); // clean if empty for insert

                    final insertedQuiz = await supabase
                        .from('cuestionarios')
                        .insert(payload)
                        .select('id_cuestionario')
                        .single();
                    final insertedQuizId = insertedQuiz['id_cuestionario'] as int;

                    if (addMaterial) {
                      final mTitle = (materialTitleCtrl.text.trim().isEmpty) ? titulo : materialTitleCtrl.text.trim();
                      String? publicUrl;
                      String? contenidoTexto;
                      if (materialType == 'text') {
                        contenidoTexto = materialTextCtrl.text.trim();
                        if (contenidoTexto.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text content is required')));
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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file for the material')));
                        } else {
                          final storage = SupabaseStorageService();
                          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split(Platform.pathSeparator).last}';
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading material: $e')));
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity created')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(isEdit ? 'Save' : 'Create'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Deletion'),
        content: Text('Delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: _dialogButtonStyle(isDestructive: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await supabase.from('cuestionarios').delete().eq('id_cuestionario', id);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity deleted')));
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
    // Títulos dinámicos para el encabezado
    final String headerTitle = widget.activityTypeName ?? widget.skillName;
    final String breadcrumb = widget.activityTypeName != null
        ? '... > ${widget.skillName} > ${widget.activityTypeName} > Activities'
        : '... > ${widget.courseName} > ${widget.skillName} > Activities';

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _isLoading
                ? null
                : () async {
                    final created = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateActivityScreen(
                          skillId: widget.skillId,
                          skillName: widget.skillName,
                          courseName: widget.courseName,
                          activityTypeId: widget.activityTypeId,
                          activityTypeName: widget.activityTypeName,
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                    if (created == true) {
                      await _load();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity created')));
                      }
                    }
                  },
            icon: const Icon(Icons.add),
            label: const Text('New Activity'),
            heroTag: null,
            backgroundColor: _courseColor.withOpacity(0.1),
            foregroundColor: _courseColor,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: const Color(0xFFD9232A), // Rojo
            foregroundColor: Colors.white,
            heroTag: null,
            child: const Icon(Icons.arrow_back_ios_new),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // --- Body Rediseñado ---
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _courseColor, strokeWidth: 5.0))
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : _quizzes.isEmpty
            ? const Center(child: Text('No activities found yet'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Encabezado Estándar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
                      decoration: BoxDecoration(
                        color: _courseColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        headerTitle, // Título dinámico
                        style: GoogleFonts.ptSans(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    breadcrumb, // Migas de pan dinámicas
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
            // 2. Lista Estándar (envuelta en Expanded)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                color: _courseColor,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _quizzes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final q = _quizzes[index];
                    return _buildActivityTile(q);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> q) {
    final title = q['titulo'] as String? ?? 'Activity';
    final tipo = q['tipo_evaluacion'] as String? ?? '—';
    final minutos = q['tiempo_limite_minutos'] as int?;
    final id = q['id_cuestionario'] as int;
    final desc = q['descripcion'] as String? ?? '';

    return InkWell(
      onTap: () {
        // Al tocar la tarjeta, va a la pantalla de preguntas
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
              child: Icon(Icons.assignment_outlined, color: _courseColor, size: 28),
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
                  // Subtítulos (Tipo y Tiempo)
                  Text(
                    "Type: $tipo" + (minutos != null ? "  •  $minutos min" : ""),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
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
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Botones de Acción
            IconButton(
              tooltip: 'Edit activity',
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF23408E)),
              onPressed: () => _createQuizDialog(quizToEdit: q),
            ),
            IconButton(
              tooltip: 'Delete activity',
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD9232A)),
              onPressed: () => _deleteQuiz(id, title),
            ),
          ],
        ),
      ),
    );
  }


  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) {
      return const Color(0xFFD9232A); // Rojo
    } else if (lower.contains('ielts')) {
      return const Color(0xFF23408E); // Azul
    } else if (lower.contains('business')) {
      return const Color(0xFFB02224); // Rojo Oscuro
    } else {
      return const Color(0xFF1F3A89); // Azul Oscuro
    }
  }
}
