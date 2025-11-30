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
  String _materialType = 'pdf';
  File? _selectedFile;

  bool _submitting = false;

  Color get _courseColor => _getCourseColor(widget.courseName);

  InputDecoration _fieldDeco(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: _courseColor.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _courseColor, width: 2)),
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
    final headerTitle = widget.activityTypeName ?? 'New Activity';
    final breadcrumb = widget.activityTypeName != null
        ? '... > ${widget.skillName} > ${widget.activityTypeName}'
        : '... > ${widget.courseName} > ${widget.skillName}';

    return Scaffold(
      backgroundColor: Colors.white,

      // 3. BOTÓN INFERIOR RECTANGULAR
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _courseColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rectangular con ligero borde
              elevation: 0,
            ),
            child: _submitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create activity', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BOTÓN ATRÁS (X GRIS)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // 2. ENCABEZADO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: _courseColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          headerTitle,
                          style: GoogleFonts.ptSans(
                            color: _courseColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      breadcrumb,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. FORMULARIO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextField(controller: _titleCtrl, decoration: _fieldDeco('Title')),
                    const SizedBox(height: 16),
                    TextField(controller: _descCtrl, decoration: _fieldDeco('Description'), maxLines: 3),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: TextField(controller: _timeCtrl, decoration: _fieldDeco('Time limit (min)'), keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _tipo,
                            decoration: _fieldDeco('Evaluation Type'),
                            items: const [
                              DropdownMenuItem(value: 'Practica', child: Text('Practice')),
                              DropdownMenuItem(value: 'Simulacro', child: Text('Mock Test')),
                              DropdownMenuItem(value: 'Examen', child: Text('Exam')),
                            ],
                            onChanged: (v) => setState(() => _tipo = v ?? 'Practica'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // MATERIAL
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: _courseColor,
                      value: _addMaterial,
                      onChanged: (v) => setState(() => _addMaterial = v),
                      title: Text('Add Study Material', style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      subtitle: const Text('Attach PDF, Audio, Image or Text'),
                    ),

                    if (_addMaterial) ...[
                      const SizedBox(height: 16),
                      TextField(controller: _materialTitleCtrl, decoration: _fieldDeco('Material Title')),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _materialType,
                        decoration: _fieldDeco('Material Type'),
                        items: const [
                          DropdownMenuItem(value: 'pdf', child: Text('PDF Document')),
                          DropdownMenuItem(value: 'text', child: Text('Reading Text')),
                          DropdownMenuItem(value: 'image', child: Text('Image')),
                          DropdownMenuItem(value: 'audio', child: Text('Audio File')),
                        ],
                        onChanged: (v) => setState(() => _materialType = v ?? 'pdf'),
                      ),

                      const SizedBox(height: 16),

                      if (_materialType == 'text')
                        TextField(controller: _materialTextCtrl, decoration: _fieldDeco('Content'), maxLines: 6)
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.attach_file, color: _courseColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedFile?.path.split(Platform.pathSeparator).last ?? 'No file selected',
                                  style: TextStyle(color: _selectedFile != null ? Colors.black87 : Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: _pickFile,
                                style: TextButton.styleFrom(foregroundColor: _courseColor),
                                child: const Text('Choose File'),
                              ),
                            ],
                          ),
                        ),
                    ],

                    const SizedBox(height: 40), // Espacio extra para que no se pegue abajo
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) return const Color(0xFFD9232A);
    if (lower.contains('ielts')) return const Color(0xFF23408E);
    if (lower.contains('business')) return const Color(0xFFB02224);
    return const Color(0xFF1F3A89);
  }
}