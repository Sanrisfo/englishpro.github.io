import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import 'teacher_activities_screen.dart';

class TeacherSkillsScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const TeacherSkillsScreen({Key? key, required this.courseId, required this.courseName}) : super(key: key);

  @override
  State<TeacherSkillsScreen> createState() => _TeacherSkillsScreenState();
}

class _TeacherSkillsScreenState extends State<TeacherSkillsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _skills = [];

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
      final response = await supabase
          .from('habilidades')
          .select('id_habilidad, nombre_habilidad, descripcion, orden, curso_id')
          .eq('curso_id', widget.courseId)
          .order('orden', ascending: true);
      setState(() => _skills = List<Map<String, dynamic>>.from(response as List));
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando habilidades: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Curso: ${widget.courseName}'),
        backgroundColor: Colors.deepPurple,
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _skills.length,
                  itemBuilder: (context, index) {
                    final s = _skills[index];
                    return _buildSkillCard(s);
                  },
                ),
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> s) {
    final id = s['id_habilidad'] as int;
    final name = s['nombre_habilidad'] as String? ?? 'Habilidad';
    final desc = s['descripcion'] as String? ?? '';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherActivitiesScreen(skillId: id, skillName: name, courseName: widget.courseName),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.extension, color: Colors.deepPurple),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: desc.isNotEmpty ? Text(desc) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
