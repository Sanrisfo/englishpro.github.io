import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';
import '../models/material_model.dart';
import '../models/question_model.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:8080';

  // Register user
  static Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String email,
    required String password,
    String? profesion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_completo': nombreCompleto,
          'email': email,
          'password': password,
          'profesion': profesion,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
          'token': data['token'] as String,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
          'token': data['token'] as String,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get current user (with token)
  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== COURSES ====================

  /// Get all courses
  static Future<Map<String, dynamic>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/courses'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final coursesData = data['data'] as List<dynamic>;
        final courses = coursesData
            .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'courses': courses,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get courses',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get course by ID
  static Future<Map<String, dynamic>> getCourseById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/courses/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'course': CourseModel.fromJson(data['data'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get course',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== SKILLS ====================

  /// Get all skills
  static Future<Map<String, dynamic>> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/skills'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final skillsData = data['data'] as List<dynamic>;
        final skills = skillsData
            .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'skills': skills,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get skills',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get skills by course ID
  static Future<Map<String, dynamic>> getSkillsByCourse(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/skills/course/$courseId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final skillsData = data['data'] as List<dynamic>;
        final skills = skillsData
            .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'skills': skills,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get skills',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get skill by ID
  static Future<Map<String, dynamic>> getSkillById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/skills/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'skill': SkillModel.fromJson(data['data'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get skill',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== MATERIALS ====================

  /// Get all materials
  static Future<Map<String, dynamic>> getMaterials() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/materials'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final materialsData = data['data'] as List<dynamic>;
        final materials = materialsData
            .map((json) => MaterialModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'materials': materials,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get materials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get materials by skill ID
  static Future<Map<String, dynamic>> getMaterialsBySkill(int skillId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/materials/skill/$skillId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final materialsData = data['data'] as List<dynamic>;
        final materials = materialsData
            .map((json) => MaterialModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'materials': materials,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get materials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get material by ID
  static Future<Map<String, dynamic>> getMaterialById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/materials/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'material': MaterialModel.fromJson(data['data'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get material',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Create material (for teachers)
  static Future<Map<String, dynamic>> createMaterial({
    required int habilidadId,
    required String titulo,
    required String tipoMaterial,
    String? urlRecurso,
    String? contenidoTexto,
    int? duracionMinutos,
    int orden = 1,
    String nivelAcceso = 'Freemium',
    int? creadoPor,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/materials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'habilidad_id': habilidadId,
          'titulo': titulo,
          'tipo_material': tipoMaterial,
          if (urlRecurso != null) 'url_recurso': urlRecurso,
          if (contenidoTexto != null) 'contenido_texto': contenidoTexto,
          if (duracionMinutos != null) 'duracion_minutos': duracionMinutos,
          'orden': orden,
          'nivel_acceso': nivelAcceso,
          if (creadoPor != null) 'creado_por': creadoPor,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'material': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to create material',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update material (for teachers)
  static Future<Map<String, dynamic>> updateMaterial({
    required int materialId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/materials/$materialId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'material': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to update material',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete material (for teachers)
  static Future<Map<String, dynamic>> deleteMaterial(int materialId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/materials/$materialId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to delete material',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== QUESTIONS ====================

  /// Get questions by skill ID
  static Future<Map<String, dynamic>> getQuestionsBySkill(int skillId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/questions/skill/$skillId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final questionsData = data['data'] as List<dynamic>;
        final questions = questionsData
            .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'questions': questions,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get questions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get question by ID with answer options
  static Future<Map<String, dynamic>> getQuestionById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/questions/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'question': QuestionModel.fromJson(data['data'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get question',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Submit user answer
  static Future<Map<String, dynamic>> submitAnswer({
    required int userId,
    required int preguntaId,
    int? opcionSeleccionadaId,
    String? respuestaTexto,
    String? audioUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/answers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': userId,
          'pregunta_id': preguntaId,
          'opcion_seleccionada_id': opcionSeleccionadaId,
          'respuesta_texto': respuestaTexto,
          'audio_url': audioUrl,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'answer': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit answer',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== QUIZZES ====================

  /// Get quizzes by skill ID
  static Future<Map<String, dynamic>> getQuizzesBySkill(int skillId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/quizzes/skill/$skillId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final quizzesData = data['data'] as List<dynamic>;

        return {
          'success': true,
          'quizzes': quizzesData,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get quizzes',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get quiz by ID with questions
  static Future<Map<String, dynamic>> getQuizById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/quizzes/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final quizData = data['data'] as Map<String, dynamic>;

        // Parse questions if available
        List<QuestionModel> questions = [];
        if (quizData['questions'] != null) {
          questions = (quizData['questions'] as List)
              .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return {
          'success': true,
          'quiz': quizData,
          'questions': questions,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get quiz',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Create quiz attempt
  static Future<Map<String, dynamic>> createQuizAttempt({
    required int userId,
    required int quizId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/attempts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': userId,
          'cuestionario_id': quizId,
          'fecha_inicio': DateTime.now().toIso8601String(),
          'estado': 'En Progreso',
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'attempt': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create attempt',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update quiz attempt (complete)
  static Future<Map<String, dynamic>> updateQuizAttempt({
    required int attemptId,
    required int puntosObtenidos,
    required double porcentaje,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/attempts/$attemptId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fecha_fin': DateTime.now().toIso8601String(),
          'puntos_obtenidos': puntosObtenidos,
          'porcentaje': porcentaje,
          'estado': 'Completado',
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'attempt': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update attempt',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user's best attempt for a quiz
  static Future<Map<String, dynamic>> getBestAttempt({
    required int userId,
    required int quizId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/quizzes/$quizId/best'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'attempt': data['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'attempt': null,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get best attempt',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== PROGRESS ====================

  /// Get user progress for all courses
  static Future<Map<String, dynamic>> getUserProgress(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/progress/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'progress': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get progress',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user stats
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stats/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'stats': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update progress after quiz
  static Future<Map<String, dynamic>> updateProgressAfterQuiz({
    required int userId,
    required int courseId,
    required int questionsAnswered,
    required int correctAnswers,
    required int pointsEarned,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/progress/user/$userId/course/$courseId/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'questionsAnswered': questionsAnswered,
          'correctAnswers': correctAnswers,
          'pointsEarned': pointsEarned,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'progress': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update progress',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== PLAN VALIDATION ====================

  /// Get user plan information with limits and usage
  static Future<Map<String, dynamic>> getUserPlanInfo(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/plan-validation/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'planInfo': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get plan info',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Validate if user can take a quiz (checks daily and monthly limits)
  static Future<Map<String, dynamic>> validateQuizLimits(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/plan-validation/user/$userId/validate-quiz'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'validation': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to validate quiz limits',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Validate if user can access a specific course
  static Future<Map<String, dynamic>> validateCourseAccess({
    required int userId,
    required int courseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/plan-validation/user/$userId/course/$courseId/access'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'access': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to validate course access',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update user plan
  static Future<Map<String, dynamic>> updateUserPlan({
    required int userId,
    required String newPlan,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/plan-validation/user/$userId/plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'plan': newPlan}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update plan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== PAYMENTS ====================

  /// Create payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int userId,
    required int planId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': userId,
          'plan_id': planId,
          'monto': amount,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'paymentIntentId': data['paymentIntentId'],
          'clientSecret': data['clientSecret'],
          'paymentId': data['paymentId'],
          'amount': data['amount'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to create payment intent',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Confirm payment
  static Future<Map<String, dynamic>> confirmPayment({
    required int paymentId,
    required String paymentIntentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/confirm/$paymentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_intent_id': paymentIntentId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'payment': data['payment'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to confirm payment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get payment by ID
  static Future<Map<String, dynamic>> getPaymentById(int paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/$paymentId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'payment': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get payment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user payments
  static Future<Map<String, dynamic>> getUserPayments(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'payments': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get payments',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user subscriptions
  static Future<Map<String, dynamic>> getUserSubscriptions(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/subscriptions/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'subscriptions': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get subscriptions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get active subscription
  static Future<Map<String, dynamic>> getActiveSubscription(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/subscriptions/user/$userId/active'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'subscription': data['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'subscription': null,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get active subscription',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Cancel subscription
  static Future<Map<String, dynamic>> cancelSubscription(int subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/subscriptions/$subscriptionId/cancel'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to cancel subscription',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== FEEDBACK ====================

  /// Create feedback
  static Future<Map<String, dynamic>> createFeedback({
    required int usuarioId,
    required int preguntaId,
    int? docenteId,
    required String tipoRespuesta,
    String? respuestaTexto,
    String? respuestaAudioUrl,
    double? puntuacion,
    String? comentarios,
    String? estado,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'pregunta_id': preguntaId,
          if (docenteId != null) 'docente_id': docenteId,
          'tipo_respuesta': tipoRespuesta,
          if (respuestaTexto != null) 'respuesta_texto': respuestaTexto,
          if (respuestaAudioUrl != null) 'respuesta_audio_url': respuestaAudioUrl,
          if (puntuacion != null) 'puntuacion': puntuacion,
          if (comentarios != null) 'comentarios': comentarios,
          if (estado != null) 'estado': estado,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'feedback': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to create feedback',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get feedback by ID
  static Future<Map<String, dynamic>> getFeedbackById(int feedbackId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/$feedbackId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'feedback': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get feedback',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get feedbacks by user
  static Future<Map<String, dynamic>> getFeedbacksByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'feedbacks': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get feedbacks',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get pending feedbacks
  static Future<Map<String, dynamic>> getPendingFeedbacks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/pending/all'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'feedbacks': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get pending feedbacks',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get feedbacks by teacher
  static Future<Map<String, dynamic>> getFeedbacksByTeacher(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/teacher/$teacherId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'feedbacks': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teacher feedbacks',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Grade feedback
  static Future<Map<String, dynamic>> gradeFeedback({
    required int feedbackId,
    required int teacherId,
    required double puntuacion,
    String? comentarios,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/feedback/$feedbackId/grade'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teacher_id': teacherId,
          'puntuacion': puntuacion,
          if (comentarios != null) 'comentarios': comentarios,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to grade feedback',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user feedback stats
  static Future<Map<String, dynamic>> getUserFeedbackStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/user/$userId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'stats': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get feedback stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== TEACHERS ====================

  /// Create teacher
  static Future<Map<String, dynamic>> createTeacher({
    required int usuarioId,
    required String especialidad,
    String? certificaciones,
    int? aniosExperiencia,
    bool? activo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/teachers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'especialidad': especialidad,
          if (certificaciones != null) 'certificaciones': certificaciones,
          if (aniosExperiencia != null) 'anios_experiencia': aniosExperiencia,
          if (activo != null) 'activo': activo,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'teacher': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to create teacher',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get teacher by ID
  static Future<Map<String, dynamic>> getTeacherById(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/$teacherId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'teacher': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teacher',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get teacher by user ID
  static Future<Map<String, dynamic>> getTeacherByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'teacher': data['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'teacher': null,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teacher',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get all teachers
  static Future<Map<String, dynamic>> getAllTeachers({bool? activo}) async {
    try {
      String url = '$baseUrl/api/teachers';
      if (activo != null) {
        url += '?activo=$activo';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'teachers': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teachers',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get teacher stats
  static Future<Map<String, dynamic>> getTeacherStats(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/$teacherId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'stats': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teacher stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update teacher
  static Future<Map<String, dynamic>> updateTeacher({
    required int teacherId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/teachers/$teacherId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to update teacher',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Deactivate teacher
  static Future<Map<String, dynamic>> deactivateTeacher(int teacherId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/teachers/$teacherId/deactivate'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to deactivate teacher',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Activate teacher
  static Future<Map<String, dynamic>> activateTeacher(int teacherId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/teachers/$teacherId/activate'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to activate teacher',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// Create notification
  static Future<Map<String, dynamic>> createNotification({
    required int idUsuario,
    required String titulo,
    required String mensaje,
    String tipo = 'Info',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': idUsuario,
          'titulo': titulo,
          'mensaje': mensaje,
          'tipo': tipo,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'notification': data['notification'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get all notifications for a user
  static Future<Map<String, dynamic>> getNotificationsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'notifications': data['notifications'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get notifications',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get unread notifications for a user
  static Future<Map<String, dynamic>> getUnreadNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/$userId/unread'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'notifications': data['notifications'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get unread notifications',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get notification count for a user
  static Future<Map<String, dynamic>> getNotificationCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/$userId/count'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'total': data['total'],
          'unread': data['unread'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get notification count',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Mark notification as read
  static Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'notification': data['notification'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark notification as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Mark all notifications as read for a user
  static Future<Map<String, dynamic>> markAllNotificationsAsRead(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$userId/read-all'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark all notifications as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete notification
  static Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$notificationId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
