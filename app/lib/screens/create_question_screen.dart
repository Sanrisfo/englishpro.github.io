import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/supabase_config.dart';

class CreateQuestionScreen extends StatefulWidget {
  final int quizId;
  final int skillId;
  final String courseName;
  final List<String>? allowedTypes;

  const CreateQuestionScreen({
    super.key,
    required this.quizId,
    required this.skillId,
    required this.courseName,
    this.allowedTypes,
  });

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  bool _loading = true;
  late List<String> _allowedTypes;
  String? _error;

  // Common fields
  final _textCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '1');
  String _nivel = 'Basico';
  final _explanationCtrl = TextEditingController();

  // Type
  final List<String> _allTypes = const ['multiple_choice', 'matching', 'completion', 'record_audio', 'write_text'];
  String? _type;

  // Multiple choice
  List<TextEditingController> _mcOptCtrls = [TextEditingController(), TextEditingController(), TextEditingController()];
  final Set<int> _mcCorrect = {};

  // Matching
  List<TextEditingController> _matchAnswersCtrls = [TextEditingController(), TextEditingController(), TextEditingController()];
  List<Map<String, dynamic>> _matchStatements = [
    {'text': TextEditingController(), 'answer': null},
    {'text': TextEditingController(), 'answer': null},
    {'text': TextEditingController(), 'answer': null},
  ];

  // Completion
  List<Map<String, TextEditingController>> _completionRows =
      List.generate(5, (_) => {'sentence': TextEditingController(), 'correct': TextEditingController()});

  // Write text
  final _maxWordsCtrl = TextEditingController(text: '120');

  bool _submitting = false;

  Color get _courseColor => _getCourseColor(widget.courseName);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _allowedTypes = widget.allowedTypes ?? [];
      if (_allowedTypes.isEmpty) {
        try {
          final quizRow = await supabase
              .from('cuestionarios')
              .select('id_tipo_actividad')
              .eq('id_cuestionario', widget.quizId)
              .single();
          final typeId = (quizRow['id_tipo_actividad'] as num?)?.toInt();
          if (typeId != null) {
            final rows = await supabase
                .from('tipo_actividad_pregunta_permitida')
                .select('tipo_pregunta')
                .eq('id_tipo_actividad', typeId);
            _allowedTypes = List<Map<String, dynamic>>.from(rows as List)
                .map((e) => (e['tipo_pregunta'] as String).toLowerCase())
                .toList();
          }
        } catch (_) {}
      }
      if (_allowedTypes.isEmpty) _allowedTypes = List.from(_allTypes);
      _type = _allowedTypes.first;
    } catch (e) {
      _error = 'Error loading: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _pointsCtrl.dispose();
    _explanationCtrl.dispose();
    for (final c in _mcOptCtrls) c.dispose();
    for (final c in _matchAnswersCtrls) c.dispose();
    for (final r in _matchStatements) (r['text'] as TextEditingController).dispose();
    for (final r in _completionRows) {
      r['sentence']!.dispose();
      r['correct']!.dispose();
    }
    _maxWordsCtrl.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    final texto = _textCtrl.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texto requerido')));
      return;
    }
    final puntos = int.tryParse(_pointsCtrl.text.trim()) ?? 1;
    final type = _type ?? _allowedTypes.first;
    setState(() => _submitting = true);
    try {
      if (type == 'multiple_choice') {
        final nonEmpty = _mcOptCtrls.where((c) => c.text.trim().isNotEmpty).toList();
        if (nonEmpty.length < 3 || nonEmpty.length > 5) {
          throw 'Multiple Choice: 3 a 5 opciones';
        }
        if (_mcCorrect.isEmpty) throw 'Marca al menos una opción correcta';
        final inserted = await supabase.from('preguntas').insert({
          'id_habilidad': widget.skillId,
          'texto_pregunta': texto,
          'tipo_pregunta': 'multiple_choice',
          'nivel_dificultad': _nivel,
          'puntos': puntos,
          'explicacion': _explanationCtrl.text.trim(),
        }).select('id_pregunta').single();
        final qid = (inserted['id_pregunta'] as num).toInt();
        final opts = <Map<String, dynamic>>[];
        for (int i = 0; i < _mcOptCtrls.length; i++) {
          final t = _mcOptCtrls[i].text.trim();
          if (t.isEmpty) continue;
          opts.add({'id_pregunta': qid, 'texto_opcion': t, 'es_correcta': _mcCorrect.contains(i), 'orden': i + 1});
        }
        await supabase.from('opciones_respuesta').insert(opts);
        await _linkQuestionToQuiz(qid);
      } else if (type == 'matching') {
        final answers = _matchAnswersCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
        final statements = _matchStatements
            .where((r) => (r['text'] as TextEditingController).text.trim().isNotEmpty && r['answer'] != null)
            .map((r) => {'texto': (r['text'] as TextEditingController).text.trim(), 'answer_index': (r['answer'] as int)})
            .toList();
        if (statements.isEmpty || statements.length > 5) throw 'Matching: 1..5 enunciados';
        if (answers.length < statements.length || answers.length > 7) throw 'Matching: respuestas B entre A..7';
        final res = await supabase.rpc('create_matching_question', params: {
          'p_id_habilidad': widget.skillId,
          'p_texto': texto,
          'p_nivel': _nivel,
          'p_puntos': puntos,
          'p_explicacion': _explanationCtrl.text.trim(),
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
        if (_completionRows.length < 5 || _completionRows.length > 6) throw 'Completion: 5..6 oraciones';
        final sentences = <Map<String, String>>[];
        for (final r in _completionRows) {
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
          'p_nivel': _nivel,
          'p_puntos': puntos,
          'p_explicacion': _explanationCtrl.text.trim(),
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
          'nivel_dificultad': _nivel,
          'puntos': puntos,
          'explicacion': _explanationCtrl.text.trim(),
        }).select('id_pregunta').single();
        final qid = (inserted['id_pregunta'] as num).toInt();
        await supabase.from('record_audio_config').insert({'id_pregunta': qid});
        await _linkQuestionToQuiz(qid);
      } else if (type == 'write_text') {
        final inserted = await supabase.from('preguntas').insert({
          'id_habilidad': widget.skillId,
          'texto_pregunta': texto,
          'tipo_pregunta': 'write_text',
          'nivel_dificultad': _nivel,
          'puntos': puntos,
          'explicacion': _explanationCtrl.text.trim(),
        }).select('id_pregunta').single();
        final qid = (inserted['id_pregunta'] as num).toInt();
        final mw = int.tryParse(_maxWordsCtrl.text.trim()) ?? 120;
        await supabase.from('write_text_config').insert({'id_pregunta': qid, 'max_words': mw});
        await _linkQuestionToQuiz(qid);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Question'),
        backgroundColor: _courseColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _courseColor))
          : _error != null
              ? Center(child: Text(_error!))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                            decoration: BoxDecoration(color: _courseColor, borderRadius: BorderRadius.circular(10.0)),
                            child: Text('New Question', style: GoogleFonts.ptSans(color: Colors.white, fontSize: 20)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(labelText: 'Tipo de pregunta'),
                          items: _allowedTypes
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' '))))
                              .toList(),
                          onChanged: (v) => setState(() => _type = v ?? _type),
                        ),
                        const SizedBox(height: 8),
                        TextField(controller: _textCtrl, decoration: const InputDecoration(labelText: 'Texto de la pregunta'), maxLines: 3),
                        const SizedBox(height: 8),
                        TextField(controller: _explanationCtrl, decoration: const InputDecoration(labelText: 'Explicación general (opcional)'), maxLines: 3),
                        const SizedBox(height: 8),
                        TextField(controller: _pointsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Puntos')),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _nivel,
                          decoration: const InputDecoration(labelText: 'Nivel de dificultad'),
                          items: const [
                            DropdownMenuItem(value: 'Basico', child: Text('Básico')),
                            DropdownMenuItem(value: 'Intermedio', child: Text('Intermedio')),
                            DropdownMenuItem(value: 'Avanzado', child: Text('Avanzado')),
                          ],
                          onChanged: (v) => setState(() => _nivel = v ?? 'Basico'),
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

                        // multiple_choice
                        if (_type == 'multiple_choice') ...[
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('Opciones (3 a 5)', style: TextStyle(fontWeight: FontWeight.w600)),
                            TextButton.icon(
                              onPressed: _mcOptCtrls.length < 5 ? () => setState(() => _mcOptCtrls.add(TextEditingController())) : null,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            ),
                          ]),
                          ..._mcOptCtrls.asMap().entries.map((e) => Row(children: [
                                Checkbox(
                                  value: _mcCorrect.contains(e.key),
                                  onChanged: (v) => setState(() => v == true ? _mcCorrect.add(e.key) : _mcCorrect.remove(e.key)),
                                ),
                                Expanded(child: TextField(controller: e.value, decoration: InputDecoration(labelText: 'Opción ${e.key + 1}'))),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _mcOptCtrls.length > 3
                                      ? () => setState(() {
                                            _mcCorrect.remove(e.key);
                                            _mcOptCtrls.removeAt(e.key);
                                          })
                                      : null,
                                ),
                              ])),
                        ]
                        // matching
                        else if (_type == 'matching') ...[
                          const Align(alignment: Alignment.centerLeft, child: Text('Respuestas (B) 1..7', style: TextStyle(fontWeight: FontWeight.w600))),
                          ..._matchAnswersCtrls.asMap().entries.map((e) => Row(children: [
                                Expanded(child: TextField(controller: e.value, decoration: InputDecoration(labelText: 'Respuesta B${e.key + 1}'))),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _matchAnswersCtrls.length > 1 ? () => setState(() => _matchAnswersCtrls.removeAt(e.key)) : null,
                                ),
                              ])),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _matchAnswersCtrls.length < 7 ? () => setState(() => _matchAnswersCtrls.add(TextEditingController())) : null,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar respuesta'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Align(alignment: Alignment.centerLeft, child: Text('Enunciados (A) 1..5', style: TextStyle(fontWeight: FontWeight.w600))),
                          ..._matchStatements.asMap().entries.map((e) {
                            final i = e.key;
                            final row = e.value;
                            return Row(children: [
                              Expanded(child: TextField(controller: row['text'], decoration: InputDecoration(labelText: 'Enunciado A${i + 1}'))),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: row['answer'] as int?,
                                hint: const Text('B?'),
                                items: _matchAnswersCtrls
                                    .asMap()
                                    .entries
                                    .map((a) => DropdownMenuItem(value: a.key, child: Text('B${a.key + 1}')))
                                    .toList(),
                                onChanged: (v) => setState(() => row['answer'] = v),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _matchStatements.length > 1 ? () => setState(() => _matchStatements.removeAt(i)) : null,
                              ),
                            ]);
                          }),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _matchStatements.length < 5
                                  ? () => setState(() => _matchStatements.add({'text': TextEditingController(), 'answer': null}))
                                  : null,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar enunciado'),
                            ),
                          ),
                        ]
                        // completion
                        else if (_type == 'completion') ...[
                          const Align(alignment: Alignment.centerLeft, child: Text('Completion (5..6)', style: TextStyle(fontWeight: FontWeight.w600))),
                          const Align(alignment: Alignment.centerLeft, child: Text('Escribe la oración completa y la palabra que será el gap. Nosotros generamos los espacios automáticamente.')),
                          ..._completionRows.asMap().entries.map((e) => Row(children: [
                                Expanded(child: TextField(controller: e.value['sentence'], decoration: InputDecoration(labelText: 'Oración ${e.key + 1}'))),
                                const SizedBox(width: 8),
                                SizedBox(width: 180, child: TextField(controller: e.value['correct'], decoration: const InputDecoration(labelText: 'Palabra (gap)'))),
                              ])),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _completionRows.length < 6
                                  ? () => setState(() => _completionRows.add({'sentence': TextEditingController(), 'correct': TextEditingController()}))
                                  : null,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            ),
                          ),
                        ]
                        else if (_type == 'write_text') ...[
                          TextField(controller: _maxWordsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max palabras')), 
                        ]
                        else if (_type == 'record_audio') ...[
                          const Text('El estudiante grabará audio (hasta 45s).'),
                        ],

                        const SizedBox(height: 24),
                        Row(
                          children: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: _courseColor.withOpacity(0.1), foregroundColor: _courseColor),
                              child: _submitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Crear'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) return const Color(0xFFD9232A);
    if (lower.contains('ielts')) return const Color(0xFF23408E);
    if (lower.contains('business')) return const Color(0xFFB02224);
    return const Color(0xFF1F3A89);
  }
}

