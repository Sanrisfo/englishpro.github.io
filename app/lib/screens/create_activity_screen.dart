import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/supabase_config.dart';
import '../services/api_service.dart';
import '../services/supabase_storage_service.dart';

/// Pantalla para que un docente cree una nueva actividad (cuestionario).
///
/// Este widget `Stateful` presenta un formulario que permite definir los
/// detalles de una nueva actividad, como su título, descripción y tipo.
/// Opcionalmente, permite adjuntar un material de estudio (PDF, texto, imagen, etc.)
/// que quedará asociado a la actividad recién creada.
class CreateActivityScreen extends StatefulWidget {
  /// El ID de la habilidad a la que pertenecerá la actividad.
  final int skillId;

  /// El nombre de la habilidad, para mostrar en la UI.
  final String skillName;

  /// El nombre del curso, para mostrar en el "breadcrumb".
  final String courseName;

  /// El ID del tipo de actividad (opcional).
  final int? activityTypeId;

  /// El nombre del tipo de actividad (opcional).
  final String? activityTypeName;

  /// Crea una instancia de la pantalla de creación de actividades.
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
  Uint8List? _selectedBytes;
  String? _selectedFileName;

  bool _submitting = false;

  /// Color temático del curso.
  Color get _courseColor => _getCourseColor(widget.courseName);

  /// Decoración estándar para los campos de texto del formulario.
  InputDecoration _fieldDeco(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: _courseColor.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _courseColor, width: 2),
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

