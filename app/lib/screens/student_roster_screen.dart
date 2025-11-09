import 'package:flutter/material.dart';
import '../config/supabase_config.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await supabase
          .from('usuarios')
          .select('id_usuario, nombre_completo, email, rol, es_docente')
          .eq('rol', 'Estudiante')
          .order('nombre_completo', ascending: true);

      setState(() => _students = List<Map<String, dynamic>>.from(response as List));
    } catch (e) {
      setState(() => _errorMessage = 'Error al cargar estudiantes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      ),
    );
  }
}

