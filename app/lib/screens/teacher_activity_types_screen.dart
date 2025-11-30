import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'teacher_activities_screen.dart';

/// Tipos de actividad para una habilidad (vista docente).
class TeacherActivityTypesScreen extends StatefulWidget {
  final int skillId;
  final String skillName;
  final String courseName;

  const TeacherActivityTypesScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    required this.courseName,
  });

  @override
  State<TeacherActivityTypesScreen> createState() =>
      _TeacherActivityTypesScreenState();
}

class _TeacherActivityTypesScreenState
    extends State<TeacherActivityTypesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _types = [];
  late final Color _courseColor;

  final Color _mainBlue = const Color(0xFF23408E);

  ButtonStyle get _softButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: _mainBlue.withOpacity(0.1),
    foregroundColor: _mainBlue,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  ButtonStyle get _textButtonStyle =>
      TextButton.styleFrom(foregroundColor: _mainBlue);

  @override
  void initState() {
    super.initState();
    _courseColor = _getCourseColor(widget.courseName);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.getActivityTypesBySkill(widget.skillId);
      if (res['success'] == true) {
        final items = res['types'] as List<dynamic>;
        _types = items
            .map((e) => e is Map<String, dynamic>
            ? e
            : (e as dynamic).toJson() as Map<String, dynamic>)
            .toList();
      } else {
        _error = res['message'] ?? 'Could not load activity types';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  InputDecoration _dialogTextFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _mainBlue.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _createTypeDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int orden = (_types.length + 1);

    await showDialog(
      context: context,
      barrierColor: Colors.white38, // evita oscurecer el fondo de la pantalla
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // fondo transparente del dialogo
        insetPadding: const EdgeInsets.all(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, //fondo del recuadro
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create activity type',
                style: GoogleFonts.ptSans(
                  color: _mainBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: nameCtrl,
                decoration: _dialogTextFieldDecoration('Name'),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: descCtrl,
                decoration: _dialogTextFieldDecoration('Description'),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: _textButtonStyle,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: _softButtonStyle,
                    onPressed: () async {
                      final nombre = nameCtrl.text.trim();
                      if (nombre.isEmpty) return;

                      final r = await ApiService.createActivityType(
                        skillId: widget.skillId,
                        nombre: nombre,
                        descripcion: descCtrl.text.trim(),
                        orden: orden,
                      );

                      if (!mounted) return;

                      Navigator.pop(context);
                      if (r['success'] == true) {
                        await _load();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Type created')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              r['message'] ?? 'Error creating type',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Create'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _renameTypeDialog(Map<String, dynamic> t) async {
    final nameCtrl = TextEditingController(text: (t['nombre'] as String?) ?? '');
    final descCtrl = TextEditingController(text: (t['descripcion'] as String?) ?? '');

    await showDialog(
      context: context,
      barrierColor: Colors.white38, // evita oscurecer el fondo de la pantalla
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // fondo transparente del dialogo
        insetPadding: const EdgeInsets.all(30), // Margen exterior
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, // fondo del recuadro
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- TÍTULO ---
              Text(
                'Edit activity type',
                style: GoogleFonts.ptSans(
                  color: _mainBlue, // Asegúrate de tener definida esta variable o usa el color directo
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // --- CAMPOS DE TEXTO ---
              TextField(
                controller: nameCtrl,
                decoration: _dialogTextFieldDecoration('Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: _dialogTextFieldDecoration('Description'),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // --- BOTONES DE ACCIÓN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: _textButtonStyle,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: _softButtonStyle,
                    onPressed: () async {
                      final nombre = nameCtrl.text.trim();
                      // Lógica de ID original
                      final id = (t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0);

                      final r = await ApiService.updateActivityType(
                        id: id,
                        nombre: nombre.isEmpty ? null : nombre,
                        descripcion: descCtrl.text.trim(),
                      );

                      if (!mounted) return;

                      Navigator.pop(context); // Cierra el diálogo
                      if (r['success'] == true) {
                        await _load();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Type updated')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(r['message'] ?? 'Error updating type'),
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteType(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete activity type',
          style: GoogleFonts.ptSans(
            color: Color(0xFFD9232A),
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
            '¿Delete this activity type? This will also delete all its activities.'),

        actions: [
          TextButton(
            style: _textButtonStyle,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9232A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final r = await ApiService.deleteActivityType(id);
    if (r['success'] == true) {
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Type deleted')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(r['message'] ?? 'Error deleting type')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _loading ? null : _createTypeDialog,
            icon: const Icon(Icons.add),
            label: const Text('New type'),
            heroTag: null,
            backgroundColor: _mainBlue.withOpacity(0.1),
            foregroundColor: _mainBlue,
            elevation: 0,
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: const Color(0xFFD9232A),
            foregroundColor: Colors.white,
            heroTag: null,
            child: const Icon(Icons.arrow_back_ios_new),
          ),
        ],
      ),

      body: SafeArea(
        child: _loading
            ? Center(
          child: CircularProgressIndicator(
            color: _courseColor,
            strokeWidth: 5,
          ),
        )
            : _error != null
            ? Center(child: Text(_error!))
            : _types.isEmpty
            ? const Center(child: Text('No activity types found'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
              const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 0),
                      decoration: BoxDecoration(
                        color: _courseColor,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.skillName,
                        style: GoogleFonts.ptSans(
                          color: Colors.white,
                          fontSize: 20,

                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "My courses > ${widget.courseName} > ${widget.skillName} > Types",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                color: _courseColor,
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 0,
                    bottom: 150.0, //espacio para los botones
                  ),
                  itemCount: _types.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildTypeTile(
                      _types[index],
                      _courseColor,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTile(Map<String, dynamic> t, Color color) {
    final nombre = (t['nombre'] as String?) ?? 'Type';
    final id =
        (t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0);
    final desc = (t['descripcion'] as String?) ?? '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherActivitiesScreen(
              skillId: widget.skillId,
              skillName: widget.skillName,
              courseName: widget.courseName,
              activityTypeId: id,
              activityTypeName: nombre,
            ),
          ),
        ).then((_) => _load());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.category_rounded,
                  color: color, size: 28),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (desc.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
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

            IconButton(
              icon: Icon(Icons.mode_edit_outlined,
                  color: Color(0xFF23408E)),
              onPressed: () => _renameTypeDialog(t),
            ),
            IconButton(
              icon: const Icon(Icons.rule, color: Color(0xFF23408E)),
              tooltip: 'Allowed question types',
              onPressed: () => _editAllowedTypesDialog((t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0), nombre),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFFD9232A)),
              onPressed: () => _deleteType(id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editAllowedTypesDialog(int activityTypeId, String title) async {
    final all = const [
      'multiple_choice',
      'matching',
      'completion',
      'record_audio',
      'write_text',
    ];
    final current = await ApiService.getAllowedQuestionTypes(activityTypeId);
    final selected = {...current};

    final Color mainColor = const Color(0xFF23408E);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierColor: Colors.white38, // Evita oscurecer demasiado el fondo
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // Fondo transparente
        insetPadding: const EdgeInsets.all(50),
        child: Container(
          // Decoración del recuadro (Bordes, Sombra, Fondo Blanco)
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.fromLTRB(40,20,40,30),
          child: StatefulBuilder(
            // StatefulBuilder es necesario para redibujar los checkboxes dentro del Dialog
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título Estilizado
                  Text.rich(
                    TextSpan(
                      text: 'Allowed question types\n', // Parte 1 (Título principal)
                      style: GoogleFonts.ptSans(
                        color: mainColor, // El azul principal (0xFF23408E)
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: title, // Parte 2 (La variable con estilo diferente)
                          style: GoogleFonts.ptSans(
                            color: Colors.grey[600], // Color diferente (ej. gris)
                            fontSize: 16,            // Tamaño más pequeño
                            fontWeight: FontWeight.normal, // Letra normal (no bold)
                            height: 1.5,             // Un poco de espacio vertical
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Lista de Checkboxes
                  // Usamos Flexible por si la lista es muy larga en pantallas pequeñas
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: all.map((t) => CheckboxListTile(
                          activeColor: mainColor,
                          contentPadding: EdgeInsets.zero, // Más compacto
                          value: selected.contains(t),
                          title: Text(
                            t.replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 15),
                          ),
                          onChanged: (v) => setStateDialog(() {
                            if (v == true) {
                              selected.add(t);
                            } else {
                              selected.remove(t);
                            }
                          }),
                        )).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botones de Acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor.withOpacity(0.1), // Fondo suave
                          foregroundColor: mainColor, // Texto color principal
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () async {
                          final r = await ApiService.setAllowedQuestionTypes(
                            activityTypeId: activityTypeId,
                            allowed: selected.toList(),
                          );

                          if (!mounted) return;
                          Navigator.pop(context);

                          if (r['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: const Text('Allowed types saved'), backgroundColor: mainColor),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(r['message'] ?? 'Error saving allowed types')),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) {
      return const Color(0xFFD9232A);
    } else if (lower.contains('ielts')) {
      return const Color(0xFF23408E);
    } else if (lower.contains('business')) {
      return const Color(0xFFB02224);
    } else {
      return const Color(0xFF1F3A89);
    }
  }
}
