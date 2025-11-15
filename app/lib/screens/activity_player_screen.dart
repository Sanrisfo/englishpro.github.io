import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../config/supabase_config.dart';
import '../models/question_model.dart';
import '../models/material_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/pdf_viewer_widget.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final Map<int, int> _selectedOptionByQuestion = {}; // questionId -> optionId
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

      // Build QuestionModel list preserving order
      final byId = <int, Map<String, dynamic>>{};
      for (final q in qList) {
        final tipo = (q['tipo_pregunta'] as String? ?? '').toLowerCase();
        // Normalize type to match model expectations
        String normalized;
        if (tipo.contains('multiple')) {
          normalized = 'multiple_choice';
        } else if (tipo.contains('texto')) {
          normalized = 'open_text';
        } else if (tipo.contains('audio')) {
          normalized = 'audio_response';
        } else {
          normalized = tipo.isEmpty ? 'multiple_choice' : tipo;
        }
        byId[q['id_pregunta'] as int] = {
          'id': q['id_pregunta'],
          'id_habilidad': q['id_habilidad'] ?? widget.skillId,
          'texto_pregunta': q['texto_pregunta'],
          'tipo_pregunta': normalized,
          'nivel_dificultad': q['nivel_dificultad'] ?? 'Basico',
          'puntaje': q['puntos'] ?? 1,
          // Sin tiempo por pregunta; se usa tiempo del cuestionario
          'tiempo_limite_segundos': null,
          'opciones': optList
              .where((o) => o['id_pregunta'] == q['id_pregunta'])
              .map((o) => {
                    'id': o['id_opcion'],
                    'pregunta_id': o['id_pregunta'],
                    'texto_opcion': o['texto_opcion'],
                    'es_correcta': o['es_correcta'],
                  })
              .toList(),
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
    final answered = _selectedOptionByQuestion.length;
    if (!auto && (answered < total)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Responde todas las preguntas ($answered/$total)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final futures = <Future>[];
      _selectedOptionByQuestion.forEach((questionId, optionId) {
        futures.add(ApiService.submitAnswer(
          userId: userId,
          preguntaId: questionId,
          opcionSeleccionadaId: optionId,
          quizId: widget.quizId,
        ));
      });
      await Future.wait(futures);
      if (mounted) {
        setState(() => _allSubmitted = true);
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
    final selected = _selectedOptionByQuestion[q.id];
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
            if ((q.opciones ?? []).isNotEmpty)
              ...q.opciones!.map((o) => RadioListTile<int>(
                    value: o.id,
                    groupValue: selected,
                    onChanged: _allSubmitted
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedOptionByQuestion[q.id] = v;
                            });
                          },
                    title: Text(o.textoOpcion),
                  )),
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

  @override
  Widget build(BuildContext context) {
    final answered = _selectedOptionByQuestion.length;
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
                    if ((_quizTimeMinutes ?? 0) > 0)
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
