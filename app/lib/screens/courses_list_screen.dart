import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';
import 'activity_types_screen.dart';

/// Lista de cursos disponibles y navegación a habilidades.
class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({Key? key}) : super(key: key);

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getCourses();

      if (result['success'] == true) {
        setState(() {
          _courses = result['courses'] as List<CourseModel>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load courses';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCourses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _courses.isEmpty
                  ? const Center(
                      child: Text(
                        'No courses available',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCourses,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return _buildCourseCard(course);
                        },
                      ),
                    ),
    );
  }

  /// Tarjeta de curso con estilo y navegación al detalle.
  Widget _buildCourseCard(CourseModel course) {
    final color = _hexToColor(course.colorHex);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to course details or skills screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course.nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.estiloProgreso == 'Porcentaje' ? '%' : 'Modules',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  course.descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course.tipoCurso,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla de detalle de curso con lista de habilidades.
class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  List<dynamic> _skills = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getSkillsByCourse(widget.course.id);

      if (result['success'] == true) {
        setState(() {
          _skills = result['skills'] as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load skills';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  IconData _getSkillIcon(String skillName) {
    switch (skillName.toLowerCase()) {
      case 'reading':
        return Icons.menu_book;
      case 'writing':
        return Icons.edit;
      case 'listening':
        return Icons.headphones;
      case 'speaking':
        return Icons.mic;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(widget.course.colorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.nombre),
        backgroundColor: color,
      ),
      body: Column(
        children: [
          // Course Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.nombre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.course.descripcion,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Skills List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadSkills,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _skills.isEmpty
                        ? const Center(
                            child: Text(
                              'No skills available for this course',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _skills.length,
                            itemBuilder: (context, index) {
                              final skill = _skills[index];
                              return _buildSkillCard(skill, color);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(dynamic skill, Color courseColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: courseColor.withOpacity(0.2),
          child: Icon(
            _getSkillIcon(skill.nombre),
            color: courseColor,
          ),
        ),
        title: Text(
          skill.nombre,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          skill.descripcion,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityTypesScreen(
                skillId: skill.id,
                skillName: skill.nombre,
                courseName: widget.course.nombre,
              ),
            ),
          );
        },
      ),
    );
  }
}
