import 'package:flutter/material.dart';
import '../config/supabase_config.dart';

class TeacherQuestionsScreen extends StatefulWidget {
  final int quizId;
  final int skillId;
  final String quizTitle;

  const TeacherQuestionsScreen({
    Key? key,
    required this.quizId,
    required this.skillId,
    required this.quizTitle,
  }) : super(key: key);

  @override
  State<TeacherQuestionsScreen> createState() => _TeacherQuestionsScreenState();
}

class _TeacherQuestionsScreenState extends State<TeacherQuestionsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _items = [];

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
      // 1) get question ids for this quiz with order
      final cp = await supabase
          .from('cuestionario_preguntas')
          .select('id_pregunta, orden')
          .eq('id_cuestionario', widget.quizId)
          .order('orden', ascending: true);
      final cpList = List<Map<String, dynamic>>.from(cp as List);
      if (cpList.isEmpty) {
        setState(() => _items = []);
        return;
      }
      final ids = cpList.map((e) => e['id_pregunta']).where((e) => e != null).toList();

      // 2) fetch questions and embed options
      final qs = await supabase
          .from('preguntas')
          .select('id_pregunta, texto_pregunta, tipo_pregunta, nivel_dificultad, puntos')
          .inFilter('id_pregunta', ids);
      final qList = List<Map<String, dynamic>>.from(qs as List);

      // 3) fetch options for all questions
      final opts = await supabase
          .from('opciones_respuesta')
          .select('id_opcion, id_pregunta, texto_opcion, es_correcta, orden')
          .inFilter('id_pregunta', ids)
          .order('orden', ascending: true);
      final optList = List<Map<String, dynamic>>.from(opts as List);

      // 4) merge by id and order
      final byId = {
        for (final q in qList) q['id_pregunta']: {
          ...q,
          'opciones': optList.where((o) => o['id_pregunta'] == q['id_pregunta']).toList(),
        }
      };
      final items = <Map<String, dynamic>>[];
      for (final row in cpList) {
        final qid = row['id_pregunta'];
        final orden = row['orden'];
        final q = byId[qid];
        if (q != null) items.add({'orden': orden, ...q});
      }
      setState(() => _items = items);
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando preguntas: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createQuestionDialog() async {
    final textCtrl = TextEditingController();
    final pointsCtrl = TextEditingController(text: '1');
    String nivel = 'Basico';
    // Multiple Choice fijo según UX
    final optCtrls = List.generate(4, (_) => TextEditingController());
    int correctIndex = 0;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Crear Pregunta (Multiple Choice)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(labelText: 'Texto de la pregunta'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pointsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Puntos'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: nivel,
                    decoration: const InputDecoration(labelText: 'Nivel de dificultad'),
                    items: const [
                      DropdownMenuItem(value: 'Basico', child: Text('Básico')),
                      DropdownMenuItem(value: 'Intermedio', child: Text('Intermedio')),
                      DropdownMenuItem(value: 'Avanzado', child: Text('Avanzado')),
                    ],
                    onChanged: (v) => setStateDialog(() => nivel = v ?? 'Basico'),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Opciones (elige la correcta)', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < 4; i++)
                    Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctIndex,
                          onChanged: (v) => setStateDialog(() => correctIndex = v ?? 0),
                        ),
                        Expanded(
                          child: TextField(
                            controller: optCtrls[i],
                            decoration: InputDecoration(labelText: 'Opción ${i + 1}'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final texto = textCtrl.text.trim();
                    if (texto.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texto requerido')));
                      return;
                    }
                    if (optCtrls.any((c) => c.text.trim().isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todas las opciones son requeridas')));
                      return;
                    }
                    final puntos = int.tryParse(pointsCtrl.text.trim()) ?? 1;

                    // 1) create question in Preguntas
                    final insertedQ = await supabase
                        .from('preguntas')
                        .insert({
                          'id_habilidad': widget.skillId,
                          'texto_pregunta': texto,
                          'tipo_pregunta': 'Multiple Choice',
                          'puntos': puntos,
                          'nivel_dificultad': nivel,
                        })
                        .select()
                        .single();

                    final qid = insertedQ['id_pregunta'] as int;

                    // 2) insert 4 options
                    final optionsPayload = <Map<String, dynamic>>[];
                    for (int i = 0; i < 4; i++) {
                      optionsPayload.add({
                        'id_pregunta': qid,
                        'texto_opcion': optCtrls[i].text.trim(),
                        'es_correcta': i == correctIndex,
                        'orden': i + 1,
                      });
                    }
                    await supabase.from('opciones_respuesta').insert(optionsPayload);

                    // 3) link to quiz in Cuestionario_Preguntas with next order
                    final current = await supabase
                        .from('cuestionario_preguntas')
                        .select('id_pregunta')
                        .eq('id_cuestionario', widget.quizId);
                    final nextOrder = (current as List).length + 1;
                    await supabase.from('cuestionario_preguntas').insert({
                      'id_cuestionario': widget.quizId,
                      'id_pregunta': qid,
                      'orden': nextOrder,
                    });

                    if (!mounted) return;
                    Navigator.pop(context);
                    await _load();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pregunta creada')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteQuestion(int questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('Esta acción eliminará la pregunta y sus opciones.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await supabase.from('preguntas').delete().eq('id_pregunta', questionId);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pregunta eliminada')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas · ${widget.quizTitle}'),
        backgroundColor: Colors.deepPurple,
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _createQuestionDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Pregunta'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _items.isEmpty
                  ? const Center(child: Text('No hay preguntas'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final q = _items[index];
                          return _buildQuestionCard(q);
                        },
                      ),
                    ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    final orden = q['orden'] as int?;
    final texto = q['texto_pregunta'] as String? ?? '';
    final nivel = q['nivel_dificultad'] as String? ?? '';
    final puntos = q['puntos'] as int? ?? 1;
    final opciones = (q['opciones'] as List?) ?? const [];
    final qid = q['id_pregunta'] as int;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  orden != null ? '#$orden' : '#',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(qid),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Nivel: $nivel • Puntos: $puntos', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text('Opciones:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...opciones.map((o) {
              final correct = o['es_correcta'] == true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Icon(correct ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16, color: correct ? Colors.green : Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(o['texto_opcion'] as String? ?? '')),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
