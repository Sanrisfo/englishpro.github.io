import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/skill_model.dart';
import '../../config/supabase_config.dart';
import '../skill_materials_screen.dart';

class IeltsScreen extends StatefulWidget {
  const IeltsScreen({super.key});

  @override
  State<IeltsScreen> createState() => _IeltsScreenState();
}

class _IeltsScreenState extends State<IeltsScreen> {
  bool _loading = true;
  String? _error;
  int? _courseId; // IELTS course id
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
          .eq('nombre_curso', 'IELTS')
          .maybeSingle();
      int? cid;
      if (courseRow != null) {
        if (courseRow['id'] != null) {
          cid = (courseRow['id'] as num).toInt();
        } else if (courseRow['id_curso'] != null) {
          cid = (courseRow['id_curso'] as num).toInt();
        }
      }
      if (cid == null) {
        setState(() { _error = 'Curso IELTS no encontrado'; });
        return;
      }
      _courseId = cid;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Preparation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _headerCard(),
                    const SizedBox(height: 24),
                    const Text('Practice Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._skills.map((s) => _skillTile(s)).toList(),
                  ],
                ),
    );
  }

  Widget _headerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.library_books, size: 60, color: Colors.white),
            SizedBox(height: 16),
            Text('IELTS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('International English Language Testing System', style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _skillTile(SkillModel skill) {
    final icon = _skillIcon(skill.nombre);
    final color = _skillColor(skill.nombre);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(skill.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(skill.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkillMaterialsScreen(
                skillId: skill.id,
                skillName: skill.nombre,
                courseName: 'IELTS',
              ),
            ),
          );
        },
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

  Color _skillColor(String name) {
    switch (name.toLowerCase()) {
      case 'reading':
        return Colors.blue;
      case 'listening':
        return Colors.green;
      case 'speaking':
        return Colors.orange;
      case 'writing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
