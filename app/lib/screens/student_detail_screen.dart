import 'package:flutter/material.dart';
import '../config/supabase_config.dart';

class StudentDetailScreen extends StatefulWidget {
  final int userId;
  const StudentDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _plans = [];
  int? _selectedPlanId;
  bool _saving = false;

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
      // Obtener usuario directo de Supabase
      final u = await supabase
          .from('usuarios')
          .select('id_usuario, nombre_completo, email, rol, es_docente, id_plan, fecha_registro')
          .eq('id_usuario', widget.userId)
          .maybeSingle();
      if (u == null) {
        throw Exception('No se encontró el estudiante');
      }

      // Obtener planes directo de Supabase
      final p = await supabase
          .from('planes')
          .select('id_plan, nombre_plan, precio')
          .order('precio');
      final plans = List<Map<String, dynamic>>.from(p as List);

      setState(() {
        _user = u;
        _plans = plans;
        _selectedPlanId = (u['id_plan'] ?? u['plan_id']) as int?;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedPlanId == null || _user == null) return;
    setState(() => _saving = true);
    try {
      // Actualizar directo en Supabase (RLS desactivado en usuarios)
      await supabase
          .from('usuarios')
          .update({'id_plan': _selectedPlanId})
          .eq('id_usuario', _user!['id_usuario']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan actualizado')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Estudiante'),
        backgroundColor: Colors.teal,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
      bottomNavigationBar: _user == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildContent() {
    final u = _user!;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.teal.withOpacity(0.15),
                  child: const Icon(Icons.person, color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (u['nombre_completo'] as String?) ?? 'Sin nombre',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text((u['email'] as String?) ?? ''),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip('Rol: ${u['rol'] ?? '—'}'),
                          _chip((u['es_docente'] == true) ? 'Docente' : 'Estudiante'),
                          if (u['fecha_registro'] != null)
                            _chip('Registro: ${(u['fecha_registro'] as String).split('T').first}'),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Text('Plan de suscripción', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedPlanId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: _plans
              .map((p) => DropdownMenuItem<int>(
                    value: p['id_plan'] as int,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p['nombre_plan'] as String? ?? ''),
                        Text(
                          (p['precio'] as num? ?? 0) == 0
                              ? 'Gratis'
                              : '\$${(p['precio'] as num).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedPlanId = v),
        ),

        const SizedBox(height: 24),
        const Text(
          'Nota: El cambio de plan actualiza los límites y beneficios disponibles para el estudiante de forma inmediata.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.teal)),
    );
  }
}
