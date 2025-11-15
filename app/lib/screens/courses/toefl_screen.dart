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
        setState(() { _error = 'TOEFL Course not found'; });
        return;
      }
      _courseId = (courseRow['id'] ?? courseRow['id_curso'] as num).toInt();

      final skillsRes = await ApiService.getSkillsByCourse(_courseId!);
      if (skillsRes['success'] != true) {
        setState(() { _error = skillsRes['message'] ?? 'Could not load skills'; });
        return;
      }
      setState(() { _skills = skillsRes['skills'] as List<SkillModel>; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  // A partir de aqui comienza tod el front

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
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40),
      constraints: const BoxConstraints(minHeight: 250),
      color: const Color(0xFFD9232A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              Positioned(
                right: -20,
                bottom: -20,
                child: Image.asset(
                  'assets/images/icono_toefl_new.png',
                  height: 120,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),

              // CONTENIDO DEL TEXTO
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    'The TOEFL test measures your academic English skills '
                        'for university. Here you ll find everything you need '
                        'to prepare—practice questions, audio drills, and writing '
                        'guides—for all four sections.',
                    style: GoogleFonts.ptSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                ],
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
                  strokeWidth: 5.0,
                ),
              ),
            )
                : _error != null
                ? _buildErrorView()
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'Practice skills',
                      style: GoogleFonts.ptSans(
                        color: Colors.white,
                        fontSize: 20,
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
    final color = (index % 2 == 0) ? const Color(0xFFD9232A) : const Color(
        0xFFD9232A);
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.nombre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9232A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}