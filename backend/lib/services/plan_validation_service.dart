import 'package:postgres/postgres.dart';
import 'database_service.dart';

class PlanValidationService {
  final DatabaseService _dbService;

  PlanValidationService(this._dbService);

  // Límites por plan (hardcoded según diseño)
  static const Map<String, Map<String, dynamic>> planLimits = {
    'Freemium': {
      'limite_quizzes_diarios': 3,
      'limite_quizzes_mensuales': 50,
      'limite_preguntas_por_tipo': 50,
      'acceso_completo_cursos': false,
      'retroalimentacion_manual': false,
      'sesiones_en_vivo': 0,
      'simulacros_completos': 0,
    },
    'Básico': {
      'limite_quizzes_diarios': 10,
      'limite_quizzes_mensuales': 200,
      'limite_preguntas_por_tipo': 200,
      'acceso_completo_cursos': false,
      'retroalimentacion_manual': false,
      'sesiones_en_vivo': 0,
      'simulacros_completos': 1,
    },
    'Pro': {
      'limite_quizzes_diarios': 50,
      'limite_quizzes_mensuales': 1000,
      'limite_preguntas_por_tipo': 1000,
      'acceso_completo_cursos': true,
      'retroalimentacion_manual': true,
      'sesiones_en_vivo': 2,
      'simulacros_completos': 5,
    },
    'Premium': {
      'limite_quizzes_diarios': 999999,
      'limite_quizzes_mensuales': 999999,
      'limite_preguntas_por_tipo': 999999,
      'acceso_completo_cursos': true,
      'retroalimentacion_manual': true,
      'sesiones_en_vivo': 10,
      'simulacros_completos': 999999,
    },
  };

  /// Obtiene el plan actual de un usuario
  Future<String> getUserPlan(int userId) async {
    final connection = await _dbService.connection;

    final result = await connection.execute(
      Sql.named(
        '''
        SELECT p.Nombre_Plan
        FROM Usuarios u
        JOIN Planes p ON u.ID_Plan = p.ID_Plan
        WHERE u.ID_Usuario = @userId
        ''',
      ),
      parameters: {
        'userId': userId,
      },
    );

    if (result.isEmpty) {
      throw Exception('Usuario no encontrado');
    }

    final plan = result.first[0] as String?;
    return plan ?? 'Freemium';
  }

  /// Valida si un usuario puede realizar un cuestionario (límite diario)
  Future<Map<String, dynamic>> canTakeQuizToday(int userId) async {
    final plan = await getUserPlan(userId);
    final limits = planLimits[plan] ?? planLimits['Freemium']!;
    final dailyLimit = limits['limite_quizzes_diarios'] as int;

    // Contar cuestionarios realizados hoy
    final connection = await _dbService.connection;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await connection.execute(
      Sql.named(
        '''
        SELECT COUNT(*) as count
        FROM Intentos_Cuestionario
        WHERE id_usuario = @userId
          AND fecha_inicio >= @startOfDay
          AND fecha_inicio < @endOfDay
          AND estado = 'Completado'
        ''',
      ),
      parameters: {
        'userId': userId,
        'startOfDay': startOfDay.toIso8601String(),
        'endOfDay': endOfDay.toIso8601String(),
      },
    );

    final count = result.first[0] as int;
    final canTake = count < dailyLimit;

    return {
      'canTake': canTake,
      'used': count,
      'limit': dailyLimit,
      'remaining': dailyLimit - count,
      'plan': plan,
    };
  }

  /// Valida si un usuario puede realizar un cuestionario (límite mensual)
  Future<Map<String, dynamic>> canTakeQuizThisMonth(int userId) async {
    final plan = await getUserPlan(userId);
    final limits = planLimits[plan] ?? planLimits['Freemium']!;
    final monthlyLimit = limits['limite_quizzes_mensuales'] as int;

    // Contar cuestionarios realizados este mes
    final connection = await _dbService.connection;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final result = await connection.execute(
      Sql.named(
        '''
        SELECT COUNT(*) as count
        FROM Intentos_Cuestionario
        WHERE id_usuario = @userId
          AND fecha_inicio >= @startOfMonth
          AND fecha_inicio < @endOfMonth
          AND estado = 'Completado'
        ''',
      ),
      parameters: {
        'userId': userId,
        'startOfMonth': startOfMonth.toIso8601String(),
        'endOfMonth': endOfMonth.toIso8601String(),
      },
    );

    final count = result.first[0] as int;
    final canTake = count < monthlyLimit;

    return {
      'canTake': canTake,
      'used': count,
      'limit': monthlyLimit,
      'remaining': monthlyLimit - count,
      'plan': plan,
    };
  }

