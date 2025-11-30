import '../config/supabase_config.dart';

/// Servicio de docentes en Supabase.
/// Gestiona consultas de datos para perfiles, métricas y pendientes.
class SupabaseTeacherService {

  /// Get teacher information by user ID
  /// Returns teacher data or null if user is not a teacher
  static Future<Map<String, dynamic>?> getTeacherByUserId(int userId) async {
    try {
      print('ðŸ” DEBUG: Buscando docente con id_usuario = $userId');

      // First, let's verify the user exists
      final userCheck = await supabase
          .from('usuarios')
          .select('id_usuario, nombre_completo, email, es_docente, rol')
          .eq('id_usuario', userId)
          .maybeSingle();

      print('ðŸ” DEBUG: Usuario encontrado: $userCheck');

      // Now check for teacher record
      final response = await supabase
          .from('docentes')
          .select('*')
          .eq('id_usuario', userId)
          .maybeSingle();

      print('ðŸ” DEBUG: Docente encontrado: $response');

      return response;
    } catch (e) {
      print('âŒ ERROR getting teacher by user ID: $e');
      return null;
    }
  }

  /// Get teacher statistics
  /// Returns stats like total feedbacks, average rating, pending reviews
  static Future<Map<String, dynamic>> getTeacherStats(int teacherId) async {
    try {
      // Get teacher basic info
      final teacher = await supabase
          .from('docentes')
          .select('*')
          .eq('id_docente', teacherId)
          .single();

      // Get total feedbacks count
      final feedbackCountResult = await supabase
          .from('retroalimentacion_docente')
          .select('id_retroalimentacion')
          .eq('id_docente', teacherId)
          .count();

      // Get pending feedbacks (responses that need review and have no feedback yet)
      final pendingResponses = await supabase
          .from('respuestas_usuario')
          .select('id_respuesta')
          .eq('requiere_revision', true);

      int pendingCount = 0;
      if (pendingResponses is List && pendingResponses.isNotEmpty) {
        final ids = pendingResponses
            .map((e) => e['id_respuesta'])
            .where((e) => e != null)
            .toList();

        final existingFeedback = await supabase
            .from('retroalimentacion_docente')
            .select('id_respuesta')
            .inFilter('id_respuesta', ids);

        final feedbackIds = existingFeedback is List
            ? existingFeedback.map((e) => e['id_respuesta']).toSet()
            : <dynamic>{};

        pendingCount = ids.where((id) => !feedbackIds.contains(id)).length;
      }

      // Get graded feedbacks count
      final gradedCount = feedbackCountResult.count ?? 0;

      final totalFeedbacks = teacher['total_retroalimentaciones'] ?? 0;
      final averageRating = teacher['calificacion_promedio'] ?? 0.0;

      return {
        'total_calificaciones': totalFeedbacks,
        'calificadas': gradedCount,
        'pendientes': pendingCount,
        'promedio_puntuacion': averageRating,
      };
    } catch (e) {
      print('Error getting teacher stats: $e');
      return {
        'total_calificaciones': 0,
        'calificadas': 0,
        'pendientes': 0,
        'promedio_puntuacion': 0.0,
      };
    }
  }

