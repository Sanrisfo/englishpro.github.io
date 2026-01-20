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
          .select(
            'id_usuario, nombre_completo, email, rol, es_docente, id_plan, supabase_uid',
          )
          .eq('rol', 'Estudiante');

      final selectedPlanId = _selectedPlanId;
      if (selectedPlanId != null) {
        query = query.eq('id_plan', selectedPlanId);
      }
      final response = await query.order('nombre_completo', ascending: true);
      setState(
        () => _students = List<Map<String, dynamic>>.from(response as List),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error loading students: $e');
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
      return (s['nombre_completo'] as String? ?? '').toLowerCase().contains(
            q,
          ) ||
          (s['email'] as String? ?? '').toLowerCase().contains(q);
    }).toList();

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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFD9232A),
                  strokeWidth: 5.0,
                ),
              )
            : _errorMessage != null
            ? _buildErrorView()
            : Column(
                children: [
                  _buildSearchBar(),
                  _buildPlanFilter(),

                  const SizedBox(height: 8),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      color: const Color(0xFFD9232A),
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final u = filtered[index];
                                return _buildStudentTile(
                                  u,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Color(0xFF23408E)),
          hintText: 'Search students by name or email',
          hintStyle: TextStyle(color: Color(0xFF23408E)),
          filled: true,
          fillColor: Color(0xFF23408E).withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) => setState(() => _query = v),
      ),
    );
  }

  Widget _buildPlanFilter() {
    const Color allPlansColor = Color(0xFF23408E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<int?>(
              expandedInsets: EdgeInsets.zero,
              textStyle: const TextStyle(
                color: Color(0xFF23408E),
                fontSize: 16,
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

              initialSelection: _selectedPlanId,
              onSelected: (val) {
                setState(() => _selectedPlanId = val);
                _load();
              },

              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFF23408E).withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),

              dropdownMenuEntries: [
                DropdownMenuEntry<int?>(
                  value: null,
                  label: 'All plans',
                  style: MenuItemButton.styleFrom(
                    foregroundColor: allPlansColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                ..._plans.map(
                  (p) => DropdownMenuEntry<int?>(
                    value: (p['id_plan'] as num).toInt(),
                    label: p['nombre_plan'] as String? ?? 'Plan',
                    style: MenuItemButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Clear filter',
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
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> u) {
    final int? idPlan = (u['id_plan'] as num?)?.toInt();
    final String code = _planCodeById(idPlan);
    final Color badgeColor = _planColor(code);
    final int userId = (u['id_usuario'] as num).toInt();

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailScreen(userId: userId),
          ),
        );
        if (mounted) _load();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                color: const Color(0xFF23408E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_outline_outlined,
                color: const Color(0xFF23408E),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u['nombre_completo'] as String? ?? 'No name',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u['email'] as String? ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            Tooltip(
              message: _planNameById(idPlan) ?? 'Plan',
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
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
            IconButton(
              tooltip: 'Copy email',
              icon: const Icon(
                Icons.content_copy,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () async {
                final email = (u['email'] as String?) ?? '';
                if (email.isEmpty) return;
                await Clipboard.setData(ClipboardData(text: email));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Email copied to clipboard',
                      style: TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                    backgroundColor: const Color(0xFF23408E),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Delete student',
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () => _confirmDeleteUser(context, u),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.search_off, color: Colors.indigo, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              'No students found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
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
              _errorMessage!,
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

  String _planCodeById(int? idPlan) {
    final name = _planNameById(idPlan)?.toLowerCase();
    if (name == null) return '?';
    if (name.contains('premium')) return 'P+';
    if (name.contains('pro')) return 'P';
    if (name.contains('básico') || name.contains('basico')) return 'B';
    if (name.contains('free') ||
        name.contains('freemium') ||
        name.contains('gratis'))
      return 'F';
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  String? _planNameById(int? idPlan) {
    if (idPlan == null) return null;
    try {
      final m = _plans.firstWhere(
        (p) => (p['id_plan'] as num).toInt() == idPlan,
      );
      return m['nombre_plan'] as String?;
    } catch (_) {
      return null;
    }
  }

  Color _planColor(String code) {
    switch (code) {
      case 'P+':
        return const Color(0xFFA60F12);
      case 'P':
        return const Color(0xFFDC242B);
      case 'B':
        return const Color(0xFF23408E);
      case 'F':
        return const Color(0xFF7E7E81);
      default:
        return Colors.grey;
    }
  }

  Future<void> _confirmDeleteUser(
      BuildContext context, Map<String, dynamic> student) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to delete student ${student['nombre_completo'] ?? ''}?'),
                const Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(student);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(Map<String, dynamic> student) async {
    final supabaseUid = student['supabase_uid'] as String?;
    if (supabaseUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete user: Missing Supabase UID.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await supabase.rpc('delete_student', params: {'student_id': supabaseUid});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result as String? ?? 'Student deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      await _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
