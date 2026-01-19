import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'activity_list_screen.dart';

/// Pantalla que muestra los tipos de actividad disponibles para una habilidad específica.
///
/// Este widget `Stateful` está diseñado para el flujo del estudiante. Carga y
/// muestra una lista de categorías de actividades (ej. "Gramática", "Vocabulario")
/// para la habilidad seleccionada. Al tocar un tipo, navega a [ActivityListScreen]
/// para mostrar las actividades correspondientes.
class ActivityTypesScreen extends StatefulWidget {
  /// El ID de la habilidad de la que se mostrarán los tipos de actividad.
  final int skillId;

  /// El nombre de la habilidad, usado para la UI (ej. en el encabezado).
  final String skillName;

  /// El nombre del curso, usado para la UI (ej. en el "breadcrumb").
  final String courseName;

  /// Crea una instancia de la pantalla de tipos de actividad.
  const ActivityTypesScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    required this.courseName,
  });

  @override
  State<ActivityTypesScreen> createState() => _ActivityTypesScreenState();
}

class _ActivityTypesScreenState extends State<ActivityTypesScreen> {
  /// Indica si los datos se están cargando.
  bool _loading = true;

  /// Almacena un mensaje de error si la carga falla.
  String? _error;

  /// Lista de los tipos de actividad obtenidos del [ApiService].
  List<Map<String, dynamic>> _types = [];

  /// Color temático del curso, usado para estilizar la UI.
  late final Color _courseColor;

  @override
  void initState() {
    super.initState();
    _courseColor = _getCourseColor(widget.courseName);
    _load();
  }

  /// Carga la lista de tipos de actividad desde el [ApiService].
  ///
  /// Actualiza el estado para reflejar el proceso de carga y maneja
  /// los posibles errores durante la obtención de datos.
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
            .map(
              (e) => e is Map<String, dynamic>
                  ? e
                  : (e as dynamic).toJson() as Map<String, dynamic>,
            )
            .toList();
      } else {
        _error = res['message'] ?? 'No se encontraron tipos de actividad';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  /// Determina el color a usar basado en el nombre del curso.
  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) return const Color(0xFFD9232A);
    if (lower.contains('ielts')) return const Color(0xFF23408E);
    if (lower.contains('business')) return const Color(0xFFB02224);
    return const Color(0xFF1F3A89);
  }

  @override
  Widget build(BuildContext context) {
    final breadcrumb =
        "Mis Cursos > ${widget.courseName} > ${widget.skillName} > Tipos";

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: const Color(0xFFD9232A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_back_ios_new),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: _courseColor,
                  strokeWidth: 5.0,
                ),
              )
            : _error != null
            ? Center(child: Text(_error!))
            : _types.isEmpty
            ? const Center(child: Text('No se encontraron tipos de actividad'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(breadcrumb),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      color: _courseColor,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 0,
                          bottom: 100,
                        ),
                        itemCount: _types.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final t = _types[index];
                          return _buildTypeTile(t);
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Construye el encabezado de la pantalla, que incluye el logo, el título y el breadcrumb.
  Widget _buildHeader(String breadcrumb) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logo_completo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 0.0,
                ),
                decoration: BoxDecoration(
                  color: _courseColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  widget.skillName,
                  style: GoogleFonts.ptSans(color: Colors.white, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            breadcrumb,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta (tile) para un tipo de actividad, que al ser presionada
  /// navega a la pantalla [ActivityListScreen].
  Widget _buildTypeTile(Map<String, dynamic> t) {
    final nombre = (t['nombre'] as String?) ?? 'Tipo';
    final id = (t['id'] as int?) ?? (t['id_tipo_actividad'] as int? ?? 0);
    final desc = (t['descripcion'] as String?) ?? '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityListScreen(
              skillId: widget.skillId,
              activityTypeId: id,
              skillName: widget.skillName,
              courseName: widget.courseName,
              activityTypeName: nombre,
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
                color: _courseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.category_rounded,
                color: _courseColor,
                size: 28,
              ),
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
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
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
}
