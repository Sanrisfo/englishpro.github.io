import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../config/supabase_config.dart';
import '../models/question_model.dart';
import '../models/matching_models.dart';
import '../models/completion_models.dart';
import '../models/material_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/pdf_viewer_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/supabase_storage_service.dart';

class ActivityPlayerScreen extends StatefulWidget {
  final int quizId;
  final int skillId;
  final String skillName;
  final String quizTitle;

  const ActivityPlayerScreen({
    Key? key,
    required this.quizId,
    required this.skillId,
    required this.skillName,
    required this.quizTitle,
  }) : super(key: key);

  @override
  State<ActivityPlayerScreen> createState() => _ActivityPlayerScreenState();
}

class _ActivityPlayerScreenState extends State<ActivityPlayerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  MaterialModel? _material;
  List<QuestionModel> _questions = [];
  // Respuestas en memoria
  final Map<int, Set<int>> _selectedOptionsByQuestion = {}; // MC: questionId -> set<optionId>
  final Map<int, Map<int, int>> _matchingByQuestion = {}; // Matching: questionId -> {statementId: answerId}
  final Map<int, Map<int, String>> _completionByQuestion = {}; // Completion: questionId -> {gapId: text}
  final Map<int, Map<int, TextEditingController>> _completionControllers = {}; // questionId -> {gapId: controller}
  final Map<int, String> _writeTextByQuestion = {}; // Write Text: questionId -> text
  final Map<int, TextEditingController> _writeTextControllers = {}; // controllers por pregunta
  final Map<int, String?> _audioUrlByQuestion = {}; // Record Audio: questionId -> uploaded url
  bool _allSubmitted = false; // all answers submitted flag
  final _audioPlayer = AudioPlayer();
  int _secondsRemaining = 0;
  Timer? _timer;
  int? _quizTimeMinutes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Load quiz info (time limit minutes)
      try {
        final quizRow = await supabase
            .from('cuestionarios')
            .select('tiempo_limite_minutos, titulo')
            .eq('id_cuestionario', widget.quizId)
            .single();
        _quizTimeMinutes = quizRow['tiempo_limite_minutos'] as int?;
      } catch (_) {}

      // Load material linked to this quiz (si existe). No fallback a nivel habilidad
      try {
        final mats = await supabase
            .from('materiales_estudio')
            .select('*')
            .eq('id_cuestionario', widget.quizId)
            .order('orden', ascending: true);
        final list = List<Map<String, dynamic>>.from(mats as List);
        if (list.isNotEmpty) {
          _material = MaterialModel.fromJson(list.first);
        }
      } catch (_) {}

      // Load questions for this quiz (via junction table)
      final cp = await supabase
          .from('cuestionario_preguntas')
          .select('id_pregunta, orden')
          .eq('id_cuestionario', widget.quizId)
          .order('orden', ascending: true);
      final cpList = List<Map<String, dynamic>>.from(cp as List);
      if (cpList.isEmpty) {
        setState(() {
          _questions = [];
          _isLoading = false;
        });
        return;
      }
      final ids = cpList.map((e) => e['id_pregunta']).where((e) => e != null).toList();

      final qs = await supabase
          .from('preguntas')
          .select('id_pregunta, id_habilidad, texto_pregunta, tipo_pregunta, nivel_dificultad, puntos, explicacion')
          .inFilter('id_pregunta', ids);
      final qList = List<Map<String, dynamic>>.from(qs as List);

      final opts = await supabase
          .from('opciones_respuesta')
          .select('id_opcion, id_pregunta, texto_opcion, es_correcta, orden')
          .inFilter('id_pregunta', ids)
          .order('orden', ascending: true);
      final optList = List<Map<String, dynamic>>.from(opts as List);

      // Cargar datos adicionales para Matching, Completion y Configs
      final matchingIds = qList
          .where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('matching'))
          .map((q) => q['id_pregunta'] as int)
          .toList();
      final completionIds = qList
          .where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('completion'))
          .map((q) => q['id_pregunta'] as int)
          .toList();
      final writeTextIds = qList
          .where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('write'))
          .map((q) => q['id_pregunta'] as int)
          .toList();
      final recordAudioIds = qList
          .where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('record'))
          .map((q) => q['id_pregunta'] as int)
          .toList();

      List<Map<String, dynamic>> mAnswers = [];
      List<Map<String, dynamic>> mStatements = [];
      if (matchingIds.isNotEmpty) {
        final a = await supabase
            .from('matching_answers')
            .select('id, id_pregunta, texto, orden')
            .inFilter('id_pregunta', matchingIds)
            .order('orden');
        mAnswers = List<Map<String, dynamic>>.from(a as List);
        final s = await supabase
            .from('matching_statements')
            .select('id, id_pregunta, texto, orden, correct_answer_id')
            .inFilter('id_pregunta', matchingIds)
            .order('orden');
        mStatements = List<Map<String, dynamic>>.from(s as List);
      }

      List<Map<String, dynamic>> cSentences = [];
      List<Map<String, dynamic>> cGaps = [];
      if (completionIds.isNotEmpty) {
        final cs = await supabase
            .from('completion_sentences')
            .select('id, id_pregunta, texto_template, orden')
            .inFilter('id_pregunta', completionIds)
            .order('orden');
        cSentences = List<Map<String, dynamic>>.from(cs as List);
        final sentIds = cSentences.map((e) => e['id'] as int).toList();
        if (sentIds.isNotEmpty) {
          final cg = await supabase
              .from('completion_gaps')
              .select('id, sentence_id, gap_index, correct_text')
              .inFilter('sentence_id', sentIds)
              .order('gap_index');
          cGaps = List<Map<String, dynamic>>.from(cg as List);
        }
      }

      Map<int, int> maxWordsByQ = {};
      if (writeTextIds.isNotEmpty) {
        final wt = await supabase
            .from('write_text_config')
            .select('id_pregunta, max_words')
            .inFilter('id_pregunta', writeTextIds);
        final wtl = List<Map<String, dynamic>>.from(wt as List);
        for (final r in wtl) {
          maxWordsByQ[(r['id_pregunta'] as num).toInt()] = (r['max_words'] as num).toInt();
        }
      }

      Map<int, Map<String, int>> audioConfigByQ = {};
      if (recordAudioIds.isNotEmpty) {
        final ra = await supabase
            .from('record_audio_config')
            .select('id_pregunta, think_time_seconds, max_record_seconds')
            .inFilter('id_pregunta', recordAudioIds);
        final ral = List<Map<String, dynamic>>.from(ra as List);
        for (final r in ral) {
          audioConfigByQ[(r['id_pregunta'] as num).toInt()] = {
            'think': (r['think_time_seconds'] as num).toInt(),
            'max': (r['max_record_seconds'] as num).toInt(),
          };
        }
      }

      // Build QuestionModel list preserving order
      final byId = <int, Map<String, dynamic>>{};
      for (final q in qList) {
        final tipo = (q['tipo_pregunta'] as String? ?? '').toLowerCase();
        // Normalize type to match model expectations
        String normalized;
        if (tipo.contains('multiple')) {
          normalized = 'multiple_choice';
        } else if (tipo.contains('matching')) {
          normalized = 'matching';
        } else if (tipo.contains('completion')) {
          normalized = 'completion';
        } else if (tipo.contains('record')) {
          normalized = 'record_audio';
        } else if (tipo.contains('write') || tipo.contains('texto')) {
          normalized = 'write_text';
        } else {
          normalized = tipo.isEmpty ? 'multiple_choice' : tipo;
        }
        final qid = q['id_pregunta'] as int;
        // Matching data for this question
        final myAnswers = mAnswers.where((e) => e['id_pregunta'] == qid).toList();
        final myStatements = mStatements.where((e) => e['id_pregunta'] == qid).toList();
        // Completion data
        final mySentences = cSentences.where((e) => e['id_pregunta'] == qid).toList();
        final sentWithGaps = mySentences
            .map((s) => {
                  ...s,
                  'gaps': cGaps.where((g) => g['sentence_id'] == s['id']).toList(),
                })
            .toList();

        byId[qid] = {
          'id': q['id_pregunta'],
          'id_habilidad': q['id_habilidad'] ?? widget.skillId,
          'texto_pregunta': q['texto_pregunta'],
          'tipo_pregunta': normalized,
          'nivel_dificultad': q['nivel_dificultad'] ?? 'Basico',
          'puntaje': q['puntos'] ?? 1,
          // Sin tiempo por pregunta; se usa tiempo del cuestionario
          'tiempo_limite_segundos': null,
          'opciones': optList
              .where((o) => o['id_pregunta'] == qid)
              .map((o) => {
                    'id': o['id_opcion'],
                    'pregunta_id': o['id_pregunta'],
                    'texto_opcion': o['texto_opcion'],
                    'es_correcta': o['es_correcta'],
                  })
              .toList(),
          'matching_answers': myAnswers,
          'matching_statements': myStatements,
          'completion_sentences': sentWithGaps,
          'max_words': maxWordsByQ[qid],
          'think_time_seconds': audioConfigByQ[qid]?['think'],
          'max_record_seconds': audioConfigByQ[qid]?['max'],
          'explicacion': q['explicacion'],
        };
      }

      final ordered = <QuestionModel>[];
      for (final row in cpList) {
        final qid = row['id_pregunta'] as int;
        final mapped = byId[qid];
        if (mapped != null) ordered.add(QuestionModel.fromJson(mapped));
      }

      setState(() {
        _questions = ordered;
        // Start timer if quiz-level time is present
        if ((_quizTimeMinutes ?? 0) > 0) {
          _secondsRemaining = (_quizTimeMinutes!) * 60;
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (_secondsRemaining > 0) {
              setState(() => _secondsRemaining--);
            } else {
              t.cancel();
              _submitAllAnswers(auto: true);
            }
          });
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando actividad: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAllAnswers({bool auto = false}) async {
    if (_allSubmitted) return;
    final user = context.read<AuthProvider>().user;
    final userId = user?.idUsuario;
    if (userId == null) {
      if (!auto) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para enviar respuestas')),
        );
      }
      return;
    }
    final total = _questions.length;
    // Count answered across all types
    int answered = 0;
    for (final q in _questions) {
      if (q.isMultipleChoice) {
        final set = _selectedOptionsByQuestion[q.id];
        if (set != null && set.isNotEmpty) answered++;
      } else if (q.isMatching) {
        final map = _matchingByQuestion[q.id];
        final totalStmts = q.matchingStatements?.length ?? 0;
        if (map != null && map.length == totalStmts && !map.values.contains(null)) answered++;
      } else if (q.isCompletion) {
        final map = _completionByQuestion[q.id];
        final totalGaps = (q.completionSentences ?? const <CompletionSentence>[])
            .fold<int>(0, (int sum, CompletionSentence s) => sum + s.gaps.length);
        if (map != null && map.length == totalGaps) answered++;
      } else if (q.isWriteText) {
        final t = _writeTextByQuestion[q.id];
        if ((t?.trim().isNotEmpty ?? false)) answered++;
      } else if (q.isRecordAudio) {
        final u = _audioUrlByQuestion[q.id];
        if (u != null && u.isNotEmpty) answered++;
      }
    }
    if (!auto && (answered < total)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Responde todas las preguntas ($answered/$total)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
    final futures = <Future>[];
    for (final q in _questions) {
      if (q.isMultipleChoice) {
        final set = _selectedOptionsByQuestion[q.id] ?? const {};
        futures.add(ApiService.submitAnswerMultipleChoice(
          userId: userId,
          preguntaId: q.id,
          optionIds: set.toList(),
          quizId: widget.quizId,
        ));
      } else if (q.isMatching) {
        final map = _matchingByQuestion[q.id] ?? const {};
        futures.add(ApiService.submitAnswerMatching(
          userId: userId,
          preguntaId: q.id,
          statementToAnswer: Map<int, int>.from(map),
          quizId: widget.quizId,
        ));
      } else if (q.isCompletion) {
        final map = _completionByQuestion[q.id] ?? const {};
        futures.add(ApiService.submitAnswerCompletion(
          userId: userId,
          preguntaId: q.id,
          gapToText: Map<int, String>.from(map),
          quizId: widget.quizId,
        ));
      } else if (q.isWriteText) {
        final text = _writeTextByQuestion[q.id] ?? '';
        futures.add(ApiService.submitAnswerWriteText(
          userId: userId,
          preguntaId: q.id,
          text: text,
          quizId: widget.quizId,
        ));
      } else if (q.isRecordAudio) {
        final url = _audioUrlByQuestion[q.id] ?? '';
        futures.add(ApiService.submitAnswerRecordAudio(
          userId: userId,
          preguntaId: q.id,
          audioUrl: url,
          quizId: widget.quizId,
        ));
      }
    }
      await Future.wait(futures);
      if (mounted) {
        setState(() {
          _allSubmitted = true;
          _timer?.cancel();
          _secondsRemaining = 0;
        });
        if (!auto) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Respuestas enviadas')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildMaterial() {
    final m = _material;
    if (m == null) return const SizedBox.shrink();
    final t = m.tipoMaterial.toLowerCase();
    if (t == 'pdf' && (m.archivoUrl?.isNotEmpty ?? false)) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text(m.titulo),
          subtitle: const Text('Abrir PDF'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PDFViewerWidget(pdfUrl: m.archivoUrl!, title: m.titulo),
            ),
          ),
        ),
      );
    }
    if ((t == 'image' || t == 'imagen') && (m.archivoUrl?.isNotEmpty ?? false)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(m.archivoUrl!, fit: BoxFit.cover),
      );
    }
    if (t == 'audio' && (m.archivoUrl?.isNotEmpty ?? false)) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.audiotrack, color: Colors.indigo),
          title: Text(m.titulo),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              try {
                await _audioPlayer.stop();
                await _audioPlayer.play(UrlSource(m.archivoUrl!));
              } catch (_) {}
            },
          ),
        ),
      );
    }
    if (t == 'text' || t == 'texto') {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(m.contenidoTexto ?? ''),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuestionCard(QuestionModel q, int index) {
    Widget body;
    if (q.isMultipleChoice) {
      final selected = _selectedOptionsByQuestion[q.id] ?? <int>{};
      final isSubmitted = _allSubmitted;
      final options = q.opciones ?? const <AnswerOptionModel>[];
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((o) {
          final bool isSelected = selected.contains(o.id);
          final bool isCorrect = (o.esCorrecta);
          if (isSubmitted) {
            final Color borderColor = isSelected
                ? (isCorrect ? Colors.green : Colors.red)
                : (isCorrect ? Colors.green : Colors.grey.shade300);
            final IconData icon = isCorrect
                ? Icons.check_circle
                : (isSelected ? Icons.cancel : Icons.radio_button_unchecked);
            final Color iconColor = isCorrect
                ? Colors.green
                : (isSelected ? Colors.red : Colors.grey);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(o.textoOpcion)),
                ],
              ),
            );
          }
          return CheckboxListTile(
            value: isSelected,
            onChanged: (v) {
              setState(() {
                final set = _selectedOptionsByQuestion.putIfAbsent(q.id, () => <int>{});
                if (v == true) {
                  set.add(o.id);
                } else {
                  set.remove(o.id);
                }
              });
            },
            title: Text(o.textoOpcion),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      );
    } else if (q.isMatching) {
      final statements = q.matchingStatements ?? const <MatchingStatement>[];
      final answers = q.matchingAnswers ?? const <MatchingAnswer>[];
      final map = _matchingByQuestion.putIfAbsent(q.id, () => <int, int>{});
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statements.map((s) {
          final selected = map[s.id];
          final correctId = s.correctAnswerId;
          final isCorrect = _allSubmitted && selected == correctId;
          final answerText = answers.firstWhere((a) => a.id == (selected ?? -1), orElse: () => MatchingAnswer(id: -1, preguntaId: s.preguntaId, texto: '-', orden: 0)).texto;
          if (_allSubmitted) {
            final String correctText = answers
                .firstWhere((a) => a.id == correctId, orElse: () => MatchingAnswer(id: -1, preguntaId: s.preguntaId, texto: '-', orden: 0))
                .texto;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: isCorrect ? Colors.green : Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(s.texto)),
                  const SizedBox(width: 12),
                  Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(answerText),
                  if (!isCorrect) ...[
                    const SizedBox(width: 10),
                    const Text('→', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 6),
                    Text(correctText, style: const TextStyle(color: Colors.green)),
                  ],
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Expanded(child: Text(s.texto)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selected,
                  hint: const Text('Selecciona'),
                  items: answers.map((a) => DropdownMenuItem<int>(value: a.id, child: Text(a.texto))).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      map[s.id] = v;
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (q.isCompletion) {
      final sentences = q.completionSentences ?? const <CompletionSentence>[];
      final map = _completionByQuestion.putIfAbsent(q.id, () => <int, String>{});
      final ctrls = _completionControllers.putIfAbsent(q.id, () => <int, TextEditingController>{});
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sentences.map((s) {
          final reg = RegExp(r'\{\{(\d+)\}\}');
          final widgets = <Widget>[];
          int last = 0;
          final text = s.textoTemplate;
          for (final m in reg.allMatches(text)) {
            if (m.start > last) {
              widgets.add(Text(text.substring(last, m.start)));
            }
            final gapIndex = int.parse(m.group(1)!);
            final gap = s.gaps.firstWhere((g) => g.gapIndex == gapIndex, orElse: () => CompletionGap(id: -gapIndex, sentenceId: s.id, gapIndex: gapIndex, correctText: ''));
            final controller = ctrls.putIfAbsent(gap.id, () => TextEditingController(text: map[gap.id] ?? ''));
            final isCorrect = _allSubmitted && controller.text.trim().toLowerCase() == gap.correctText.trim().toLowerCase();
            widgets.add(SizedBox(
              width: 160,
              child: TextField(
                controller: controller,
                readOnly: _allSubmitted,
                onChanged: (v) {
                  map[gap.id] = v;
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '...',
                  suffixIcon: _allSubmitted
                      ? Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 18)
                      : null,
                ),
              ),
            ));
            if (_allSubmitted && !isCorrect) {
              widgets.add(Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text('(${gap.correctText})', style: const TextStyle(color: Colors.green)),
              ));
            }
            last = m.end;
          }
          if (last < text.length) {
            widgets.add(Text(text.substring(last)));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: widgets,
            ),
          );
        }).toList(),
      );
    } else if (q.isWriteText) {
      final max = q.maxWords ?? 0;
      final controller = _writeTextControllers.putIfAbsent(q.id, () {
        return TextEditingController(text: _writeTextByQuestion[q.id] ?? '');
      });
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLines: 6,
            onChanged: (v) {
              if (_allSubmitted) return;
              _writeTextByQuestion[q.id] = v;
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta...',
              border: const OutlineInputBorder(),
              // no usar counterText para no depender de maxLength
            ),
          ),
          const SizedBox(height: 6),
          Builder(builder: (_) {
            final words = _wordCount(controller.text);
            return Text(
              max > 0 ? '$words/$max palabras' : '$words palabras',
              style: const TextStyle(color: Colors.grey),
            );
          })
        ],
      );
    } else if (q.isRecordAudio) {
      body = _buildRecordAudio(q);
    } else {
      body = const Text('Tipo de pregunta no soportado aún.');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pregunta ${index + 1}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(q.textoPregunta, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            body,
            if (_allSubmitted && (q.explicacionGeneral?.trim().isNotEmpty ?? false))
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(child: Text(q.explicacionGeneral!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _wordCount(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  Widget _buildRecordAudio(QuestionModel q) {
    // Simple estado local por pregunta
    final think = q.thinkTimeSeconds ?? 10;
    final max = q.maxRecordSeconds ?? 45;
    final url = _audioUrlByQuestion[q.id];
    return _RecordAudioWidget(
      thinkSeconds: think,
      maxRecordSeconds: max,
      existingUrl: url,
      onUploaded: (u) => setState(() => _audioUrlByQuestion[q.id] = u),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recalcular progreso (preguntas "contestadas")
    int answered = 0;
    for (final q in _questions) {
      if (q.isMultipleChoice) {
        final set = _selectedOptionsByQuestion[q.id];
        if (set != null && set.isNotEmpty) answered++;
      } else if (q.isMatching) {
        final map = _matchingByQuestion[q.id];
        final totalStmts = q.matchingStatements?.length ?? 0;
        if (map != null && map.length == totalStmts && !map.values.contains(null)) answered++;
      } else if (q.isCompletion) {
        final map = _completionByQuestion[q.id];
        final totalGaps = (q.completionSentences ?? const <CompletionSentence>[]) 
            .fold<int>(0, (int sum, CompletionSentence s) => sum + s.gaps.length);
        if (map != null && map.length == totalGaps) answered++;
      } else if (q.isWriteText) {
        final t = _writeTextByQuestion[q.id];
        if ((t?.trim().isNotEmpty ?? false)) answered++;
      } else if (q.isRecordAudio) {
        final u = _audioUrlByQuestion[q.id];
        if (u != null && u.isNotEmpty) answered++;
      }
    }
    final total = _questions.length;
    final allAnswered = total > 0 && answered == total;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skillName),
        backgroundColor: Colors.indigo,
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    if ((_quizTimeMinutes ?? 0) > 0 && !_allSubmitted)
                      Container(
                        width: double.infinity,
                        color: Colors.indigo.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(
                              'Tiempo restante: '
                              '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    // Progress counter
                    Container(
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.list_alt, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Respondidas $answered de $total',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : (answered / (total == 0 ? 1 : total)),
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                allAnswered ? Colors.green : Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Quiz title
                          Text(widget.quizTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          // Material
                          _buildMaterial(),
                          const SizedBox(height: 8),
                          // Questions
                          if (_questions.isEmpty)
                            const Text('Esta actividad aún no tiene preguntas')
                          else
                            ..._questions.asMap().entries.map((e) => _buildQuestionCard(e.value, e.key)),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _allSubmitted || !allAnswered ? null : () => _submitAllAnswers(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            _allSubmitted
                                ? 'Respuestas enviadas'
                                : allAnswered
                                    ? 'Enviar respuestas'
                                    : 'Responde todas para enviar',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _RecordAudioWidget extends StatefulWidget {
  final int thinkSeconds;
  final int maxRecordSeconds;
  final String? existingUrl;
  final ValueChanged<String> onUploaded;

  const _RecordAudioWidget({
    required this.thinkSeconds,
    required this.maxRecordSeconds,
    required this.existingUrl,
    required this.onUploaded,
  });

  @override
  State<_RecordAudioWidget> createState() => _RecordAudioWidgetState();
}

class _RecordAudioWidgetState extends State<_RecordAudioWidget> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isThinking = false;
  int _remaining = 0;
  Timer? _timer;
  String? _uploadedUrl;

  @override
  void initState() {
    super.initState();
    _uploadedUrl = widget.existingUrl;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    // Thinking countdown
    setState(() {
      _isThinking = true;
      _remaining = widget.thinkSeconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        t.cancel();
        setState(() {
          _isThinking = false;
          _isRecording = true;
          _remaining = widget.maxRecordSeconds;
        });
        await _startRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sin permiso de micrófono')));
      setState(() {
        _isRecording = false;
      });
      return;
    }
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: filePath,
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        await _stopRecording();
        t.cancel();
      }
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;
    // Upload to Supabase Storage
    try {
      final userId = 'temp-user'; // reemplazar con user real si se necesita en este contexto
      final file = File(path);
      final name = 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storage = SupabaseStorageService();
      final res = await storage.uploadAudio(userId: userId, audioFile: file, fileName: name);
      if (res['success'] == true) {
        setState(() => _uploadedUrl = res['url'] as String);
        widget.onUploaded(_uploadedUrl!);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Grabación subida')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error subiendo audio: ${res['error']}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error subiendo audio: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isThinking) {
      return Row(
        children: [
          const Icon(Icons.psychology, color: Colors.indigo),
          const SizedBox(width: 8),
          Text('Piensa... ${_remaining}s'),
        ],
      );
    }
    if (_isRecording) {
      return Row(
        children: [
          const Icon(Icons.mic, color: Colors.red),
          const SizedBox(width: 8),
          Text('Grabando... ${_remaining}s'),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _stopRecording,
            child: const Text('Detener'),
          )
        ],
      );
    }
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: (_uploadedUrl == null) ? _start : null,
          icon: const Icon(Icons.mic),
          label: const Text('Grabar'),
        ),
        const SizedBox(width: 12),
        if (_uploadedUrl != null) ...[
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 6),
          const Text('Audio guardado')
        ],
      ],
    );
  }
}
