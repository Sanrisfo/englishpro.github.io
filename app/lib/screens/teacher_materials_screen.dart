import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/material_model.dart';
import '../models/skill_model.dart';

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
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final urlController = TextEditingController();
    final contentController = TextEditingController();
    int? selectedSkillId;
    String selectedType = 'pdf';
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
                      decoration: const InputDecoration(labelText: 'Habilidad'),
                      items: _skills.map((skill) {
                        return DropdownMenuItem<int>(
                          value: skill.id,
                          child: Text(skill.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSkillId = value;
                        });
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
                    // URL
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL del Archivo (opcional)',
                        hintText: 'https://...',
                      ),
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
                      urlRecurso: urlController.text.isNotEmpty ? urlController.text : null,
                      contenidoTexto: contentController.text.isNotEmpty ? contentController.text : null,
                      duracionMinutos: null,
                      nivelAcceso: isPremium ? 'Premium' : 'Freemium',
                      creadoPor: teacherId,
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
        onPressed: _showCreateMaterialDialog,
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
