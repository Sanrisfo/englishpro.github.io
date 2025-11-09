import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/module_model.dart';

class TeacherModulesScreen extends StatefulWidget {
  final int skillId;
  final String skillName;
  final String courseName;
  const TeacherModulesScreen({Key? key, required this.skillId, required this.skillName, required this.courseName}) : super(key: key);

  @override
  State<TeacherModulesScreen> createState() => _TeacherModulesScreenState();
}

class _TeacherModulesScreenState extends State<TeacherModulesScreen> {
  bool _loading = true;
  String? _error;
  List<ModuleModel> _modules = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.getModulesBySkill(widget.skillId); if (res['success'] == true) { setState(() { _modules = (res['modules'] as List<ModuleModel>); });
      } else {
        setState(() { _error = res['message'] ?? 'No se pudieron cargar módulos'; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _createModuleDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Módulo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del módulo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre requerido')));
                return;
              }
              final res = await ApiService.createModule(
                habilidadId: widget.skillId,
                nombre: name,
                descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
              );
              if (!mounted) return;
              Navigator.pop(context);
              await _load();
              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo creado')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Error')));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseName} • ${widget.skillName} • Módulos'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _createModuleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Módulo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _modules.isEmpty
                  ? const Center(child: Text('Aún no hay módulos'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _modules.length,
                        itemBuilder: (context, index) {
                          final m = _modules[index];
                          final name = m.nombre;
                          final orden = m.orden;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.folder, color: Colors.indigo),
                              title: Text(name),
                              subtitle: orden != null ? Text('Orden: $orden') : null,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

