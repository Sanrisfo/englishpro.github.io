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
      backgroundColor: Colors.white,

      // Boton flotante
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
            color: const Color(0xFFD9232A),
            strokeWidth: 5.0,
          ),
        )
            : _error != null
            ? _buildErrorView()
            : _buildContent(),
      ),

      // --- BARRA DE BOTÓN REDISEÑADA ---
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
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9232A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Contenido (menu, titulo, tarjeta)
  Widget _buildContent() {
    final u = _user!;
    const Color noPlanColor = Color(0xFF23408E);

    //Tarjeta
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF23408E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline_outlined, color: const Color(0xFF23408E), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (u['nombre_completo'] as String?) ?? 'No name',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text((u['email'] as String?) ?? '', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('Role: ${u['rol'] ?? '—'}'),
                        _chip((u['es_docente'] == true) ? 'Teacher' : 'Student'),
                        if (u['fecha_registro'] != null)
                          _chip('Registered: ${(u['fecha_registro'] as String).split('T').first}'),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Titulo


        //Menu de subscripciones
        DropdownMenu<int?>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: _selectedPlanId,
          textStyle: const TextStyle(
            color: Color(0xFF23408E),
            fontSize: 16,
          ),
          onSelected: (val) {
            setState(() => _selectedPlanId = val);
          },

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF23408E).withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),

          menuStyle: MenuStyle(
            alignment: Alignment(0.3, 1.3),
            backgroundColor: WidgetStateProperty.all(Color(0xFFE8EBF1)),
            elevation: WidgetStateProperty.all(1),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.all(8.0)),
          ),


          dropdownMenuEntries: [
            // 1. Opción para "Sin Plan" (equivale a null)
            DropdownMenuEntry<int?>(
              value: null,
              label: 'No Plan',
              style: MenuItemButton.styleFrom(
                foregroundColor: noPlanColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),

            ..._plans.map((p) {
              final planName = p['nombre_plan'] as String? ?? 'Unnamed Plan';
              final price = p['precio'] as num? ?? 0;
              final priceLabel = price == 0 ? 'Free' : '\$${price.toStringAsFixed(2)}';

              return DropdownMenuEntry<int?>(
                value: (p['id_plan'] as num).toInt(),
                label: planName,
                style: MenuItemButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                labelWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(planName),
                    Text(priceLabel, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
            'Note: Changing the plan immediately updates the available limits and benefits for the student.',
            style: TextStyle(color: Color(0xFF7E7E81), fontStyle: FontStyle.italic),
          ),
        )
      ],
    );
  }

  //Save changes
  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD9232A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFD9232A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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