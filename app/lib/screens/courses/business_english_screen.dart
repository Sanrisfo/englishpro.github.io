import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/skill_model.dart';
import '../activity_types_screen.dart';
import '../../config/supabase_config.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessEnglishScreen extends StatefulWidget {
  const BusinessEnglishScreen({super.key});

  @override
  State<BusinessEnglishScreen> createState() => _BusinessEnglishScreenState();
}

class _BusinessEnglishScreenState extends State<BusinessEnglishScreen> {
  bool _loading = true;
  String? _error;
  int? _courseId;
  List<SkillModel> _skills = [];

  // Theme color for Business English
  final Color _themeColor = const Color(0xFFB02224);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 1. Find the course ID for 'Business English'
      // We try exact match first, or 'Business' if that fails
      var courseRow = await supabase
          .from('cursos')
          .select('*')
          .eq('nombre_curso', 'Business English')
          .maybeSingle();

      if (courseRow == null) {
        // Fallback try
        courseRow = await supabase
            .from('cursos')
            .select('*')
            .ilike('nombre_curso', '%Business%') // Loose match if exact fails
            .limit(1)
            .maybeSingle();
      }

      int? cid;
      if (courseRow != null) {
        if (courseRow['id'] != null) {
          cid = (courseRow['id'] as num).toInt();
        } else if (courseRow['id_curso'] != null) {
          cid = (courseRow['id_curso'] as num).toInt();
        }
      }

      if (cid == null) {
        setState(() {
          _error = 'Business English Course not found';
        });
        return;
      }
      _courseId = cid;

      // 2. Load skills
      final skillsRes = await ApiService.getSkillsByCourse(_courseId!);
      if (skillsRes['success'] != true) {
        setState(() {
          _error = skillsRes['message'] ?? 'Could not load skills';
        });
        return;
      }
      setState(() {
        _skills = skillsRes['skills'] as List<SkillModel>;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: _themeColor,
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

  Widget _buildHeaderBackground(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40),
      constraints: const BoxConstraints(minHeight: 250),
      color: _themeColor,
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
                  'assets/images/icono_business.png',
                  height: 120,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Business English',
                    style: GoogleFonts.ptSans(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Master professional English for the workplace. '
                    'This section provides practice for presentations, '
                    'emails, negotiations, and interviews.',
                    style: GoogleFonts.ptSans(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                      height: 1.3,
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

  Widget _buildContentPanel(TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(top: 220),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _loading
                ? Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _themeColor,
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
                            color: _themeColor,
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
                      if (_skills.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No skills found for this course.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _skills.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final skill = _skills[index];
                            return _skillTile(skill, textTheme, index);
                          },
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _skillTile(SkillModel skill, TextTheme textTheme, int index) {
    final icon = _skillIcon(skill.nombre);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityTypesScreen(
              skillId: skill.id,
              skillName: skill.nombre,
              courseName: 'Business English',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _themeColor, size: 28),
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
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
      case 'vocabulary':
      case 'business vocabulary':
        return Icons.business_center;
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
                backgroundColor: _themeColor,
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
