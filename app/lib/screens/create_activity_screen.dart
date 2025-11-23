import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/supabase_config.dart';
import '../services/api_service.dart';
import '../services/supabase_storage_service.dart';

class CreateActivityScreen extends StatefulWidget {
  final int skillId;
  final String skillName;
  final String courseName;
  final int? activityTypeId;
  final String? activityTypeName;

  const CreateActivityScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    required this.courseName,
    this.activityTypeId,
    this.activityTypeName,
  });

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  String _tipo = 'Practica';

  bool _addMaterial = false;
  final _materialTitleCtrl = TextEditingController();
  final _materialTextCtrl = TextEditingController();
  String _materialType = 'pdf'; // pdf | text | image | audio
  File? _selectedFile;

  bool _submitting = false;

  Color get _courseColor => _getCourseColor(widget.courseName);

  InputDecoration _fieldDeco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF23408E).withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timeCtrl.dispose();
    _materialTitleCtrl.dispose();
    _materialTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    List<String> extensions = [];
    if (_materialType == 'pdf') extensions = ['pdf'];
    if (_materialType == 'image') extensions = ['png', 'jpg', 'jpeg'];
    if (_materialType == 'audio') extensions = ['mp3', 'wav', 'm4a'];
    final result = await FilePicker.platform.pickFiles(
      type: extensions.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: extensions,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    final titulo = _titleCtrl.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    final tiempo = int.tryParse(_timeCtrl.text.trim());
    setState(() => _submitting = true);
    try {
      final payload = <String, dynamic>{
        'titulo': titulo,
        if (_descCtrl.text.trim().isNotEmpty) 'descripcion': _descCtrl.text.trim(),
        if (tiempo != null) 'tiempo_limite_minutos': tiempo,
        'tipo_evaluacion': _tipo,
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
      final insertedQuizId = (insertedQuiz['id_cuestionario'] as num).toInt();

      if (_addMaterial) {
        final mTitle = (_materialTitleCtrl.text.trim().isEmpty) ? titulo : _materialTitleCtrl.text.trim();
        String? publicUrl;
        String? contenidoTexto;
        if (_materialType == 'text') {
          contenidoTexto = _materialTextCtrl.text.trim();
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
          if (_selectedFile == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file for the material')));
          } else {
            final storage = SupabaseStorageService();
            final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split(Platform.pathSeparator).last}';
            try {
              if (_materialType == 'pdf') {
                final r = await storage.uploadPDF(pdfFile: _selectedFile!, fileName: fileName);
                if (r['success'] == true) publicUrl = r['url'] as String;
              } else if (_materialType == 'image') {
                final r = await storage.uploadImage(imageFile: _selectedFile!, fileName: fileName);
                if (r['success'] == true) publicUrl = r['url'] as String;
              } else if (_materialType == 'audio') {
                final path = 'materials/$fileName';
                await supabase.storage.from('audios').upload(path, _selectedFile!);
                publicUrl = supabase.storage.from('audios').getPublicUrl(path);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading material: $e')));
            }
            if (publicUrl != null) {
              await ApiService.createMaterial(
                habilidadId: widget.skillId,
                titulo: mTitle,
                tipoMaterial: _materialType,
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
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerTitle = widget.activityTypeName ?? widget.skillName;
    final breadcrumb = widget.activityTypeName != null
        ? '... > ${widget.skillName} > ${widget.activityTypeName} > New Activity'
        : '... > ${widget.courseName} > ${widget.skillName} > New Activity';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
        backgroundColor: _courseColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                  decoration: BoxDecoration(color: _courseColor, borderRadius: BorderRadius.circular(10.0)),
                  child: Text(headerTitle, style: GoogleFonts.ptSans(color: Colors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(height: 12),
              Text(breadcrumb, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 16),

              TextField(controller: _titleCtrl, decoration: _fieldDeco('Title')),
              const SizedBox(height: 8),
              TextField(controller: _descCtrl, decoration: _fieldDeco('Description'), maxLines: 3),
              const SizedBox(height: 8),
              TextField(controller: _timeCtrl, decoration: _fieldDeco('Time limit (minutes)'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'Practica', child: Text('Practica')),
                  DropdownMenuItem(value: 'Simulacro', child: Text('Simulacro')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'Practica'),
              ),

              const SizedBox(height: 16),
              SwitchListTile(
                value: _addMaterial,
                onChanged: (v) => setState(() => _addMaterial = v),
                title: const Text('Add Material'),
              ),

              if (_addMaterial) ...[
                TextField(controller: _materialTitleCtrl, decoration: _fieldDeco('Material title (optional)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _materialType,
                  decoration: const InputDecoration(labelText: 'Material type'),
                  items: const [
                    DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                    DropdownMenuItem(value: 'text', child: Text('Text')),
                    DropdownMenuItem(value: 'image', child: Text('Image')),
                    DropdownMenuItem(value: 'audio', child: Text('Audio')),
                  ],
                  onChanged: (v) => setState(() => _materialType = v ?? 'pdf'),
                ),
                const SizedBox(height: 8),
                if (_materialType == 'text')
                  TextField(controller: _materialTextCtrl, decoration: _fieldDeco('Text content'), maxLines: 6)
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFile?.path.split(Platform.pathSeparator).last ?? 'No file selected',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(onPressed: _pickFile, icon: const Icon(Icons.attach_file)),
                    ],
                  ),
              ],

              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: _courseColor.withOpacity(0.1), foregroundColor: _courseColor),
                    child: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) {
      return const Color(0xFFD9232A);
    } else if (lower.contains('ielts')) {
      return const Color(0xFF23408E);
    } else if (lower.contains('business')) {
      return const Color(0xFFB02224);
    } else {
      return const Color(0xFF1F3A89);
    }
  }
}

