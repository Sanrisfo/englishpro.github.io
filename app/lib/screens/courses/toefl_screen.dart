import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/skill_model.dart';
import '../skill_materials_screen.dart';
import '../../config/supabase_config.dart';
import 'package:google_fonts/google_fonts.dart';

class ToeflScreen extends StatefulWidget {
  const ToeflScreen({super.key});

  @override
  State<ToeflScreen> createState() => _ToeflScreenState();
}

class _ToeflScreenState extends State<ToeflScreen> {
  bool _loading = true;
  String? _error;
  int? _courseId;
  List<SkillModel> _skills = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final courseRow = await supabase
          .from('cursos')
          .select('*')
          .eq('nombre_curso', 'TOEFL')
          .maybeSingle();
      if (courseRow == null || (courseRow['id'] == null && courseRow['id_curso'] == null)) {
        setState(() { _error = 'Curso TOEFL no encontrado'; });
        return;
      }
      _courseId = (courseRow['id'] ?? courseRow['id_curso'] as num).toInt();

      final skillsRes = await ApiService.getSkillsByCourse(_courseId!);
      if (skillsRes['success'] != true) {
        setState(() { _error = skillsRes['message'] ?? 'No se pudieron cargar habilidades'; });
        return;
      }
      setState(() { _skills = skillsRes['skills'] as List<SkillModel>; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  // A partir de aqui comienza todo el front

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: const Color(0xFFD9232A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_back_ios_new),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          _buildHeaderBackground(textTheme),
          _buildContentPanel(textTheme),
        ],
      ),
    );
  }

  // Fondo rojo de arriba
  Widget _buildHeaderBackground(TextTheme textTheme) {
    return Container(
      height: 250,
      width: double.infinity,
      color: const Color(0xFFD9232A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOEFL',
                    style: GoogleFonts.ptSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The TOEFL test measures your academic English skills'
                        ' for university. Here you ll find everything you need '
                        'to prepare—practice questions, audio drills, and writing '
                        'guides—for all four sections.',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/images/icono_toefl_new.png',
                  height: 100,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Contenido
  Widget _buildContentPanel(TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(top: 220),
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),

      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _loading
                ? Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFD9232A),
                  strokeWidth: 5.0, // El default es 4.0
                ),
              ),
            )
                : _error != null
                ? Center(child: Text(_error!))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100.0,
                      vertical: 0.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9232A),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'Practice skills',
                      style: GoogleFonts.ptSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _skills.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final skill = _skills[index];
                    return _skillTile(skill, textTheme, index);
                  },
                ),
                const SizedBox(height: 80),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _skillTile(SkillModel skill, TextTheme textTheme, int index) {
    final color = (index % 2 == 0) ? const Color(0xFFD9232A) : const Color(0xFFB02224);
    final icon = _skillIcon(skill.nombre);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillMaterialsScreen(
              skillId: skill.id,
              skillName: skill.nombre,
              courseName: 'TOEFL',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            // Ícono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.nombre,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Flecha
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  IconData _skillIcon(String name) {
    switch (name.toLowerCase()) {
      case 'reading':
        return Icons.menu_book;
      case 'listening':
        return Icons.headphones;
      case 'speaking':
        return Icons.mic;
      case 'writing':
        return Icons.edit;
      default:
        return Icons.extension;
    }
  }
}