  /// Valida límites combinados (diario y mensual)
  Future<Map<String, dynamic>> validateQuizLimits(int userId) async {
    final dailyCheck = await canTakeQuizToday(userId);
    final monthlyCheck = await canTakeQuizThisMonth(userId);

    final canTake = dailyCheck['canTake'] as bool &&
        monthlyCheck['canTake'] as bool;

    return {
      'canTake': canTake,
      'plan': dailyCheck['plan'],
      'daily': {
        'used': dailyCheck['used'],
        'limit': dailyCheck['limit'],
        'remaining': dailyCheck['remaining'],
      },
      'monthly': {
        'used': monthlyCheck['used'],
        'limit': monthlyCheck['limit'],
        'remaining': monthlyCheck['remaining'],
      },
      'message': canTake
          ? 'Puedes realizar el cuestionario'
          : (!(dailyCheck['canTake'] as bool)
              ? 'Has alcanzado el límite diario de cuestionarios'
              : 'Has alcanzado el límite mensual de cuestionarios'),
    };
  }

  /// Valida si un usuario tiene acceso a retroalimentación manual
  Future<bool> hasManualFeedbackAccess(int userId) async {
    final plan = await getUserPlan(userId);
    final limits = planLimits[plan] ?? planLimits['Freemium']!;
    return limits['retroalimentacion_manual'] as bool;
  }

  /// Valida si un usuario tiene acceso completo a todos los cursos
  Future<bool> hasFullCourseAccess(int userId) async {
    final plan = await getUserPlan(userId);
    final limits = planLimits[plan] ?? planLimits['Freemium']!;
    return limits['acceso_completo_cursos'] as bool;
  }

  /// Obtiene información completa del plan del usuario
  Future<Map<String, dynamic>> getUserPlanInfo(int userId) async {
    final plan = await getUserPlan(userId);
    final limits = planLimits[plan] ?? planLimits['Freemium']!;

    // Obtener estadísticas de uso actual
    final dailyCheck = await canTakeQuizToday(userId);
    final monthlyCheck = await canTakeQuizThisMonth(userId);

    return {
      'plan': plan,
      'limits': limits,
      'usage': {
        'daily': {
          'used': dailyCheck['used'],
          'limit': dailyCheck['limit'],
          'remaining': dailyCheck['remaining'],
        },
        'monthly': {
          'used': monthlyCheck['used'],
          'limit': monthlyCheck['limit'],
          'remaining': monthlyCheck['remaining'],
        },
      },
    };
  }

  /// Actualiza el plan de un usuario
  Future<bool> updateUserPlan(int userId, String newPlan) async {
    if (!planLimits.containsKey(newPlan)) {
      throw Exception('Plan no válido: $newPlan');
    }

    final connection = await _dbService.connection;

    // Obtener ID del plan
    final planResult = await connection.execute(
      Sql.named(
        'SELECT ID_Plan FROM Planes WHERE Nombre_Plan = @planName',
      ),
      parameters: {
        'planName': newPlan,
      },
    );

    if (planResult.isEmpty) {
      throw Exception('Plan no encontrado: $newPlan');
    }

    final planId = planResult.first[0] as int;

    await connection.execute(
      Sql.named(
        '''
        UPDATE Usuarios
        SET ID_Plan = @planId,
            Ultimo_Acceso = @updatedAt
        WHERE ID_Usuario = @userId
        ''',
      ),
      parameters: {
        'planId': planId,
        'updatedAt': DateTime.now().toIso8601String(),
        'userId': userId,
      },
    );

    return true;
  }

  /// Valida si un usuario puede acceder a un curso específico
  Future<Map<String, dynamic>> canAccessCourse(
    int userId,
    int courseId,
  ) async {
    final hasFullAccess = await hasFullCourseAccess(userId);

    if (hasFullAccess) {
      return {
        'canAccess': true,
        'message': 'Acceso completo con tu plan actual',
      };
    }

    // Cursos básicos disponibles para todos (IDs 1 y 2 por ejemplo)
    final basicCourseIds = [1, 2];
    if (basicCourseIds.contains(courseId)) {
      return {
        'canAccess': true,
        'message': 'Curso básico disponible',
      };
    }

    final plan = await getUserPlan(userId);
    return {
      'canAccess': false,
      'message':
          'Actualiza a plan Pro o Premium para acceder a este curso',
      'currentPlan': plan,
      'requiredPlans': ['Pro', 'Premium'],
    };
  }
}
