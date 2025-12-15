import 'package:englishpro_app/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para gestionar las operaciones de datos relacionadas con los estudiantes.
class SupabaseStudentService {
  /// Obtiene el perfil de un estudiante basado en su ID de usuario.
  ///
  /// Realiza una consulta a la tabla `usuarios` para encontrar el perfil
  /// completo del estudiante.
  static Future<Map<String, dynamic>?> getStudentByUserId(int userId) async {
    try {
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id_usuario', userId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching student by user ID: $e');
      return null;
    }
  }

  /// Obtiene las estadísticas de progreso de un estudiante.
  ///
  /// Realiza consultas a las tablas `Progreso_Usuarios` y `Respuestas_Usuario`
  /// para calcular métricas clave del rendimiento del estudiante.
  static Future<Map<String, dynamic>> getStudentStats(int userId) async {
    try {
      // Obtener el total de puntos y cursos iniciados
      final progressResponse = await supabase
          .from('progreso_usuarios')
          .select('puntos_totales')
          .eq('id_usuario', userId);

      int totalPoints = 0;
      if (progressResponse.isNotEmpty) {
        totalPoints = progressResponse
            .map<int>((item) => (item['puntos_totales'] as int?) ?? 0)
            .reduce((a, b) => a + b);
      }
      final coursesStarted = progressResponse.length;

      // Obtener el total de retroalimentaciones recibidas
      final feedbackCountResponse = await supabase
          .from('retroalimentacion_docente')
          .count()
          .eq('id_respuesta.id_usuario', userId); // Join implicit

      final feedbacksReceived = feedbackCountResponse;

      return {
        'total_puntos': totalPoints,
        'cursos_iniciados': coursesStarted,
        'retroalimentaciones_recibidas': feedbacksReceived ?? 0,
      };
    } catch (e) {
      print('Error fetching student stats: $e');
      return {
        'total_puntos': 0,
        'cursos_iniciados': 0,
        'retroalimentaciones_recibidas': 0,
      };
    }
  }
}
