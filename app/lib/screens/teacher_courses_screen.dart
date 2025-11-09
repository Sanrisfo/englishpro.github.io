import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import 'teacher_skills_screen.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({Key? key}) : super(key: key);

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _courses = [];

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
          .from('cursos')
          .select('id, nombre_curso, tipo_curso, estilo_progreso, url_imagen, activo')
          .eq('activo', true)
          .order('id');
      setState(() => _courses = List<Map<String, dynamic>>.from(response as List));
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando cursos: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulos: Cursos'),
        backgroundColor: Colors.deepPurple,
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final c = _courses[index];
                      return _buildCourseCard(c);
                    },
                  ),
                ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> c) {
    final title = c['nombre_curso'] as String? ?? 'Curso';
    final tipo = c['tipo_curso'] as String? ?? '';
    final id = (c['id'] as num).toInt();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherSkillsScreen(courseId: id, courseName: title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.deepPurple),
                  ),
                  const Spacer(),
                  Text(tipo, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
