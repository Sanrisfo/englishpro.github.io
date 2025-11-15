import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import 'teacher_activities_screen.dart';
import 'teacher_activity_types_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Color principal para los íconos (basado en el tema del curso)
  late final Color _courseColor;

  @override
  void initState() {
    super.initState();
    // Asignamos el color del tema basado en el nombre del curso
    _courseColor = _getCourseColor(widget.courseName);
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
      // --- CORRECCIÓN: Mensaje estándar ---
      setState(() => _errorMessage = 'Error loading skills: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- CORRECCIÓN: Botón flotante estándar ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: const Color(0xFFD9232A), // Rojo
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_back_ios_new),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // --- CORRECCIÓN: Sin AppBar, usamos SafeArea ---
      body: SafeArea(
        child: _isLoading
        // --- CORRECCIÓN: Indicador de carga estándar ---
            ? Center(
          child: CircularProgressIndicator(
            color: _courseColor, // Color del curso
            strokeWidth: 5.0,
          ),
        )
        // --- CORRECCIÓN: Manejo de error estándar ---
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
        // --- CORRECCIÓN: Layout con cabecera y lista ---
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera personalizada
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Barra
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100.0,
                        vertical: 0.0,
                      ),
                      decoration: BoxDecoration(
                          color: _courseColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        widget.courseName,
                        style: GoogleFonts.ptSans(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "My courses > " + widget.courseName + " > Skills",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Lista de skills
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _skills.length,
                itemBuilder: (context, index) {
                  final s = _skills[index];
                  // Llamamos a nuestro _buildSkillTile estándar
                  return _buildSkillTile(s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSkillTile(Map<String, dynamic> s) {
    final id = s['id_habilidad'] as int;
    final name = s['nombre_habilidad'] as String? ?? 'Skill';
    final desc = s['descripcion'] as String? ?? '';
    final icon = _skillIcon(name); // Icono basado en nombre

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherActivityTypesScreen(
              skillId: id,
              skillName: name,
              courseName: widget.courseName,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Separador
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            // Ícono (Estilo estándar)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _courseColor.withOpacity(0.1), // Color del curso
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _courseColor, size: 28), // Color del curso
            ),
            const SizedBox(width: 16),

            // Textos (Estilo estándar)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (desc.isNotEmpty) // Oculta si no hay descripción
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Flecha (Estilo estándar)
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Asigna un icono basado en el nombre del skill
  IconData _skillIcon(String name) {
    switch (name.toLowerCase()) {
      case 'reading':
        return Icons.chrome_reader_mode;
      case 'listening':
        return Icons.headphones_rounded;
      case 'speaking':
        return Icons.mic_rounded;
      case 'writing':
        return Icons.text_fields;
      default:
        return Icons.extension;
    }
  }

  // Asigna un color basado en el nombre del curso
  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) {
      return const Color(0xFFD9232A); // Rojo
    } else if (lower.contains('ielts')) {
      return const Color(0xFF23408E); // Azul
    } else if (lower.contains('business')) {
      return const Color(0xFFB02224); // Rojo Oscuro
    } else {
      return const Color(0xFF1F3A89); // Azul Oscuro
    }
  }
}
