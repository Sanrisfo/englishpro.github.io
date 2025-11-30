import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../config/supabase_config.dart';
import '../services/supabase_storage_service.dart';
import '../models/material_model.dart';
import '../models/skill_model.dart';

/// Gestión de materiales (PDF, video, audio) por parte del docente.
class TeacherMaterialsScreen extends StatefulWidget {
  const TeacherMaterialsScreen({Key? key}) : super(key: key);

  @override
  State<TeacherMaterialsScreen> createState() => _TeacherMaterialsScreenState();
}

class _TeacherMaterialsScreenState extends State<TeacherMaterialsScreen> {
  bool _isLoading = true;
  List<MaterialModel> _materials = [];
  List<SkillModel> _skills = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all materials
      final materialsResponse = await ApiService.getMaterials();
      // Load all skills for the dropdown
      final skillsResponse = await ApiService.getSkills();

      if (materialsResponse['success'] == true && skillsResponse['success'] == true) {
        setState(() {
          _materials = materialsResponse['materials'] as List<MaterialModel>;
          _skills = skillsResponse['skills'] as List<SkillModel>;
        });
      } else {
        setState(() {
          _errorMessage = materialsResponse['message'] ?? skillsResponse['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateMaterialDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacherId = authProvider.user?.idUsuario;

    if (teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Login failed',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
            backgroundColor: const Color(0xFFD9232A),
          )
      );
      return;
    }

    // Asegurar que existan habilidades disponibles antes de abrir el diálogo
    if (_skills.isEmpty) {
      // Cargar SOLO habilidades para no depender del endpoint de materiales
      setState(() => _isLoading = true);
      try {
        final skillsResponse = await ApiService.getSkills();
        if (skillsResponse['success'] == true) {
          setState(() {
            _skills = skillsResponse['skills'] as List<SkillModel>;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(skillsResponse['message'] ?? 'No se pudieron cargar las habilidades')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando habilidades: $e')),
        );
        return;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      if (_skills.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay habilidades disponibles aún. Intenta nuevamente en unos segundos.'),
          ),
        );
        return;
      }
    }

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final urlController = TextEditingController();
    final contentController = TextEditingController();
    final durationController = TextEditingController();
    int? selectedSkillId = _skills.isNotEmpty ? _skills.first.id : null;
    String selectedType = 'pdf';
    String selectedLevel = 'Freemium';
    bool isPremium = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Material'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Skill dropdown
                    DropdownButtonFormField<int>(
                      value: selectedSkillId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Habilidad *'),
                      hint: const Text('Selecciona una habilidad'),
                      disabledHint: const Text('Cargando habilidades...'),
                      items: () {
                        // Eliminar duplicados por ID usando Map
                        final Map<int, SkillModel> uniqueSkills = {};
                        for (var skill in _skills) {
                          if (skill.id > 0 && !uniqueSkills.containsKey(skill.id)) {
                            uniqueSkills[skill.id] = skill;
                          }
                        }
                        return uniqueSkills.values.map((skill) {
                          return DropdownMenuItem<int>(
                            value: skill.id,
                            child: Text(skill.nombre),
                          );
                        }).toList();
                      }(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSkillId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione una habilidad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    // Type
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                        DropdownMenuItem(value: 'video', child: Text('Video')),
                        DropdownMenuItem(value: 'audio', child: Text('Audio')),
                        DropdownMenuItem(value: 'text', child: Text('Texto')),
                        DropdownMenuItem(value: 'link', child: Text('Enlace')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // URL + Subida directa
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: urlController,
                            decoration: const InputDecoration(
                              labelText: 'URL del Archivo (opcional)',
                              hintText: 'https://...',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Seleccionar archivo según tipo
                            List<String> exts;
                            String bucket;
                            String folder;
                            if (selectedType == 'pdf') {
                              exts = ['pdf'];
                              bucket = 'pdfs';
                              folder = 'materials';
                            } else if (selectedType == 'image' || selectedType == 'imagen') {
                              exts = ['png', 'jpg', 'jpeg'];
                              bucket = 'images';
                              folder = '';
                            } else if (selectedType == 'audio') {
                              exts = ['mp3', 'm4a', 'wav'];
                              bucket = 'audios';
                              folder = 'materials';
                            } else if (selectedType == 'video') {
                              exts = ['mp4', 'mov'];
                              bucket = 'videos';
                              folder = '';
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tipo no soportado para subida directa')),
                              );
                              return;
                            }

                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: exts,
                            );
                            if (result == null || result.files.single.path == null) return;
                            final file = File(result.files.single.path!);
                            final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

                            String? publicUrl;
                            try {
                              final storage = SupabaseStorageService();
                              if (selectedType == 'pdf') {
                                final r = await storage.uploadPDF(pdfFile: file, fileName: fileName);
                                if (r['success'] == true) publicUrl = r['url'] as String;
                              } else if (selectedType == 'image' || selectedType == 'imagen') {
                                final r = await storage.uploadImage(imageFile: file, fileName: fileName);
                                if (r['success'] == true) publicUrl = r['url'] as String;
                              } else if (selectedType == 'audio') {
                                // Subir a bucket audios/materials/
                                final path = folder.isNotEmpty ? '$folder/$fileName' : fileName;
                                await supabase.storage.from(bucket).upload(path, file);
                                publicUrl = supabase.storage.from(bucket).getPublicUrl(path);
                              } else if (selectedType == 'video') {
                                final r = await storage.uploadVideo(videoFile: file, fileName: fileName);
                                if (r['success'] == true) publicUrl = r['url'] as String;
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error subiendo archivo: $e')),
                              );
                              return;
                            }

                            if (publicUrl != null) {
                              setDialogState(() {
                                urlController.text = publicUrl!;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Archivo subido')),
                              );
                            }
                          },
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Subir'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Content
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Contenido de Texto (opcional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    // Premium
                    CheckboxListTile(
                      title: const Text('Material Premium'),
                      value: isPremium,
                      onChanged: (value) {
                        setDialogState(() {
                          isPremium = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedSkillId == null || titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor complete los campos obligatorios'),
                        ),
                      );
                      return;
                    }

                    // Create material
                    final result = await ApiService.createMaterial(
                      habilidadId: selectedSkillId!,
                      titulo: titleController.text,
                      tipoMaterial: selectedType,
                      descripcion: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                      archivoUrl: urlController.text.isNotEmpty ? urlController.text : null,
                      contenidoTexto: contentController.text.isNotEmpty ? contentController.text : null,
                      esPremium: isPremium,
                      duracionMinutos: int.tryParse(durationController.text),
                      // nivelAcceso: selectedLevel, // opcional; omitir para evitar constraint si no existe
                      // creadoPor: teacherId, // opcional; puede requerir id_docente, se omite
                    );

                    Navigator.pop(context);

                    if (result['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Material creado exitosamente')),
                      );
                      _loadData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${result['message']}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMaterial(int materialId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Está seguro de eliminar "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.deleteMaterial(materialId);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material eliminado exitosamente')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Materiales'),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _showCreateMaterialDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Material'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                        onPressed: _loadData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _materials.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay materiales todavía',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Presiona el botón + para crear uno',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _materials.length,
                        itemBuilder: (context, index) {
                          final material = _materials[index];
                          return _buildMaterialCard(material);
                        },
                      ),
                    ),
    );
  }

  Widget _buildMaterialCard(MaterialModel material) {
    IconData icon;
    Color iconColor;

    switch (material.tipoMaterial) {
      case 'PDF':
        icon = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'Video':
        icon = Icons.video_library;
        iconColor = Colors.blue;
        break;
      case 'Audio':
        icon = Icons.audiotrack;
        iconColor = Colors.orange;
        break;
      case 'Texto':
        icon = Icons.article;
        iconColor = Colors.green;
        break;
      case 'Imagen':
        icon = Icons.image;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.description;
        iconColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          material.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Tipo: ${material.tipoMaterial}'),
            Text('Premium: ${material.esPremium ? "Sí" : "No"}'),
            Text('Orden: ${material.orden}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteMaterial(material.id!, material.titulo),
        ),
      ),
    );
  }
}
