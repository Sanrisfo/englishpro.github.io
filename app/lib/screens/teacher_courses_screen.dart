import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/supabase_config.dart';
import 'teacher_skills_screen.dart';

/// Listado de cursos para gestión docente.
class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({Key? key}) : super(key: key);

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _courses = [];
  int _getSortPriority(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) return 1;
    if (lower.contains('ielts')) return 2;
    if (lower.contains('business')) return 3;
    if (lower.contains('action')) return 4;
    return 5;
  }

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
          .select(
            'id, nombre_curso, tipo_curso, estilo_progreso, url_imagen, activo',
          )
          .eq('activo', true)
          .order('id');
      var fetchedCourses = List<Map<String, dynamic>>.from(response as List);
      fetchedCourses.sort((a, b) {
        String nameA = a['nombre_curso'] as String? ?? '';
        String nameB = b['nombre_curso'] as String? ?? '';
        return _getSortPriority(nameA).compareTo(_getSortPriority(nameB));
      });
      setState(() => _courses = fetchedCourses);
    } catch (e) {
      setState(() => _errorMessage = 'Error loading courses: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //inicio del front
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //Boton flotante para atras
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: const Color(0xFFD9232A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_back_ios_new),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFD9232A),
                strokeWidth: 5.0,
              ),
            )
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          //Tarjetas principales
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200.0),
                //Barra
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100.0,
                      vertical: 0.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9232A),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'My courses',
                      style: GoogleFonts.ptSans(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    color: const Color(0xFFD9232A),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(24.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final c = _courses[index];
                        final title = c['nombre_curso'] as String? ?? 'Curso';
                        final id = (c['id'] as num).toInt();

                        // Lógica para asignar imagen y color (como en HomeScreen)
                        final String imagePath;
                        final Color color;
                        String lowerTitle = title.toLowerCase();

                        if (lowerTitle.contains('toefl')) {
                          imagePath = 'assets/images/icono_toefl_new.png';
                          color = const Color(0xFFD9232A);
                        } else if (lowerTitle.contains('ielts')) {
                          imagePath = 'assets/images/icono_ielts.png';
                          color = const Color(0xFF23408E);
                        } else if (lowerTitle.contains('business')) {
                          imagePath = 'assets/images/icono_business.png';
                          color = const Color(0xFFB02224);
                        } else {
                          imagePath = 'assets/images/icono_conversational.png';
                          color = const Color(0xFF1F3A89);
                        }

                        return _buildCourseCard(title, imagePath, color, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherSkillsScreen(
                                courseId: id,
                                courseName: title,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCourseCard(
    String title,
    String imagePath,
    Color color,
    VoidCallback onTap,
  ) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Título
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      title,
                      style: GoogleFonts.ptSans(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Imagen
                Center(
                  child: Image.asset(
                    imagePath,
                    height: 70,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
