import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Asegúrate de tener google_fonts
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Importaciones de tu proyecto (ajusta las rutas si es necesario)
import '../config/supabase_config.dart';
import '../models/question_model.dart';
import '../models/matching_models.dart';
import '../models/completion_models.dart';
import '../models/material_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/supabase_storage_service.dart';
import '../widgets/pdf_viewer_widget.dart';

class ActivityPlayerScreen extends StatefulWidget {
  final int quizId;
  final int skillId;
  final String skillName;
  final String quizTitle;
  final String courseName;

  const ActivityPlayerScreen({
    Key? key,
    required this.quizId,
    required this.skillId,
    required this.skillName,
    required this.quizTitle,
    this.courseName = 'Course',
  }) : super(key: key);

  @override
  State<ActivityPlayerScreen> createState() => _ActivityPlayerScreenState();
}

class _ActivityPlayerScreenState extends State<ActivityPlayerScreen> {
  // --- VARIABLES DE ESTADO ---
  bool _isLoading = true;
  String? _errorMessage;
  MaterialModel? _material;
  List<QuestionModel> _questions = [];

  // Respuestas en memoria
  final Map<int, Set<int>> _selectedOptionsByQuestion = {};
  final Map<int, Map<int, int>> _matchingByQuestion = {};
  final Map<int, Map<int, String>> _completionByQuestion = {};
  final Map<int, Map<int, TextEditingController>> _completionControllers = {};
  final Map<int, String> _writeTextByQuestion = {};
  final Map<int, TextEditingController> _writeTextControllers = {};
  final Map<int, String?> _audioUrlByQuestion = {};

  bool _allSubmitted = false;
  final _audioPlayer = AudioPlayer();
  int _secondsRemaining = 0;
  Timer? _timer;
  int? _quizTimeMinutes;

  late final Color _courseColor; // Color del tema