  /// Get pending feedbacks (responses that require manual review)
  static Future<List<Map<String, dynamic>>> getPendingFeedbacks() async {
    try {
      final response = await supabase
          .from('respuestas_usuario')
          .select('''
            *,
            preguntas:id_pregunta(id_habilidad, texto_pregunta, tipo_pregunta),
            usuarios:id_usuario(nombre_completo, email, id_plan)
          ''')
          .eq('requiere_revision', true)
          .order('fecha_respuesta', ascending: true);

      final list = List<Map<String, dynamic>>.from(response as List);

      if (list.isEmpty) return [];

      final ids = list
          .map((e) => e['id_respuesta'])
          .where((e) => e != null)
          .toList();

      if (ids.isEmpty) return list;

      final existingFeedback = await supabase
          .from('retroalimentacion_docente')
          .select('id_respuesta')
          .inFilter('id_respuesta', ids);

      final feedbackIds = existingFeedback is List
          ? existingFeedback.map((e) => e['id_respuesta']).toSet()
          : <dynamic>{};

      final filtered = list
          .where((row) => !feedbackIds.contains(row['id_respuesta']))
          .toList();

      // Enriquecer con breadcrumb: Curso > Skill > Tipo de Actividad > Actividad
      try {
        // 1) Juntar IDs necesarios
        final skillIds = <int>{};
        final quizIds = <int>{};
        for (final row in filtered) {
          final pq = (row['preguntas'] as Map?)?.cast<String, dynamic>();
          final sid = (pq?['id_habilidad'] as num?)?.toInt();
          if (sid != null) skillIds.add(sid);
          final qid = (row['id_cuestionario'] as num?)?.toInt();
          if (qid != null) quizIds.add(qid);
        }

        // 2) Cargar habilidades -> {id: {nombre, curso_id}}
        final skillsById = <int, Map<String, dynamic>>{};
        if (skillIds.isNotEmpty) {
          final rs = await supabase
              .from('habilidades')
              .select('id, nombre, curso_id')
              .inFilter('id', skillIds.toList());
          for (final s in (rs as List)) {
            final id = (s['id'] as num).toInt();
            skillsById[id] = {
              'nombre': s['nombre'],
              'curso_id': (s['curso_id'] as num?)?.toInt(),
            };
          }
        }

        // 3) Cargar cursos -> {id: nombre}
        final courseIds = <int>{};
        for (final v in skillsById.values) {
          final cid = v['curso_id'] as int?;
          if (cid != null) courseIds.add(cid);
        }
        final coursesById = <int, String>{};
        if (courseIds.isNotEmpty) {
          final rc = await supabase
              .from('cursos')
              .select('id, nombre')
              .inFilter('id', courseIds.toList());
          for (final c in (rc as List)) {
            coursesById[(c['id'] as num).toInt()] = c['nombre'] as String;
          }
        }

        // 4) Cargar cuestionarios -> {id: {titulo, id_tipo_actividad}}
        final quizzesById = <int, Map<String, dynamic>>{};
        if (quizIds.isNotEmpty) {
          final rq = await supabase
              .from('cuestionarios')
              .select('id_cuestionario, titulo, id_tipo_actividad')
              .inFilter('id_cuestionario', quizIds.toList());
          for (final q in (rq as List)) {
            final id = (q['id_cuestionario'] as num).toInt();
            quizzesById[id] = {
              'titulo': q['titulo'],
              'id_tipo_actividad': (q['id_tipo_actividad'] as num?)?.toInt(),
            };
          }
        }

        // 5) Cargar tipos de actividad -> {id: nombre}
        final typeIds = <int>{};
        for (final v in quizzesById.values) {
          final tid = v['id_tipo_actividad'] as int?;
          if (tid != null) typeIds.add(tid);
        }
        final typesById = <int, String>{};
        if (typeIds.isNotEmpty) {
          final rt = await supabase
              .from('tipos_actividad')
              .select('id, nombre')
              .inFilter('id', typeIds.toList());
          for (final t in (rt as List)) {
            typesById[(t['id'] as num).toInt()] = t['nombre'] as String;
          }
        }

        // 6) Armar breadcrumb por fila y adjuntar
        for (final row in filtered) {
          final pq = (row['preguntas'] as Map?)?.cast<String, dynamic>();
          final sid = (pq?['id_habilidad'] as num?)?.toInt();
          final s = sid != null ? skillsById[sid] : null;
          final courseName = s != null && s['curso_id'] != null
              ? (coursesById[s['curso_id'] as int] ?? '')
              : '';
          final skillName = (s != null ? (s['nombre'] as String? ?? '') : '');
          final qid = (row['id_cuestionario'] as num?)?.toInt();
          final qz = (qid != null) ? quizzesById[qid] : null;
          final typeName = (qz != null && qz['id_tipo_actividad'] != null)
              ? (typesById[qz['id_tipo_actividad'] as int] ?? '')
              : '';
          final activityTitle = (qz != null ? (qz['titulo'] as String? ?? '') : '');

          final parts = <String>[];
          if (courseName.isNotEmpty) parts.add(courseName);
          if (skillName.isNotEmpty) parts.add(skillName);
          if (typeName.isNotEmpty) parts.add(typeName);
          if (activityTitle.isNotEmpty) parts.add(activityTitle);
          row['path_breadcrumb'] = parts.join(' > ');
        }
      } catch (_) {}

      return filtered;
    } catch (e) {
      print('Error getting pending feedbacks: $e');
      return [];
    }
  }

