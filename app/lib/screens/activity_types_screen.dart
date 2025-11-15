import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activity_list_screen.dart';

class ActivityTypesScreen extends StatefulWidget {
  final int skillId;
  final String skillName;
  final String courseName;

  const ActivityTypesScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    required this.courseName,
  });

  @override
  State<ActivityTypesScreen> createState() => _ActivityTypesScreenState();
}

class _ActivityTypesScreenState extends State<ActivityTypesScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseName} › ${widget.skillName} › Tipos'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
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
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ActivityListScreen(
                                      skillId: widget.skillId,
                                      activityTypeId: id,
                                      skillName: widget.skillName,
                                      courseName: widget.courseName,
                                      activityTypeName: nombre,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
