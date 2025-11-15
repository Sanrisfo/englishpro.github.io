import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'teacher_activities_screen.dart';

class TeacherActivityTypesScreen extends StatefulWidget {
  final int skillId;
  final String skillName;
  final String courseName;

  const TeacherActivityTypesScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    required this.courseName,
  });

  @override
  State<TeacherActivityTypesScreen> createState() => _TeacherActivityTypesScreenState();
}

class _TeacherActivityTypesScreenState extends State<TeacherActivityTypesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _types = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.getActivityTypesBySkill(widget.skillId);
      if (res['success'] == true) {
        final items = res['types'] as List<dynamic>;
        _types = items
            .map((e) => e is Map<String, dynamic> ? e : (e as dynamic).toJson() as Map<String, dynamic>)
            .toList();
      } else {
        _error = res['message'] ?? 'No se pudieron cargar los tipos de actividad';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _createTypeDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int orden = (_types.length + 1);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Crear Tipo de Actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')), 
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nombre = nameCtrl.text.trim();
              if (nombre.isEmpty) return;
              final r = await ApiService.createActivityType(
                skillId: widget.skillId,
                nombre: nombre,
                descripcion: descCtrl.text.trim(),
                orden: orden,
              );
              if (!mounted) return;
              Navigator.pop(context);
              if (r['success'] == true) {
                await _load();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipo creado')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Error creando tipo')));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _renameTypeDialog(Map<String, dynamic> t) async {
    final nameCtrl = TextEditingController(text: (t['nombre'] as String?) ?? '');
    final descCtrl = TextEditingController(text: (t['descripcion'] as String?) ?? '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Tipo de Actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nombre = nameCtrl.text.trim();
              final id = (t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0);
              final r = await ApiService.updateActivityType(
                id: id,
                nombre: nombre.isEmpty ? null : nombre,
                descripcion: descCtrl.text.trim(),
              );
              if (!mounted) return;
              Navigator.pop(context);
              if (r['success'] == true) {
                await _load();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipo actualizado')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Error actualizando tipo')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteType(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Tipo'),
        content: const Text('¿Eliminar este tipo de actividad? (También eliminará sus actividades)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    final r = await ApiService.deleteActivityType(id);
    if (r['success'] == true) {
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipo eliminado')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Error eliminando tipo')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseName} › ${widget.skillName} › Tipos'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _createTypeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Tipo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _types.isEmpty
                  ? const Center(child: Text('No hay tipos de actividad'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _types.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = _types[index];
                          final nombre = (t['nombre'] as String?) ?? 'Tipo';
                          final id = (t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0);
                          final desc = (t['descripcion'] as String?) ?? '';
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.category),
                              title: Text(nombre),
                              subtitle: desc.isNotEmpty ? Text(desc) : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TeacherActivitiesScreen(
                                      skillId: widget.skillId,
                                      skillName: widget.skillName,
                                      courseName: widget.courseName,
                                      activityTypeId: id,
                                      activityTypeName: nombre,
                                    ),
                                  ),
                                ).then((_) => _load());
                              },
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _renameTypeDialog(t),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteType(id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