  /// Abre el selector de archivos para que el usuario elija un material.
  ///
  /// Filtra los tipos de archivo permitidos según el `_materialType` seleccionado.
  Future<void> _pickFile() async {
    List<String> extensions = [];
    if (_materialType == 'pdf') extensions = ['pdf'];
    if (_materialType == 'image') extensions = ['png', 'jpg', 'jpeg'];
    if (_materialType == 'audio') extensions = ['mp3', 'wav', 'm4a'];
    final result = await FilePicker.platform.pickFiles(
      type: extensions.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: extensions,
      withData: true, // Crucial para Web
    );
    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        if (kIsWeb) {
          _selectedBytes = result.files.single.bytes;
        } else if (result.files.single.path != null) {
          _selectedFile = File(result.files.single.path!);
        }
      });
    }
  }

  /// Procesa y envía los datos del formulario para crear la actividad y el material.
  ///
  /// El proceso se realiza en dos pasos principales:
  /// 1.  Crea el registro en la tabla `cuestionarios`.
  /// 2.  Si se ha añadido un material (`_addMaterial` es true):
  ///     a. Sube el archivo a Supabase Storage (si no es de tipo texto).
  ///     b. Crea el registro en la tabla `materiales_estudio`, vinculándolo
  ///        al `cuestionario` recién creado.
  Future<void> _submit() async {
    final titulo = _titleCtrl.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El título es obligatorio')));
      return;
    }
    final tiempo = int.tryParse(_timeCtrl.text.trim());
    setState(() => _submitting = true);
    try {
      final payload = <String, dynamic>{
        'titulo': titulo,
        if (_descCtrl.text.trim().isNotEmpty)
          'descripcion': _descCtrl.text.trim(),
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
        final mTitle = (_materialTitleCtrl.text.trim().isEmpty)
            ? titulo
            : _materialTitleCtrl.text.trim();
        String? publicUrl;
        String? contenidoTexto;
        if (_materialType == 'text') {
          contenidoTexto = _materialTextCtrl.text.trim();
          if (contenidoTexto.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El contenido del texto es obligatorio'),
              ),
            );
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
          if ((kIsWeb && _selectedBytes == null) ||
              (!kIsWeb && _selectedFile == null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Por favor, selecciona un archivo para el material',
                ),
              ),
            );
          } else {
            final storage = SupabaseStorageService();
            // Usar _selectedFileName si existe, o generar uno
            final nameToUse = _selectedFileName ?? 'file';
            final fileName =
                '${DateTime.now().millisecondsSinceEpoch}_$nameToUse';
            try {
              if (_materialType == 'pdf') {
                final r = await storage.uploadPDF(
                  pdfFile: _selectedFile,
                  bytes: _selectedBytes,
                  fileName: fileName,
                );
                if (r['success'] == true) publicUrl = r['url'] as String;
              } else if (_materialType == 'image') {
                final r = await storage.uploadImage(
                  imageFile: _selectedFile,
                  bytes: _selectedBytes,
                  fileName: fileName,
                );
                if (r['success'] == true) publicUrl = r['url'] as String;
              } else if (_materialType == 'audio') {
                // Usar uploadAudio que ya soporta bytes
                // Subida manual para audios en materiales
                final path = 'materials/$fileName';
                if (kIsWeb) {
                  await supabase.storage
                      .from('audios')
                      .uploadBinary(path, _selectedBytes!);
                } else {
                  await supabase.storage
                      .from('audios')
                      .upload(path, _selectedFile!);
                }
                publicUrl = supabase.storage.from('audios').getPublicUrl(path);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al subir material: $e')),
              );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerTitle = widget.activityTypeName ?? 'Nueva Actividad';
    final breadcrumb = widget.activityTypeName != null
        ? '... > ${widget.skillName} > ${widget.activityTypeName}'
        : '... > ${widget.courseName} > ${widget.skillName}';

    return Scaffold(
      backgroundColor: Colors.white,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _submitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Crear Actividad',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 8.0,
                        ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      decoration: _fieldDeco('Título'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descCtrl,
                      decoration: _fieldDeco('Descripción'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _timeCtrl,
                            decoration: _fieldDeco('Límite de tiempo (min)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _tipo,
                            decoration: _fieldDeco('Tipo de Evaluación'),
                            items: const [
                              DropdownMenuItem(
                                value: 'Practica',
                                child: Text('Práctica'),
                              ),
                              DropdownMenuItem(
                                value: 'Simulacro',
                                child: Text('Simulacro'),
                              ),
                              DropdownMenuItem(
                                value: 'Examen',
                                child: Text('Examen'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _tipo = v ?? 'Practica'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: _courseColor,
                      value: _addMaterial,
                      onChanged: (v) => setState(() => _addMaterial = v),
                      title: Text(
                        'Añadir Material de Estudio',
                        style: GoogleFonts.ptSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: const Text(
                        'Adjuntar PDF, Audio, Imagen o Texto',
                      ),
                    ),
                    if (_addMaterial) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _materialTitleCtrl,
                        decoration: _fieldDeco('Título del Material'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _materialType,
                        decoration: _fieldDeco('Tipo de Material'),
                        items: const [
                          DropdownMenuItem(
                            value: 'pdf',
                            child: Text('Documento PDF'),
                          ),
                          DropdownMenuItem(
                            value: 'text',
                            child: Text('Texto de Lectura'),
                          ),
                          DropdownMenuItem(
                            value: 'image',
                            child: Text('Imagen'),
                          ),
                          DropdownMenuItem(
                            value: 'audio',
                            child: Text('Archivo de Audio'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _materialType = v ?? 'pdf'),
                      ),
                      const SizedBox(height: 16),
                      if (_materialType == 'text')
                        TextField(
                          controller: _materialTextCtrl,
                          decoration: _fieldDeco('Contenido'),
                          maxLines: 6,
                        )
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
                                  _selectedFileName ??
                                      'Ningún archivo seleccionado',
                                  style: TextStyle(
                                    color: _selectedFileName != null
                                        ? Colors.black87
                                        : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: _pickFile,
                                style: TextButton.styleFrom(
                                  foregroundColor: _courseColor,
                                ),
                                child: const Text('Elegir Archivo'),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Determina el color a usar basado en el nombre del curso.
  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) return const Color(0xFFD9232A);
    if (lower.contains('ielts')) return const Color(0xFF23408E);
    if (lower.contains('business')) return const Color(0xFFB02224);
    return const Color(0xFF1F3A89);
  }
}
