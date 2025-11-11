import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/supabase_config.dart';
import 'student_detail_screen.dart';

class StudentRosterScreen extends StatefulWidget {
  const StudentRosterScreen({Key? key}) : super(key: key);

  @override
  State<StudentRosterScreen> createState() => _StudentRosterScreenState();
}

class _StudentRosterScreenState extends State<StudentRosterScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _students = [];
  String _query = '';
  List<Map<String, dynamic>> _plans = [];
  int? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await _loadPlans();
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      var query = supabase
          .from('usuarios')
          .select('id_usuario, nombre_completo, email, rol, es_docente, id_plan')
          .eq('rol', 'Estudiante');

      final selectedPlanId = _selectedPlanId; // evitar no-promoción de campos
      if (selectedPlanId != null) {
        query = query.eq('id_plan', selectedPlanId);
      }

      final response = await query.order('nombre_completo', ascending: true);

      setState(() => _students = List<Map<String, dynamic>>.from(response as List));
    } catch (e) {
      setState(() => _errorMessage = 'Error al cargar estudiantes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPlans() async {
    try {
      final res = await supabase
          .from('planes')
          .select('id_plan, nombre_plan')
          .order('id_plan', ascending: true);
      setState(() {
        _plans = List<Map<String, dynamic>>.from(res as List);
      });
    } catch (_) {
      // Silencioso: si falla, dejamos el filtro con opción "Todos" únicamente
      setState(() {
        _plans = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _students.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (s['nombre_completo'] as String? ?? '').toLowerCase().contains(q) ||
          (s['email'] as String? ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Estudiantes'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Reintentar'),
                        )
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Buscar estudiantes por nombre o email...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    // Filtro por plan
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              value: _selectedPlanId,
                              decoration: const InputDecoration(
                                labelText: 'Filtrar por plan',
                                border: OutlineInputBorder(),
                              ),
                              items: <DropdownMenuItem<int?>>[
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Todos los planes'),
                                ),
                                ..._plans.map((p) => DropdownMenuItem<int?>(
                                      value: (p['id_plan'] as num).toInt(),
                                      child: Text(p['nombre_plan'] as String? ?? 'Plan'),
                                    )),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedPlanId = val);
                                _load();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Limpiar filtro',
                            onPressed: _selectedPlanId == null
                                ? null
                                : () {
                                    setState(() => _selectedPlanId = null);
                                    _load();
                                  },
                            icon: const Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: filtered.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 120),
                                  Center(child: Text('No se encontraron estudiantes')),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final u = filtered[index];
                                  return _buildStudentCard(u);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> u) {
    final int? idPlan = (u['id_plan'] as num?)?.toInt();
    final String code = _planCodeById(idPlan);
    final Color badgeColor = _planColor(code);
    final int userId = (u['id_usuario'] as num).toInt();
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.15),
          child: const Icon(Icons.person, color: Colors.teal),
        ),
        title: Text(u['nombre_completo'] as String? ?? 'Sin nombre',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(u['email'] as String? ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: _planNameById(idPlan) ?? 'Plan',
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withOpacity(0.6)),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Copiar email',
              icon: const Icon(Icons.content_copy, color: Colors.grey),
              onPressed: () async {
                final email = (u['email'] as String?) ?? '';
                if (email.isEmpty) return;
                await Clipboard.setData(ClipboardData(text: email));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email copiado al portapapeles')),
                );
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Ver/editar estudiante',
              icon: const Icon(Icons.open_in_new, color: Colors.teal),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailScreen(userId: userId),
                  ),
                );
                if (mounted) {
                  _load();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _planCodeById(int? idPlan) {
    final name = _planNameById(idPlan)?.toLowerCase();
    if (name == null) return '?';
    if (name.contains('premium')) return 'P+';
    if (name.contains('pro')) return 'P';
    if (name.contains('básico') || name.contains('basico')) return 'B';
    if (name.contains('free') || name.contains('freemium') || name.contains('gratis')) return 'F';
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  String? _planNameById(int? idPlan) {
    if (idPlan == null) return null;
    try {
      final m = _plans.firstWhere((p) => (p['id_plan'] as num).toInt() == idPlan);
      return m['nombre_plan'] as String?;
    } catch (_) {
      return null;
    }
  }

  Color _planColor(String code) {
    switch (code) {
      case 'P+':
        return const Color(0xFFD9232A); // rojo premium
      case 'P':
        return const Color(0xFF23408E); // azul pro
      case 'B':
        return Colors.orange; // básico
      case 'F':
        return Colors.green; // freemium
      default:
        return Colors.grey;
    }
  }
}
