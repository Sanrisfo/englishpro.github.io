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
  int? _activityTypeId;
  List<String> _allowedTypes = const [];

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
      // 1) get quiz activity type and allowed question types (always load, even if no questions yet)
      try {
        final quizRow = await supabase
            .from('cuestionarios')
            .select('id_tipo_actividad, titulo')
            .eq('id_cuestionario', widget.quizId)
            .single();
        _activityTypeId = (quizRow['id_tipo_actividad'] as num?)?.toInt();
        final localTypeId = _activityTypeId;
        if (localTypeId != null) {
          final rows = await supabase
              .from('tipo_actividad_pregunta_permitida')
              .select('tipo_pregunta')
              .eq('id_tipo_actividad', localTypeId);
          _allowedTypes = List<Map<String, dynamic>>.from(rows as List)
              .map((e) => (e['tipo_pregunta'] as String).toLowerCase())
              .toList();
        }
      } catch (_) {}

      // 2) get question ids for this quiz with order
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

      // 3) fetch questions and embed options
      final qs = await supabase
          .from('preguntas')
          .select('id_pregunta, texto_pregunta, tipo_pregunta, nivel_dificultad, puntos, explicacion')
          .inFilter('id_pregunta', ids);
      final qList = List<Map<String, dynamic>>.from(qs as List);

      // 4) fetch options for all questions
      final opts = await supabase
          .from('opciones_respuesta')
          .select('id_opcion, id_pregunta, texto_opcion, es_correcta, orden')
          .inFilter('id_pregunta', ids)
          .order('orden', ascending: true);
      final optList = List<Map<String, dynamic>>.from(opts as List);

      // 5) merge by id and order
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
    final explanationCtrl = TextEditingController();

    final allTypes = const ['multiple_choice', 'matching', 'completion', 'record_audio', 'write_text'];
    final availableTypes = _allowedTypes.isEmpty ? allTypes : _allowedTypes;
    String type = availableTypes.first;

    // MC
    List<TextEditingController> mcOptCtrls = [TextEditingController(), TextEditingController(), TextEditingController()];
    final Set<int> mcCorrect = {};
    // Matching
    List<TextEditingController> matchAnswersCtrls = [TextEditingController(), TextEditingController(), TextEditingController()];
    List<Map<String, dynamic>> matchStatements = [
      {'text': TextEditingController(), 'answer': null},
      {'text': TextEditingController(), 'answer': null},
      {'text': TextEditingController(), 'answer': null},
    ];
    // Completion
    List<Map<String, TextEditingController>> completionRows = List.generate(5, (_) => {'sentence': TextEditingController(), 'correct': TextEditingController()});
    // Write Text
    final maxWordsCtrl = TextEditingController(text: '120');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Crear Pregunta'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Tipo de pregunta'),
                    items: availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ')))).toList(),
                    onChanged: (v) => setStateDialog(() => type = v ?? type),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Texto de la pregunta'), maxLines: 3),
                  const SizedBox(height: 8),
                  TextField(controller: explanationCtrl, decoration: const InputDecoration(labelText: 'Explicación general (opcional)'), maxLines: 3),
                  const SizedBox(height: 8),
                  TextField(controller: pointsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Puntos')),
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
                  if (_allowedTypes.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tipos permitidos en esta actividad: ${_allowedTypes.map((e) => e.replaceAll('_',' ')).join(', ')}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  if (type == 'multiple_choice') ...[
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Opciones (3 a 5)', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextButton.icon(onPressed: mcOptCtrls.length < 5 ? () => setStateDialog(() => mcOptCtrls.add(TextEditingController())) : null, icon: const Icon(Icons.add), label: const Text('Agregar')),
                    ]),
                    ...mcOptCtrls.asMap().entries.map((e) => Row(children: [
                          Checkbox(value: mcCorrect.contains(e.key), onChanged: (v) => setStateDialog(() => v == true ? mcCorrect.add(e.key) : mcCorrect.remove(e.key))),
                          Expanded(child: TextField(controller: e.value, decoration: InputDecoration(labelText: 'Opción ${e.key + 1}'))),
                          IconButton(icon: const Icon(Icons.close), onPressed: mcOptCtrls.length > 3 ? () => setStateDialog(() { mcCorrect.remove(e.key); mcOptCtrls.removeAt(e.key); }) : null),
                        ])),
                  ]
                  else if (type == 'matching') ...[
                    const Align(alignment: Alignment.centerLeft, child: Text('Respuestas (B) 1..7', style: TextStyle(fontWeight: FontWeight.w600))),
                    ...matchAnswersCtrls.asMap().entries.map((e) => Row(children: [
                          Expanded(child: TextField(controller: e.value, decoration: InputDecoration(labelText: 'Respuesta B${e.key + 1}'))),
                          IconButton(icon: const Icon(Icons.close), onPressed: matchAnswersCtrls.length > 1 ? () => setStateDialog(() => matchAnswersCtrls.removeAt(e.key)) : null),
                        ])),
                    Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: matchAnswersCtrls.length < 7 ? () => setStateDialog(() => matchAnswersCtrls.add(TextEditingController())) : null, icon: const Icon(Icons.add), label: const Text('Agregar respuesta'))),
                    const SizedBox(height: 8),
                    const Align(alignment: Alignment.centerLeft, child: Text('Enunciados (A) 1..5', style: TextStyle(fontWeight: FontWeight.w600))),
                    ...matchStatements.asMap().entries.map((e) {
                      final i = e.key; final row = e.value;
                      return Row(children: [
                        Expanded(child: TextField(controller: row['text'], decoration: InputDecoration(labelText: 'Enunciado A${i + 1}'))),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: row['answer'] as int?, hint: const Text('B?'),
                          items: matchAnswersCtrls.asMap().entries.map((a) => DropdownMenuItem(value: a.key, child: Text('B${a.key + 1}'))).toList(),
                          onChanged: (v) => setStateDialog(() => row['answer'] = v),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: matchStatements.length > 1 ? () => setStateDialog(() => matchStatements.removeAt(i)) : null),
                      ]);
                    }),
                    Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: matchStatements.length < 5 ? () => setStateDialog(() => matchStatements.add({'text': TextEditingController(), 'answer': null})) : null, icon: const Icon(Icons.add), label: const Text('Agregar enunciado'))),
                  ]
                  else if (type == 'completion') ...[
                    const Align(alignment: Alignment.centerLeft, child: Text('Completion (5..6)', style: TextStyle(fontWeight: FontWeight.w600))),
                    const Align(alignment: Alignment.centerLeft, child: Text('Escribe la oración completa y la palabra que será el gap. Nosotros generamos los espacios automáticamente.')),
                    ...completionRows.asMap().entries.map((e) => Row(children: [
                          Expanded(child: TextField(controller: e.value['sentence'], decoration: InputDecoration(labelText: 'Oración ${e.key + 1}'))),
                          const SizedBox(width: 8),
                          SizedBox(width: 180, child: TextField(controller: e.value['correct'], decoration: const InputDecoration(labelText: 'Palabra (gap)'))),
                        ])),
                    Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: completionRows.length < 6 ? () => setStateDialog(() => completionRows.add({'sentence': TextEditingController(), 'correct': TextEditingController()})) : null, icon: const Icon(Icons.add), label: const Text('Agregar oración'))),
                  ]
                  else if (type == 'write_text') ...[
                    TextField(controller: maxWordsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Máximo de palabras')),
                  ]
                  else if (type == 'record_audio') ...[
                    const Text('El estudiante grabará audio (hasta 45s).'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  final texto = textCtrl.text.trim();
                  if (texto.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texto requerido'))); return; }
                  final puntos = int.tryParse(pointsCtrl.text.trim()) ?? 1;
                  try {
                    if (type == 'multiple_choice') {
                      final nonEmpty = mcOptCtrls.where((c) => c.text.trim().isNotEmpty).toList();
                      if (nonEmpty.length < 3 || nonEmpty.length > 5) throw 'Multiple Choice: 3 a 5 opciones';
                      if (mcCorrect.isEmpty) throw 'Marca al menos una opción correcta';
                      final inserted = await supabase.from('preguntas').insert({
                        'id_habilidad': widget.skillId,
                        'texto_pregunta': texto,
                        'tipo_pregunta': 'multiple_choice',
                        'nivel_dificultad': nivel,
                        'puntos': puntos,
                        'explicacion': explanationCtrl.text.trim(),
                      }).select('id_pregunta').single();
                      final qid = (inserted['id_pregunta'] as num).toInt();
                      final opts = <Map<String, dynamic>>[];
                      for (int i = 0; i < mcOptCtrls.length; i++) {
                        final t = mcOptCtrls[i].text.trim(); if (t.isEmpty) continue;
                        opts.add({'id_pregunta': qid, 'texto_opcion': t, 'es_correcta': mcCorrect.contains(i), 'orden': i + 1});
                      }
                      await supabase.from('opciones_respuesta').insert(opts);
                      await _linkQuestionToQuiz(qid);
                    } else if (type == 'matching') {
                      final answers = matchAnswersCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
                      final statements = matchStatements
                          .where((r) => (r['text'] as TextEditingController).text.trim().isNotEmpty && r['answer'] != null)
                          .map((r) => {'texto': (r['text'] as TextEditingController).text.trim(), 'answer_index': (r['answer'] as int)})
                          .toList();
                      if (statements.isEmpty || statements.length > 5) throw 'Matching: 1..5 enunciados';
                      if (answers.length < statements.length || answers.length > 7) throw 'Matching: respuestas B entre A..7';
                      final res = await supabase.rpc('create_matching_question', params: {
                        'p_id_habilidad': widget.skillId,
                        'p_texto': texto,
                        'p_nivel': nivel,
                        'p_puntos': puntos,
                        'p_explicacion': explanationCtrl.text.trim(),
                        'p_answers': answers,
                        'p_statements': statements,
                      });
                      int qid;
                      if (res is List && res.isNotEmpty) {
                        qid = (res.first['qid'] as num).toInt();
                      } else if (res is Map && res.containsKey('qid')) {
                        qid = (res['qid'] as num).toInt();
                      } else {
                        throw 'RPC create_matching_question no retornó qid';
                      }
                      await _linkQuestionToQuiz(qid);
                    } else if (type == 'completion') {
                      if (completionRows.length < 5 || completionRows.length > 6) throw 'Completion: 5..6 oraciones';
                      final sentences = <Map<String, String>>[];
                      for (final r in completionRows) {
                        final sentence = r['sentence']!.text.trim();
                        final correct = r['correct']!.text.trim();
                        if (sentence.isEmpty || correct.isEmpty) continue;
                        String template;
                        final idx = sentence.toLowerCase().indexOf(correct.toLowerCase());
                        if (idx >= 0) {
                          template = sentence.replaceRange(idx, idx + correct.length, '{{1}}');
                        } else {
                          template = '$sentence {{1}}';
                        }
                        sentences.add({'texto_template': template, 'correct_text': correct});
                      }
                      if (sentences.length < 5) throw 'Completion: completa 5 oraciones';
                      final res = await supabase.rpc('create_completion_question', params: {
                        'p_id_habilidad': widget.skillId,
                        'p_texto': texto,
                        'p_nivel': nivel,
                        'p_puntos': puntos,
                        'p_explicacion': explanationCtrl.text.trim(),
                        'p_sentences': sentences,
                      });
                      int qid;
                      if (res is List && res.isNotEmpty) {
                        qid = (res.first['qid'] as num).toInt();
                      } else if (res is Map && res.containsKey('qid')) {
                        qid = (res['qid'] as num).toInt();
                      } else {
                        throw 'RPC create_completion_question no retornó qid';
                      }
                      await _linkQuestionToQuiz(qid);
                    } else if (type == 'record_audio') {
                      final inserted = await supabase.from('preguntas').insert({
                        'id_habilidad': widget.skillId,
                        'texto_pregunta': texto,
                        'tipo_pregunta': 'record_audio',
                        'nivel_dificultad': nivel,
                        'puntos': puntos,
                        'explicacion': explanationCtrl.text.trim(),
                      }).select('id_pregunta').single();
                      final qid = (inserted['id_pregunta'] as num).toInt();
                      await supabase.from('record_audio_config').insert({'id_pregunta': qid});
                      await _linkQuestionToQuiz(qid);
                    } else if (type == 'write_text') {
                      final inserted = await supabase.from('preguntas').insert({
                        'id_habilidad': widget.skillId,
                        'texto_pregunta': texto,
                        'tipo_pregunta': 'write_text',
                        'nivel_dificultad': nivel,
                        'puntos': puntos,
                        'explicacion': explanationCtrl.text.trim(),
                      }).select('id_pregunta').single();
                      final qid = (inserted['id_pregunta'] as num).toInt();
                      final mw = int.tryParse(maxWordsCtrl.text.trim()) ?? 120;
                      await supabase.from('write_text_config').insert({'id_pregunta': qid, 'max_words': mw});
                      await _linkQuestionToQuiz(qid);
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                    await _load();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pregunta creada')));
                  } catch (e) {
                    if (!mounted) return;
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

  Future<void> _linkQuestionToQuiz(int qid) async {
    final current = await supabase
        .from('cuestionario_preguntas')
        .select('orden')
        .eq('id_cuestionario', widget.quizId)
        .order('orden', ascending: false)
        .limit(1);
    final nextOrder = (current is List && current.isNotEmpty) ? ((current.first['orden'] as num).toInt() + 1) : 1;
    await supabase.from('cuestionario_preguntas').insert({
      'id_cuestionario': widget.quizId,
      'id_pregunta': qid,
      'orden': nextOrder,
    });
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
    final tipo = (q['tipo_pregunta'] as String?)?.toLowerCase() ?? '';
    final nivel = q['nivel_dificultad'] as String? ?? '';
    final puntos = q['puntos'] as int? ?? 1;
    final opciones = (q['opciones'] as List?) ?? const [];
    final expGeneral = (q['explicacion'] as String?)?.trim();
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
            Text('Tipo: $tipo • Nivel: $nivel • Puntos: $puntos', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            if (expGeneral != null && expGeneral.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text('Explicación general:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(expGeneral, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 10),
            ],
            if (opciones.isNotEmpty) const Text('Opciones:', style: TextStyle(fontWeight: FontWeight.w600)),
            if (opciones.isNotEmpty) const SizedBox(height: 6),
            ...opciones.map((o) {
              final correct = o['es_correcta'] == true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Icon(
                      correct ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: correct ? Colors.green : Colors.grey,
                    ),
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
