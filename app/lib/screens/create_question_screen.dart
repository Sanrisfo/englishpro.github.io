import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/supabase_config.dart';
import '../widgets/rich_text_field.dart';

class CreateQuestionScreen extends StatefulWidget {
  final int quizId;
  final int skillId;
  final String courseName;
  final List<String>? allowedTypes;
  final Map<String, dynamic>? questionToEdit;

  const CreateQuestionScreen({
    super.key,
    required this.quizId,
    required this.skillId,
    required this.courseName,
    this.allowedTypes,
    this.questionToEdit,
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
      if (widget.questionToEdit != null) {
        final q = widget.questionToEdit!;
        _textCtrl.text = q['texto_pregunta'] ?? '';
        _pointsCtrl.text = (q['puntos'] ?? 1).toString();
        _explanationCtrl.text = q['explicacion'] ?? '';
        _nivel = q['nivel_dificultad'] ?? 'Basico';
        _type = (q['tipo_pregunta'] as String?)?.toLowerCase();

        // Lock type
        _allowedTypes = _type != null ? [_type!] : [];
        
        // Populate specific fields
        if (_type == 'multiple_choice') {
           final opts = q['opciones'] as List?;
           if (opts != null) {
             _mcOptCtrls = opts.map((o) => TextEditingController(text: o['texto_opcion'])).toList();
             for (int i=0; i<opts.length; i++) {
               if (opts[i]['es_correcta'] == true) _mcCorrect.add(i);
             }
             // Ensure at least 3 controllers
             while (_mcOptCtrls.length < 3) _mcOptCtrls.add(TextEditingController());
           }
        }
        // NOTE: For Matching/Completion, we rely on the teacher re-entering data if they want to edit, 
        // as we don't fully fetch relations in TeacherQuestionsScreen yet.
        // We will just allow editing basic info for those types if relations are missing.
      } else {
        // ... (Existing NEW logic)
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
      }
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
      final isEdit = widget.questionToEdit != null;
      final qId = isEdit ? widget.questionToEdit!['id_pregunta'] as int : null;

      // 1. Update/Insert Question Record
      if (isEdit) {
        await supabase.from('preguntas').update({
          'texto_pregunta': texto,
          'nivel_dificultad': _nivel,
          'puntos': puntos,
          'explicacion': _explanationCtrl.text.trim(),
        }).eq('id_pregunta', qId!);
      } else {
        // Insert logic remains part of specific blocks below for ID retrieval
        // But to unify, we could insert first. However, type-specific tables (record_audio_config) need ID.
      }

      // 2. Handle specific types
      if (type == 'multiple_choice') {
        final nonEmpty = _mcOptCtrls.where((c) => c.text.trim().isNotEmpty).toList();
        if (nonEmpty.length < 3 || nonEmpty.length > 5) throw 'Multiple Choice: 3 a 5 opciones';
        if (_mcCorrect.isEmpty) throw 'Marca al menos una opción correcta';

        int currentQId;
        if (isEdit) {
          currentQId = qId!;
          // Delete old options
          await supabase.from('opciones_respuesta').delete().eq('id_pregunta', currentQId);
        } else {
           final inserted = await supabase.from('preguntas').insert({
            'id_habilidad': widget.skillId,
            'texto_pregunta': texto,
            'tipo_pregunta': 'multiple_choice',
            'nivel_dificultad': _nivel,
            'puntos': puntos,
            'explicacion': _explanationCtrl.text.trim(),
          }).select('id_pregunta').single();
          currentQId = (inserted['id_pregunta'] as num).toInt();
        }

        final opts = <Map<String, dynamic>>[];
        for (int i = 0; i < _mcOptCtrls.length; i++) {
          final t = _mcOptCtrls[i].text.trim();
          if (t.isEmpty) continue;
          opts.add({'id_pregunta': currentQId, 'texto_opcion': t, 'es_correcta': _mcCorrect.contains(i), 'orden': i + 1});
        }
        await supabase.from('opciones_respuesta').insert(opts);
        
        if (!isEdit) await _linkQuestionToQuiz(currentQId);

      } else if (type == 'matching') {
        // Edit Matching is complex due to relations. For MVP CRUD, we only update basic info if editing.
        // If user wants to change pairs, they might need to re-create or we assume strict usage.
        if (isEdit) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated basic info. Editing matching pairs is not fully supported yet.')));
        } else {
            // ... (Existing Creation Logic)
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
              throw 'RPC error';
            }
            await _linkQuestionToQuiz(qid);
        }
      } else if (type == 'completion') {
         if (isEdit) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated basic info. Editing completion sentences is not fully supported yet.')));
         } else {
            // ... (Existing Creation Logic)
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
              throw 'RPC error';
            }
            await _linkQuestionToQuiz(qid);
         }
      } else if (type == 'record_audio') {
         if (!isEdit) {
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
         }
      } else if (type == 'write_text') {
         final mw = int.tryParse(_maxWordsCtrl.text.trim()) ?? 120;
         if (isEdit) {
             await supabase.from('write_text_config').update({'max_words': mw}).eq('id_pregunta', qId!);
         } else {
            final inserted = await supabase.from('preguntas').insert({
              'id_habilidad': widget.skillId,
              'texto_pregunta': texto,
              'tipo_pregunta': 'write_text',
              'nivel_dificultad': _nivel,
              'puntos': puntos,
              'explicacion': _explanationCtrl.text.trim(),
            }).select('id_pregunta').single();
            final qid = (inserted['id_pregunta'] as num).toInt();
            await supabase.from('write_text_config').insert({'id_pregunta': qid, 'max_words': mw});
            await _linkQuestionToQuiz(qid);
         }
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

  // esto nos ayuda a diseñar el frontend
  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _courseColor.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _courseColor, width: 2)),
    );
  }

  Widget _buildTypeSelector() {
    // Definimos los datos de cada tipo (ID, Etiqueta, Icono)
    final typesData = [
      {'id': 'multiple_choice', 'label': 'Choice', 'icon': Icons.checklist_rtl_rounded},
      {'id': 'matching', 'label': 'Match', 'icon': Icons.abc_rounded},
      {'id': 'completion', 'label': 'Complete', 'icon': Icons.short_text_rounded},
      {'id': 'record_audio', 'label': 'Audio', 'icon': Icons.multitrack_audio_rounded},
      {'id': 'write_text', 'label': 'Write', 'icon': Icons.text_snippet_outlined},
    ];

    // Filtramos solo los tipos permitidos
    final availableTypes = typesData.where((t) => _allowedTypes.contains(t['id'])).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alineado a la izquierda
        children: availableTypes.map((t) {
          final id = t['id'] as String;
          final label = t['label'] as String;
          final icon = t['icon'] as IconData;
          final isSelected = _type == id;

          return GestureDetector(
            onTap: () => setState(() => _type = id),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0), // Espacio entre botones
              child: Column(
                children: [
                  // Etiqueta superior (pequeña)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF23408E) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Caja del Icono
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF23408E) : Colors.grey[100], // Azul si seleccionado
                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      border: Border.all(
                        color: isSelected ? const Color(0xFF23408E) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey[400], // Blanco si seleccionado
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _courseColor))
          : _error != null
          ? Center(child: Text(_error!))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [



              // Selector de iconos segun preguntaaaa
              const Text("Select question type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 12),
              _buildTypeSelector(),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // --- CAMPOS COMUNES ---
              // --- CAMPOS COMUNES ---
              RichTextField(controller: _textCtrl, label: 'Texto de la pregunta', maxLines: 3, decoration: _inputDeco('Texto de la pregunta')),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              RichTextField(controller: _explanationCtrl, label: 'Explicación general (opcional)', maxLines: 2, decoration: _inputDeco('Explicación general (opcional)')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _pointsCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Puntos'))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _nivel,
                      decoration: _inputDeco('Nivel de dificultad'),
                      items: const [
                        DropdownMenuItem(value: 'Basico', child: Text('Básico')),
                        DropdownMenuItem(value: 'Intermedio', child: Text('Intermedio')),
                        DropdownMenuItem(value: 'Avanzado', child: Text('Avanzado')),
                      ],
                      onChanged: (v) => setState(() => _nivel = v ?? 'Basico'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- FORMULARIOS DINÁMICOS ---

              // multiple_choice
              if (_type == 'multiple_choice') ...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Opciones (3 a 5)', style: TextStyle(fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: _mcOptCtrls.length < 5 ? () => setState(() => _mcOptCtrls.add(TextEditingController())) : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                    style: TextButton.styleFrom(foregroundColor: _courseColor),
                  ),
                ]),
                const SizedBox(height: 8),
                ..._mcOptCtrls.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        activeColor: _courseColor,
                        value: _mcCorrect.contains(e.key),
                        onChanged: (v) => setState(() => v == true ? _mcCorrect.add(e.key) : _mcCorrect.remove(e.key)),
                      ),
                    ),
                    Expanded(child: RichTextField(controller: e.value, label: 'Opción ${e.key + 1}', decoration: _inputDeco('Opción ${e.key + 1}'))),
                    if (_mcOptCtrls.length > 3)
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _mcCorrect.remove(e.key);
                            _mcOptCtrls.removeAt(e.key);
                          })
                      ),
                  ]),
                )),
              ]
              // matching
              else if (_type == 'matching') ...[
                Text('Respuestas (Columna B)', style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.bold, color: _courseColor)),
                const SizedBox(height: 8),
                ..._matchAnswersCtrls.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(children: [
                    Expanded(child: RichTextField(controller: e.value, label: 'Respuesta B${e.key + 1}', decoration: _inputDeco('Respuesta B${e.key + 1}'))),
                    if (_matchAnswersCtrls.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _matchAnswersCtrls.removeAt(e.key)),
                      ),
                  ]),
                )),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _matchAnswersCtrls.length < 7 ? () => setState(() => _matchAnswersCtrls.add(TextEditingController())) : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar respuesta'),
                    style: TextButton.styleFrom(foregroundColor: _courseColor),
                  ),
                ),
                const Divider(),
                Text('Enunciados (Columna A)', style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.bold, color: _courseColor)),
                const SizedBox(height: 8),
                ..._matchStatements.asMap().entries.map((e) {
                  final i = e.key;
                  final row = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(children: [
                      Expanded(flex: 2, child: RichTextField(controller: row['text'], label: 'Enunciado A${i + 1}', decoration: _inputDeco('Enunciado A${i + 1}'))),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<int>(
                          value: row['answer'] as int?,
                          decoration: _inputDeco('Match'),
                          items: _matchAnswersCtrls
                              .asMap()
                              .entries
                              .map((a) => DropdownMenuItem(value: a.key, child: Text('B${a.key + 1}')))
                              .toList(),
                          onChanged: (v) => setState(() => row['answer'] = v),
                        ),
                      ),
                      if (_matchStatements.length > 1)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _matchStatements.removeAt(i)),
                        ),
                    ]),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _matchStatements.length < 5
                        ? () => setState(() => _matchStatements.add({'text': TextEditingController(), 'answer': null}))
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar enunciado'),
                    style: TextButton.styleFrom(foregroundColor: _courseColor),
                  ),
                ),
              ]
              // completion
              else if (_type == 'completion') ...[
                  Text('Completion (5-6)', style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.bold, color: _courseColor)),
                  const Text('Escribe la oración completa y la palabra que será el gap.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ..._completionRows.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      children: [
                        RichTextField(controller: e.value['sentence']!, label: 'Oración Completa ${e.key + 1}', decoration: _inputDeco('Oración Completa ${e.key + 1}')),
                        const SizedBox(height: 8),
                        RichTextField(controller: e.value['correct']!, label: 'Palabra (Gap)', decoration: _inputDeco('Palabra (Gap)')),
                      ],
                    ),
                  )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _completionRows.length < 6
                          ? () => setState(() => _completionRows.add({'sentence': TextEditingController(), 'correct': TextEditingController()}))
                          : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar oración'),
                      style: TextButton.styleFrom(foregroundColor: _courseColor),
                    ),
                  ),
                ]
                else if (_type == 'write_text') ...[
                    TextField(controller: _maxWordsCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Máximo de palabras')),
                  ]
                  else if (_type == 'record_audio') ...[
                      Center(child: Text('El estudiante grabará audio (hasta 45s).', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]))),
                    ],

              const SizedBox(height: 40),

              // --- BOTONES DE ACCIÓN ---
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _courseColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Crear', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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