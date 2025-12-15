import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'teacher_activities_screen.dart';

/// Pantalla para que los docentes gestionen los tipos de actividad de una habilidad específica.
///
/// Un "tipo de actividad" es una categoría dentro de una habilidad, por ejemplo,
/// para la habilidad de "Writing", los tipos podrían ser "Ensayo" o "Email".
/// Esta pantalla permite ver, crear, editar y eliminar dichos tipos.
class TeacherActivityTypesScreen extends StatefulWidget {
  /// El ID de la habilidad a la que pertenecen los tipos de actividad.
  final int skillId;

  /// El nombre de la habilidad, para mostrar en la UI.
  final String skillName;

  /// El nombre del curso, para mostrar en el "breadcrumb".
  final String courseName;

  /// Crea una instancia de la pantalla de gestión de tipos de actividad.
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
  /// Indica si los datos se están cargando.
  bool _loading = true;

  /// Almacena un mensaje de error si la carga falla.
  String? _error;

  /// Lista de los tipos de actividad obtenidos del [ApiService].
  List<Map<String, dynamic>> _types = [];

  /// Color representativo del curso, usado para tematizar la UI.
  late final Color _courseColor;

  final Color _mainBlue = const Color(0xFF23408E);

  /// Estilo para botones con fondo suave.
  ButtonStyle get _softButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: _mainBlue.withOpacity(0.1),
    foregroundColor: _mainBlue,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  /// Estilo para botones de texto.
  ButtonStyle get _textButtonStyle =>
      TextButton.styleFrom(foregroundColor: _mainBlue);

  @override
  void initState() {
    super.initState();
    _courseColor = _getCourseColor(widget.courseName);
    _load();
  }

  /// Carga la lista de tipos de actividad desde [ApiService].
  ///
  /// Maneja los estados de carga y error para la UI.
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
        _error = res['message'] ?? 'No se pudieron cargar los tipos de actividad';
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

  /// Decoración estándar para los campos de texto en los diálogos.
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

  /// Muestra un diálogo para crear un nuevo tipo de actividad.
  Future<void> _createTypeDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int orden = (_types.length + 1);

    await showDialog(
      context: context,
      barrierColor: Colors.white38,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Crear Tipo de Actividad',
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
                decoration: _dialogTextFieldDecoration('Nombre'),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: descCtrl,
                decoration: _dialogTextFieldDecoration('Descripción'),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: _textButtonStyle,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
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
                          const SnackBar(content: Text('Tipo creado')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              r['message'] ?? 'Error al crear el tipo',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Crear'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo para renombrar un tipo de actividad existente.
  /// @param t El mapa de datos del tipo de actividad a editar.
  Future<void> _renameTypeDialog(Map<String, dynamic> t) async {
    final nameCtrl = TextEditingController(text: (t['nombre'] as String?) ?? '');
    final descCtrl = TextEditingController(text: (t['descripcion'] as String?) ?? '');

    await showDialog(
      context: context,
      barrierColor: Colors.white38,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(30),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar Tipo de Actividad',
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
                decoration: _dialogTextFieldDecoration('Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: _dialogTextFieldDecoration('Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: _textButtonStyle,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: _softButtonStyle,
                    onPressed: () async {
                      final nombre = nameCtrl.text.trim();
                      final id = (t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0);

                      final r = await ApiService.updateActivityType(
                        id: id,
                        nombre: nombre.isEmpty ? null : nombre,
                        descripcion: descCtrl.text.trim(),
                      );

                      if (!mounted) return;

                      Navigator.pop(context);
                      if (r['success'] == true) {
                        await _load();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tipo actualizado')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(r['message'] ?? 'Error al actualizar el tipo'),
                          ),
                        );
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación para eliminar un tipo de actividad.
  /// @param id El ID del tipo de actividad a eliminar.
  Future<void> _deleteType(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Eliminar Tipo de Actividad',
          style: GoogleFonts.ptSans(
            color: const Color(0xFFD9232A),
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
            '¿Eliminar este tipo de actividad? Esto también eliminará todas sus actividades asociadas.'),
        actions: [
          TextButton(
            style: _textButtonStyle,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9232A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
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
            const SnackBar(content: Text('Tipo eliminado')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(r['message'] ?? 'Error al eliminar el tipo')),
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
            label: const Text('Nuevo Tipo'),
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
                    ? const Center(child: Text('No se encontraron tipos de actividad'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 0),
                                    decoration: BoxDecoration(
                                      color: _courseColor,
                                      borderRadius: BorderRadius.circular(10),
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
                                  "Mis Cursos > ${widget.courseName} > ${widget.skillName} > Tipos",
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
                                  bottom: 150.0,
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

  /// Construye una tarjeta (tile) para un tipo de actividad.
  Widget _buildTypeTile(Map<String, dynamic> t, Color color) {
    final nombre = (t['nombre'] as String?) ?? 'Tipo';
    final id = (t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0);
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
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.category_rounded, color: color, size: 28),
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
              icon: Icon(Icons.mode_edit_outlined, color: Color(0xFF23408E)),
              onPressed: () => _renameTypeDialog(t),
            ),
            IconButton(
              icon: const Icon(Icons.rule, color: Color(0xFF23408E)),
              tooltip: 'Tipos de pregunta permitidos',
              onPressed: () => _editAllowedTypesDialog((t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0), nombre),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD9232A)),
              onPressed: () => _deleteType(id),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un diálogo para editar los tipos de pregunta permitidos para un tipo de actividad.
  /// @param activityTypeId El ID del tipo de actividad a configurar.
  /// @param title El nombre del tipo de actividad para mostrar en el título del diálogo.
  Future<void> _editAllowedTypesDialog(int activityTypeId, String title) async {
    const all = [
      'multiple_choice',
      'matching',
      'completion',
      'record_audio',
      'write_text',
    ];
    final current = await ApiService.getAllowedQuestionTypes(activityTypeId);
    final selected = {...current};

    const Color mainColor = Color(0xFF23408E);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierColor: Colors.white38,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(50),
        child: Container(
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
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 30),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Tipos de pregunta permitidos\n',
                      style: GoogleFonts.ptSans(
                        color: mainColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: title,
                          style: GoogleFonts.ptSans(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: all.map((t) => CheckboxListTile(
                          activeColor: mainColor,
                          contentPadding: EdgeInsets.zero,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor.withOpacity(0.1),
                          foregroundColor: mainColor,
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
                              SnackBar(content: const Text('Tipos permitidos guardados'), backgroundColor: mainColor),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(r['message'] ?? 'Error al guardar los tipos')),
                            );
                          }
                        },
                        child: const Text('Guardar'),
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

  /// Determina el color a usar basado en el nombre del curso.
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
