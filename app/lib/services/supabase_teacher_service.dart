import '../config/supabase_config.dart';

/// Supabase Teacher Service
/// Handles all teacher-related database queries
class SupabaseTeacherService {

  /// Get teacher information by user ID
  /// Returns teacher data or null if user is not a teacher
  static Future<Map<String, dynamic>?> getTeacherByUserId(int userId) async {
    try {
      print('🔍 DEBUG: Buscando docente con id_usuario = $userId');

      // First, let's verify the user exists
      final userCheck = await supabase
          .from('usuarios')
          .select('id_usuario, nombre_completo, email, es_docente, rol')
          .eq('id_usuario', userId)
          .maybeSingle();

      print('🔍 DEBUG: Usuario encontrado: $userCheck');

      // Now check for teacher record
      final response = await supabase
          .from('docentes')
          .select('*')
          .eq('id_usuario', userId)
          .maybeSingle();

      print('🔍 DEBUG: Docente encontrado: $response');

      return response;
    } catch (e) {
      print('❌ ERROR getting teacher by user ID: $e');
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
            preguntas:id_pregunta(texto_pregunta, tipo_pregunta),
            usuarios:id_usuario(nombre_completo, email)
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
            usuarios:id_usuario(nombre_completo, email)
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