  @override
  void initState() {
    super.initState();
    _courseColor = _getCourseColor(widget.courseName);
    _load();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    // Limpiar controladores
    for (var map in _completionControllers.values) {
      for (var ctrl in map.values) ctrl.dispose();
    }
    for (var ctrl in _writeTextControllers.values) ctrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CARGA (INTACTA) ---
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 1. Cargar info del quiz (tiempo)
      try {
        final quizRow = await supabase
            .from('cuestionarios')
            .select('tiempo_limite_minutos, titulo')
            .eq('id_cuestionario', widget.quizId)
            .single();
        _quizTimeMinutes = quizRow['tiempo_limite_minutos'] as int?;
      } catch (_) {}

      // 2. Cargar material (si existe)
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

      // 3. Cargar preguntas
      final cp = await supabase
          .from('cuestionario_preguntas')
          .select('id_pregunta, orden')
          .eq('id_cuestionario', widget.quizId)
          .order('orden', ascending: true);
      final cpList = List<Map<String, dynamic>>.from(cp as List);

      if (cpList.isEmpty) {
        setState(() { _questions = []; _isLoading = false; });
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

      final matchingIds = qList.where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('matching')).map((q) => q['id_pregunta'] as int).toList();
      final completionIds = qList.where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('completion')).map((q) => q['id_pregunta'] as int).toList();
      final writeTextIds = qList.where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('write')).map((q) => q['id_pregunta'] as int).toList();
      final recordAudioIds = qList.where((q) => ((q['tipo_pregunta'] as String?) ?? '').toLowerCase().contains('record')).map((q) => q['id_pregunta'] as int).toList();

      List<Map<String, dynamic>> mAnswers = [];
      List<Map<String, dynamic>> mStatements = [];
      if (matchingIds.isNotEmpty) {
        final a = await supabase.from('matching_answers').select('id, id_pregunta, texto, orden').inFilter('id_pregunta', matchingIds).order('orden');
        mAnswers = List<Map<String, dynamic>>.from(a as List);
        final s = await supabase.from('matching_statements').select('id, id_pregunta, texto, orden, correct_answer_id').inFilter('id_pregunta', matchingIds).order('orden');
        mStatements = List<Map<String, dynamic>>.from(s as List);
      }

      List<Map<String, dynamic>> cSentences = [];
      List<Map<String, dynamic>> cGaps = [];
      if (completionIds.isNotEmpty) {
        final cs = await supabase.from('completion_sentences').select('id, id_pregunta, texto_template, orden').inFilter('id_pregunta', completionIds).order('orden');
        cSentences = List<Map<String, dynamic>>.from(cs as List);
        final sentIds = cSentences.map((e) => e['id'] as int).toList();
        if (sentIds.isNotEmpty) {
          final cg = await supabase.from('completion_gaps').select('id, sentence_id, gap_index, correct_text').inFilter('sentence_id', sentIds).order('gap_index');
          cGaps = List<Map<String, dynamic>>.from(cg as List);
        }
      }

      Map<int, int> maxWordsByQ = {};
      if (writeTextIds.isNotEmpty) {
        final wt = await supabase.from('write_text_config').select('id_pregunta, max_words').inFilter('id_pregunta', writeTextIds);
        for (final r in List<Map<String, dynamic>>.from(wt as List)) maxWordsByQ[(r['id_pregunta'] as num).toInt()] = (r['max_words'] as num).toInt();
      }

      Map<int, Map<String, int>> audioConfigByQ = {};
      if (recordAudioIds.isNotEmpty) {
        final ra = await supabase.from('record_audio_config').select('id_pregunta, think_time_seconds, max_record_seconds').inFilter('id_pregunta', recordAudioIds);
        for (final r in List<Map<String, dynamic>>.from(ra as List)) {
          audioConfigByQ[(r['id_pregunta'] as num).toInt()] = {'think': (r['think_time_seconds'] as num).toInt(), 'max': (r['max_record_seconds'] as num).toInt()};
        }
      }
      // --- FIN BLOQUE DE CARGA AUXILIAR ---

      final byId = <int, Map<String, dynamic>>{};
      for (final q in qList) {
        final tipo = (q['tipo_pregunta'] as String? ?? '').toLowerCase();
        String normalized = tipo.contains('multiple') ? 'multiple_choice' : tipo.contains('matching') ? 'matching' : tipo.contains('completion') ? 'completion' : tipo.contains('record') ? 'record_audio' : (tipo.contains('write') || tipo.contains('texto')) ? 'write_text' : 'multiple_choice';

        final qid = q['id_pregunta'] as int;
        final myAnswers = mAnswers.where((e) => e['id_pregunta'] == qid).toList();
        final myStatements = mStatements.where((e) => e['id_pregunta'] == qid).toList();
        final mySentences = cSentences.where((e) => e['id_pregunta'] == qid).toList();
        final sentWithGaps = mySentences.map((s) => {...s, 'gaps': cGaps.where((g) => g['sentence_id'] == s['id']).toList()}).toList();

        byId[qid] = {
          'id': q['id_pregunta'],
          'id_habilidad': q['id_habilidad'] ?? widget.skillId,
          'texto_pregunta': q['texto_pregunta'],
          'tipo_pregunta': normalized,
          'nivel_dificultad': q['nivel_dificultad'] ?? 'Basico',
          'puntaje': q['puntos'] ?? 1,
          'tiempo_limite_segundos': null,
          'opciones': optList.where((o) => o['id_pregunta'] == qid).map((o) => {'id': o['id_opcion'], 'pregunta_id': o['id_pregunta'], 'texto_opcion': o['texto_opcion'], 'es_correcta': o['es_correcta']}).toList(),
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
        // Timer
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
      setState(() => _errorMessage = 'Error loading activity: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAllAnswers({bool auto = false}) async {
    if (_allSubmitted) return;
    final user = context.read<AuthProvider>().user;
    final userId = user?.idUsuario;
    if (userId == null) {
      if (!auto) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must log in to submit answers')));
      return;
    }

    // Validación de completitud
    int answered = 0;
    for (final q in _questions) {
      if (q.isMultipleChoice) {
        if ((_selectedOptionsByQuestion[q.id]?.isNotEmpty ?? false)) answered++;
      } else if (q.isMatching) {
        final map = _matchingByQuestion[q.id];
        final totalStmts = q.matchingStatements?.length ?? 0;
        if (map != null && map.length == totalStmts && !map.values.contains(null)) answered++;
      } else if (q.isCompletion) {
        final map = _completionByQuestion[q.id];
        final totalGaps = (q.completionSentences ?? []).fold<int>(0, (sum, s) => sum + s.gaps.length);
        if (map != null && map.length == totalGaps) answered++;
      } else if (q.isWriteText) {
        if ((_writeTextByQuestion[q.id]?.trim().isNotEmpty ?? false)) answered++;
      } else if (q.isRecordAudio) {
        if ((_audioUrlByQuestion[q.id]?.isNotEmpty ?? false)) answered++;
      }
    }

    if (!auto && (answered < _questions.length)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please answer all questions ($answered/${_questions.length})')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final futures = <Future>[];
      for (final q in _questions) {
        if (q.isMultipleChoice) {
          final set = _selectedOptionsByQuestion[q.id] ?? const {};
          futures.add(ApiService.submitAnswerMultipleChoice(userId: userId, preguntaId: q.id, optionIds: set.toList(), quizId: widget.quizId));
        } else if (q.isMatching) {
          final map = _matchingByQuestion[q.id] ?? const {};
          futures.add(ApiService.submitAnswerMatching(userId: userId, preguntaId: q.id, statementToAnswer: Map<int, int>.from(map), quizId: widget.quizId));
        } else if (q.isCompletion) {
          final map = _completionByQuestion[q.id] ?? const {};
          futures.add(ApiService.submitAnswerCompletion(userId: userId, preguntaId: q.id, gapToText: Map<int, String>.from(map), quizId: widget.quizId));
        } else if (q.isWriteText) {
          final text = _writeTextByQuestion[q.id] ?? '';
          futures.add(ApiService.submitAnswerWriteText(userId: userId, preguntaId: q.id, text: text, quizId: widget.quizId));
        } else if (q.isRecordAudio) {
          final url = _audioUrlByQuestion[q.id] ?? '';
          futures.add(ApiService.submitAnswerRecordAudio(userId: userId, preguntaId: q.id, audioUrl: url, quizId: widget.quizId));
        }
      }
      await Future.wait(futures);
      if (mounted) {
        setState(() {
          _allSubmitted = true;
          _timer?.cancel();
          _secondsRemaining = 0;
        });
        if (!auto) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Answers submitted successfully')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPERS VISUALES (ESTÁNDAR DE ORO) ---
  Color _getCourseColor(String courseName) {
    String lower = courseName.toLowerCase();
    if (lower.contains('toefl')) return const Color(0xFFD9232A);
    if (lower.contains('ielts')) return const Color(0xFF23408E);
    if (lower.contains('business')) return const Color(0xFFB02224);
    return const Color(0xFF1F3A89);
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: _courseColor.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _courseColor, width: 2)),
    );
  }

  // --- BUILD PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    // Calculamos contestadas
    int answered = 0;
    for (final q in _questions) {
      if (q.isMultipleChoice) {
        if ((_selectedOptionsByQuestion[q.id]?.isNotEmpty ?? false)) answered++;
      } else if (q.isMatching) {
        if ((_matchingByQuestion[q.id]?.length ?? 0) == (q.matchingStatements?.length ?? 0)) answered++;
      } else if (q.isCompletion) {
        final totalGaps = (q.completionSentences ?? []).fold<int>(0, (s, e) => s + e.gaps.length);
        if ((_completionByQuestion[q.id]?.length ?? 0) == totalGaps) answered++;
      } else if (q.isWriteText) {
        if ((_writeTextByQuestion[q.id]?.trim().isNotEmpty ?? false)) answered++;
      } else if (q.isRecordAudio) {
        if ((_audioUrlByQuestion[q.id]?.isNotEmpty ?? false)) answered++;
      }
    }
    final total = _questions.length;
    final allAnswered = total > 0 && answered == total;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _courseColor, strokeWidth: 5.0))
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : Column(
          children: [
            // 1. ENCABEZADO
            _buildHeader(),

            // 2. BARRA DE PROGRESO
            LinearProgressIndicator(
              value: total == 0 ? 0 : (answered / total),
              backgroundColor: Colors.grey[100],
              color: _courseColor,
              minHeight: 4,
            ),

            // 3. CONTENIDO (Material + Preguntas)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Título de la Actividad
                  Text(
                    widget.quizTitle,
                    style: GoogleFonts.ptSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _allSubmitted ? 'Activity Completed' : 'Answer all questions below',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Material (Si existe)
                  if (_material != null) _buildMaterialCard(),
                  if (_material != null) const SizedBox(height: 24),

                  // Lista de Preguntas
                  if (_questions.isEmpty)
                    const Center(child: Text('No questions available'))
                  else
                    ..._questions.asMap().entries.map((e) => _buildQuestionCard(e.value, e.key)),
                ],
              ),
            ),

            // 4. BOTÓN INFERIOR
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_allSubmitted || !allAnswered) ? null : () => _submitAllAnswers(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _courseColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    _allSubmitted
                        ? 'Answers Submitted'
                        : allAnswered
                        ? 'Submit Answers'
                        : 'Answer all questions to submit ($answered/$total)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES VISUALES ---

  Widget _buildHeader() {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    final timerText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if ((_quizTimeMinutes ?? 0) > 0 && !_allSubmitted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: _courseColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: _courseColor),
                  const SizedBox(width: 6),
                  Text(timerText, style: TextStyle(color: _courseColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard() {
    final m = _material!;
    final type = m.tipoMaterial.toLowerCase();
    IconData icon = Icons.description;
    if (type == 'audio') icon = Icons.audiotrack;
    if (type == 'image') icon = Icons.image;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _courseColor, size: 20),
              const SizedBox(width: 8),
              Text('Study Material', style: TextStyle(color: _courseColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(m.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          if (type == 'text' || type == 'texto')
            Text(m.contenidoTexto ?? '', style: TextStyle(color: Colors.grey[800], height: 1.5))
          else if ((type == 'image' || type == 'imagen') && (m.archivoUrl?.isNotEmpty ?? false))
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(m.archivoUrl!))
          else if (type == 'audio' && (m.archivoUrl?.isNotEmpty ?? false))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Play Audio'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_filled, size: 32),
                  color: _courseColor,
                  onPressed: () async {
                    try { await _audioPlayer.stop(); await _audioPlayer.play(UrlSource(m.archivoUrl!)); } catch (_) {}
                  },
                ),
              )
            else if (type == 'pdf' && (m.archivoUrl?.isNotEmpty ?? false))
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, side: BorderSide(color: Colors.grey[300]!)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PDFViewerWidget(pdfUrl: m.archivoUrl!, title: m.titulo))),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View PDF'),
                ),
        ],
      ),
    );
  }

  // --- RENDERIZADO DE PREGUNTAS (ESTILO ACTUALIZADO) ---
  Widget _buildQuestionCard(QuestionModel q, int index) {
    Widget body;

    // 1. Multiple Choice
    if (q.isMultipleChoice) {
      final selected = _selectedOptionsByQuestion[q.id] ?? <int>{};
      final options = q.opciones ?? [];
      body = Column(
        children: options.map((o) {
          final isSelected = selected.contains(o.id);
          final isCorrect = o.esCorrecta;
          Color borderColor = Colors.grey[200]!;
          Color bgColor = Colors.white;
          IconData icon = isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked;
          Color iconColor = isSelected ? _courseColor : Colors.grey[400]!;

          if (_allSubmitted) {
            if (isCorrect) {
              borderColor = Color(0xFF1A3075);
              bgColor = Color(0xFFE5E4EE);
              icon = Icons.check_circle_rounded;
              iconColor = Color(0xFF1A3075);
            } else if (isSelected && !isCorrect) {
              borderColor = Color(0xFFD9232A);
              bgColor = Colors.red.withOpacity(0.05);
              icon = Icons.cancel_rounded;
              iconColor = Color(0xFFD9232A);
            }
          } else if (isSelected) {
            borderColor = _courseColor;
            bgColor = _courseColor.withOpacity(0.05);
          }

          return GestureDetector(
            onTap: _allSubmitted ? null : () {
              setState(() {
                final set = _selectedOptionsByQuestion.putIfAbsent(q.id, () => <int>{});
                // Lógica para single selection (si quieres multiple, quita el clear)
                // set.clear();
                if (set.contains(o.id)) set.remove(o.id); else set.add(o.id);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: isSelected || _allSubmitted ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text(o.textoOpcion, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
    // 2. Matching
    else if (q.isMatching) {
      final statements = q.matchingStatements ?? [];
      final answers = q.matchingAnswers ?? [];
      final map = _matchingByQuestion.putIfAbsent(q.id, () => {});

      body = Column(
        children: statements.map((s) {
          final selectedVal = map[s.id];
          final isCorrect = _allSubmitted && selectedVal == s.correctAnswerId;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _allSubmitted ? (isCorrect ? Color(0xFF1A3075) : Color(
                  0xFFD9232A)) : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(child: Text(s.texto, style: const TextStyle(fontWeight: FontWeight.w500))),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedVal,
                  hint: Text('Select', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  underline: const SizedBox(), // Quitar línea fea
                  icon: Icon(Icons.arrow_drop_down, color: _courseColor),
                  items: answers.map((a) => DropdownMenuItem(value: a.id, child: Text(a.texto, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: _allSubmitted ? null : (v) => setState(() => map[s.id] = v!),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
    // 3. Completion
    else if (q.isCompletion) {
      final sentences = q.completionSentences ?? [];
      final map = _completionByQuestion.putIfAbsent(q.id, () => {});
      final ctrls = _completionControllers.putIfAbsent(q.id, () => {});

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sentences.map((s) {
          final parts = <Widget>[];
          final reg = RegExp(r'\{\{(\d+)\}\}');
          int last = 0;
          for (final m in reg.allMatches(s.textoTemplate)) {
            if (m.start > last) parts.add(Text(s.textoTemplate.substring(last, m.start), style: const TextStyle(fontSize: 16, height: 1.5)));

            final gapIndex = int.parse(m.group(1)!);
            final gap = s.gaps.firstWhere((g) => g.gapIndex == gapIndex);
            final ctrl = ctrls.putIfAbsent(gap.id, () => TextEditingController(text: map[gap.id] ?? ''));
            final isCorrect = _allSubmitted && ctrl.text.trim().toLowerCase() == gap.correctText.trim().toLowerCase();

            parts.add(SizedBox(
              width: 120,
              child: TextField(
                controller: ctrl,
                readOnly: _allSubmitted,
                onChanged: (v) => map[gap.id] = v,
                textAlign: TextAlign.center,
                style: TextStyle(color: _allSubmitted ? (isCorrect ? Colors.green : Colors.red) : Colors.black),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  isDense: true,
                  filled: true,
                  fillColor: _allSubmitted ? (isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1)) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ));
            last = m.end;
          }
          if (last < s.textoTemplate.length) parts.add(Text(s.textoTemplate.substring(last), style: const TextStyle(fontSize: 16, height: 1.5)));

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 8, spacing: 4, children: parts),
          );
        }).toList(),
      );
    }
    // 4. Write Text
    else if (q.isWriteText) {
      final max = q.maxWords ?? 0;
      final ctrl = _writeTextControllers.putIfAbsent(q.id, () => TextEditingController(text: _writeTextByQuestion[q.id] ?? ''));

      body = Column(
        children: [
          TextField(
            controller: ctrl,
            readOnly: _allSubmitted,
            maxLines: 6,
            onChanged: (v) { if (!_allSubmitted) { _writeTextByQuestion[q.id] = v; setState((){}); } },
            decoration: _inputDeco('Type your answer here...'),
          ),
          if (max > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('${_wordCount(ctrl.text)} / $max words', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ),
            ),
        ],
      );
    }
    // 5. Record Audio
    else if (q.isRecordAudio) {
      body = _buildRecordAudio(q);
    } else {
      body = const Text('Question type not supported');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Question ${index + 1}", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
              if (q.puntaje > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Color(0xFFE5E8EE), borderRadius: BorderRadius.circular(4)),
                  child: Text("${q.puntaje} pts", style: const TextStyle(color: Color(
                      0xFF1A3075), fontSize: 10, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(q.textoPregunta, style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          body,
          if (_allSubmitted && (q.explicacionGeneral?.isNotEmpty ?? false))
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Color(0xFFECEEF3), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.lightbulb, color: Color(0xFF1A3075), size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(q.explicacionGeneral!, style: TextStyle(color: Color(0xFF1A3075), fontSize: 13))),
              ]),
            ),
        ],
      ),
    );
  }

  int _wordCount(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  Widget _buildRecordAudio(QuestionModel q) {
    // Se eliminan los tiempos de preparación y límite de grabación
    // Ignoramos valores provenientes de DB para deshabilitar tiempos
    final think = 0;
    final max = 0;
    final url = _audioUrlByQuestion[q.id];
    return _RecordAudioWidget(
      thinkSeconds: think,
      maxRecordSeconds: max,
      existingUrl: url,
      readOnly: _allSubmitted,
      onUploaded: (u) => setState(() => _audioUrlByQuestion[q.id] = u),
      activeColor: _courseColor,
    );
  }
}

// --- WIDGET DE GRABACIÓN DE AUDIO (MODERNO) ---
class _RecordAudioWidget extends StatefulWidget {
  final int thinkSeconds;
  final int maxRecordSeconds;
  final String? existingUrl;
  final bool readOnly;
  final ValueChanged<String> onUploaded;
  final Color activeColor;

  const _RecordAudioWidget({
    required this.thinkSeconds,
    required this.maxRecordSeconds,
    required this.existingUrl,
    required this.readOnly,
    required this.onUploaded,
    required this.activeColor,
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
    // Si no hay tiempo de preparación, comenzar a grabar de inmediato
    if (widget.thinkSeconds <= 0) {
      setState(() {
        _isThinking = false;
        _isRecording = true;
        _remaining = widget.maxRecordSeconds;
      });
      await _startRecording();
      return;
    }

    // Mantener cuenta regresiva de preparación solo si es > 0
    setState(() { _isThinking = true; _remaining = widget.thinkSeconds; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        t.cancel();
        setState(() { _isThinking = false; _isRecording = true; _remaining = widget.maxRecordSeconds; });
        await _startRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000), path: filePath);
    _timer?.cancel();

    // Si hay límite de grabación (>0), iniciar countdown; si no, grabación sin límite hasta detener manualmente
    if (widget.maxRecordSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (_remaining > 0) {
          setState(() => _remaining--);
        } else {
          await _stopRecording();
          t.cancel();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;

    // Subir a Supabase
    try {
      final file = File(path);
      final name = 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storage = SupabaseStorageService();
      final res = await storage.uploadAudio(userId: 'temp', audioFile: file, fileName: name); // Ajusta userID real si puedes
      if (res['success'] == true) {
        setState(() => _uploadedUrl = res['url'] as String);
        widget.onUploaded(_uploadedUrl!);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) {
      if (_uploadedUrl != null) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [Icon(Icons.mic_rounded, color: Colors.green), SizedBox(width: 12), Text("Audio Recorded", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
        );
      }
      return const Text("No audio recorded", style: TextStyle(color: Colors.grey));
    }

    if (_isThinking) {
      return Center(
        child: Column(
          children: [
            const Text("Prepare your answer...", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text("$_remaining s", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.activeColor)),
          ],
        ),
      );
    }

    if (_isRecording) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.mic_rounded, color: Color(0xFFD9232A), size: 32),
            const SizedBox(height: 8),
            // Si no hay límite, no mostramos cuenta regresiva
            if (widget.maxRecordSeconds > 0)
              Text("Recording... $_remaining s", style: const TextStyle(color: Color(0xFFD9232A), fontWeight: FontWeight.bold))
            else
              const Text("Recording...", style: TextStyle(color: Color(0xFFD9232A), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _stopRecording, child: const Text("Stop Recording"))
          ],
        ),
      );
    }

    if (_uploadedUrl != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF1A3075), size: 48),
            const SizedBox(height: 8),
            const Text("Audio Saved", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3075))),
            TextButton(onPressed: () => setState(() => _uploadedUrl = null), child: const Text("Record Again"))
          ],
        ),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: _start,
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: widget.activeColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.mic_rounded, color: widget.activeColor, size: 32),
        ),
      ),
    );
  }
}