  /// Get all feedbacks by teacher
  static Future<List<Map<String, dynamic>>> getFeedbacksByTeacher(int teacherId) async {
    try {
      final response = await supabase
          .from('retroalimentacion_docente')
          .select('''
            *,
            respuestas_usuario:id_respuesta(
              *,
              preguntas:id_pregunta(texto_pregunta),
              usuarios:id_usuario(nombre_completo)
            )
          ''')
          .eq('id_docente', teacherId)
          .order('fecha_retroalimentacion', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting feedbacks by teacher: $e');
      return [];
    }
  }

  /// Create feedback for a student response
  static Future<Map<String, dynamic>> createFeedback({
    required int responseId,
    required int teacherId,
    required String comment,
    required int grade,
    int? pointsAssigned,
  }) async {
    try {
      final response = await supabase
          .from('retroalimentacion_docente')
          .insert({
            'id_respuesta': responseId,
            'id_docente': teacherId,
            'comentario': comment,
            'calificacion': grade,
            'puntos_asignados': pointsAssigned,
          })
          .select()
          .single();

      // Update response to mark as reviewed and optionally assign points
      final updatePayload = <String, dynamic>{'requiere_revision': false};
      if (pointsAssigned != null) {
        updatePayload['puntos_obtenidos'] = pointsAssigned;
      }
      await supabase
          .from('respuestas_usuario')
          .update(updatePayload)
          .eq('id_respuesta', responseId);

      return {
        'success': true,
        'feedback': response,
      };
    } catch (e) {
      print('Error creating feedback: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get response by ID with question details
  static Future<Map<String, dynamic>?> getResponseById(int responseId) async {
    try {
      final response = await supabase
          .from('respuestas_usuario')
          .select('''
            *,
            preguntas:id_pregunta(*),
            usuarios:id_usuario(nombre_completo, email, id_plan)
          ''')
          .eq('id_respuesta', responseId)
          .single();

      return response;
    } catch (e) {
      print('Error getting response by ID: $e');
      return null;
    }
  }

  /// Create a new teacher profile
  static Future<Map<String, dynamic>> createTeacher({
    required String userId,
    required String especialidad,
    String? certificaciones,
    int? anosExperiencia,
  }) async {
    try {
      final response = await supabase
          .from('docentes')
          .insert({
            'id_usuario': userId,
            'especialidad': especialidad,
            'certificaciones': certificaciones,
            'anos_experiencia': anosExperiencia,
          })
          .select()
          .single();

      // Update user to mark as teacher
      await supabase
          .from('usuarios')
          .update({'es_docente': true, 'rol': 'Docente'})
          .eq('id_usuario', userId);

      return {
        'success': true,
        'teacher': response,
      };
    } catch (e) {
      print('Error creating teacher: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update teacher profile
  static Future<Map<String, dynamic>> updateTeacher({
    required int teacherId,
    String? especialidad,
    String? certificaciones,
    int? anosExperiencia,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (especialidad != null) updates['especialidad'] = especialidad;
      if (certificaciones != null) updates['certificaciones'] = certificaciones;
      if (anosExperiencia != null) updates['anos_experiencia'] = anosExperiencia;

      final response = await supabase
          .from('docentes')
          .update(updates)
          .eq('id_docente', teacherId)
          .select()
          .single();

      return {
        'success': true,
        'teacher': response,
      };
    } catch (e) {
      print('Error updating teacher: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
