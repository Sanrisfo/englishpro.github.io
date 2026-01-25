import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/supabase_config.dart';
import '../models/user.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';
import '../models/activity_type_model.dart';
import '../models/material_model.dart';
import '../models/module_model.dart';
import '../models/question_model.dart';

/// Servicio de API para interactuar con el backend.
///
/// Proporciona una capa de comunicación para realizar operaciones a través de una API HTTP tradicional,
/// así como interacciones directas con Supabase para ciertas funcionalidades.
///
/// **Nota:** Esta clase es opcional y se mantiene para endpoints propios (ej. pagos, informes).
/// Muchos métodos interactúan directamente con Supabase para simplificar la lógica del cliente.
/// Todos los métodos retornan un `Future<Map<String, dynamic>>` que contiene:
/// - `success` (bool): `true` si la operación fue exitosa, `false` en caso contrario.
/// - `data` (opcional): Los datos solicitados.
/// - `message` (opcional): Un mensaje de error si la operación falló.
class ApiService {
  /// URL base para las llamadas a la API, obtenida desde las variables de entorno.
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:8080';

  // ==================== AUTENTICACIÓN ====================

  /// Registra un nuevo usuario en el sistema.
  ///
  /// @param nombreCompleto El nombre completo del usuario.
  /// @param email El correo electrónico del usuario.
  /// @param password La contraseña del usuario.
  /// @param profesion La profesión del usuario (opcional).
  /// @return Un mapa con el resultado de la operación, incluyendo el usuario y un token si es exitoso.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Inicia sesión de un usuario.
  ///
  /// @param email El correo electrónico del usuario.
  /// @param password La contraseña del usuario.
  /// @return Un mapa con el resultado de la operación, incluyendo el usuario y un token si es exitoso.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
          'token': data['token'] as String,
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene los datos del usuario actualmente autenticado.
  ///
  /// @param token El token de autenticación del usuario.
  /// @return Un mapa con el resultado de la operación, incluyendo los datos del usuario si es exitoso.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== CURSOS ====================

  /// Obtiene todos los cursos disponibles.
  ///
  /// @return Un mapa con una lista de todos los cursos.
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

        return {'success': true, 'courses': courses};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get courses',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene un curso por su ID.
  ///
  /// @param id El ID del curso a obtener.
  /// @return Un mapa con los datos del curso.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== HABILIDADES ====================

  /// Obtiene todas las habilidades.
  ///
  /// @return Un mapa con una lista de todas las habilidades.
  static Future<Map<String, dynamic>> getSkills() async {
    try {
      final response = await supabase
          .from('habilidades')
          .select('*')
          .order('orden', ascending: true);

      final skills = (response as List<dynamic>)
          .map((row) => SkillModel.fromJson(row as Map<String, dynamic>))
          .toList();

      return {'success': true, 'skills': skills};
    } catch (e) {
      return {'success': false, 'message': 'Error (Supabase getSkills): $e'};
    }
  }

  /// Obtiene las habilidades de un curso por su ID.
  ///
  /// @param courseId El ID del curso del que se quieren obtener las habilidades.
  /// @return Un mapa con una lista de las habilidades del curso.
  static Future<Map<String, dynamic>> getSkillsByCourse(int courseId) async {
    try {
      final response = await supabase
          .from('habilidades')
          .select('*')
          .eq('curso_id', courseId)
          .order('orden', ascending: true);

      final skills = (response as List<dynamic>)
          .map((row) => SkillModel.fromJson(row as Map<String, dynamic>))
          .toList();

      return {'success': true, 'skills': skills};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase getSkillsByCourse): $e',
      };
    }
  }

  /// Obtiene una habilidad por su ID.
  ///
  /// @param id El ID de la habilidad a obtener.
  /// @return Un mapa con los datos de la habilidad.
  static Future<Map<String, dynamic>> getSkillById(int id) async {
    try {
      final row = await supabase
          .from('habilidades')
          .select('*')
          .eq('id', id)
          .single();

      return {
        'success': true,
        'skill': SkillModel.fromJson(row as Map<String, dynamic>),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error (Supabase getSkillById): $e'};
    }
  }

  // ==================== TIPOS DE ACTIVIDAD ====================

  /// Lista los tipos de actividad para una habilidad.
  ///
  /// @param skillId El ID de la habilidad.
  /// @return Un mapa con una lista de los tipos de actividad para la habilidad.
  static Future<Map<String, dynamic>> getActivityTypesBySkill(
    int skillId,
  ) async {
    try {
      final response = await supabase
          .from('tipos_actividad')
          .select('*')
          .eq('id_habilidad', skillId)
          .eq('activo', true)
          .order('orden', ascending: true);

      final items = (response as List<dynamic>)
          .map((row) => ActivityTypeModel.fromJson(row as Map<String, dynamic>))
          .toList();

      return {'success': true, 'types': items};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase getActivityTypesBySkill): $e',
      };
    }
  }

  /// Crea un nuevo tipo de actividad.
  ///
  /// @param skillId El ID de la habilidad a la que pertenece el tipo de actividad.
  /// @param nombre El nombre del tipo de actividad.
  /// @param descripcion La descripción del tipo de actividad (opcional).
  /// @param orden El orden del tipo de actividad (por defecto 1).
  /// @param activo Si el tipo de actividad está activo (por defecto `true`).
  /// @param categoria La categoría para la UI ('mini_quiz' o 'practice_exam').
  /// @return Un mapa con los datos del tipo de actividad creado.
  static Future<Map<String, dynamic>> createActivityType({
    required int skillId,
    required String nombre,
    String? descripcion,
    int orden = 1,
    bool activo = true,
    String categoria = 'mini_quiz',
  }) async {
    try {
      final inserted = await supabase
          .from('tipos_actividad')
          .insert({
            'id_habilidad': skillId,
            'nombre': nombre,
            if (descripcion != null && descripcion.isNotEmpty)
              'descripcion': descripcion,
            'orden': orden,
            'activo': activo,
            'categoria': categoria,
          })
          .select()
          .single();
      return {
        'success': true,
        'type': ActivityTypeModel.fromJson(inserted as Map<String, dynamic>),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase createActivityType): $e',
      };
    }
  }

  /// Actualiza un tipo de actividad existente.
  ///
  /// @param id El ID del tipo de actividad a actualizar.
  /// @param nombre El nuevo nombre del tipo de actividad (opcional).
  /// @param descripcion La nueva descripción del tipo de actividad (opcional).
  /// @param orden El nuevo orden del tipo de actividad (opcional).
  /// @param activo El nuevo estado de activación del tipo de actividad (opcional).
  /// @param categoria La nueva categoría del tipo de actividad (opcional).
  /// @return Un mapa con los datos del tipo de actividad actualizado.
  static Future<Map<String, dynamic>> updateActivityType({
    required int id,
    String? nombre,
    String? descripcion,
    int? orden,
    bool? activo,
    String? categoria,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (nombre != null) payload['nombre'] = nombre;
      if (descripcion != null) payload['descripcion'] = descripcion;
      if (orden != null) payload['orden'] = orden;
      if (activo != null) payload['activo'] = activo;
      if (categoria != null) payload['categoria'] = categoria;

      final updated = await supabase
          .from('tipos_actividad')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return {
        'success': true,
        'type': ActivityTypeModel.fromJson(updated as Map<String, dynamic>),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase updateActivityType): $e',
      };
    }
  }

  /// Elimina un tipo de actividad.
  ///
  /// @param id El ID del tipo de actividad a eliminar.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> deleteActivityType(int id) async {
    try {
      await supabase.from('tipos_actividad').delete().eq('id', id);
      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase deleteActivityType): $e',
      };
    }
  }

  // ==================== REGLAS DE TIPO DE ACTIVIDAD (TIPOS DE PREGUNTA PERMITIDOS) ====================

  /// Obtiene los tipos de pregunta permitidos para un tipo de actividad.
  ///
  /// @param activityTypeId El ID del tipo de actividad.
  /// @return Una lista de los tipos de pregunta permitidos.
  static Future<List<String>> getAllowedQuestionTypes(
    int activityTypeId,
  ) async {
    try {
      final rows = await supabase
          .from('tipo_actividad_pregunta_permitida')
          .select('tipo_pregunta')
          .eq('id_tipo_actividad', activityTypeId);
      return List<Map<String, dynamic>>.from(
        rows as List,
      ).map((e) => (e['tipo_pregunta'] as String).toLowerCase()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Establece los tipos de pregunta permitidos para un tipo de actividad (reemplaza el conjunto actual).
  ///
  /// @param activityTypeId El ID del tipo de actividad.
  /// @param allowed La lista de tipos de pregunta permitidos.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> setAllowedQuestionTypes({
    required int activityTypeId,
    required List<String> allowed,
  }) async {
    try {
      // Estrategia de reemplazo: eliminar todos, luego insertar el nuevo conjunto
      await supabase
          .from('tipo_actividad_pregunta_permitida')
          .delete()
          .eq('id_tipo_actividad', activityTypeId);

      if (allowed.isNotEmpty) {
        final payload = allowed
            .map(
              (t) => {'id_tipo_actividad': activityTypeId, 'tipo_pregunta': t},
            )
            .toList();
        await supabase
            .from('tipo_actividad_pregunta_permitida')
            .insert(payload);
      }
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Error setAllowedQuestionTypes: $e'};
    }
  }

  // ==================== MATERIALES ====================

  /// Obtiene todos los materiales.
  ///
  /// @return Un mapa con una lista de todos los materiales.
  static Future<Map<String, dynamic>> getMaterials() async {
    try {
      final response = await supabase
          .from('materiales_estudio')
          .select('*')
          .order('orden', ascending: true);

      final materials = (response as List<dynamic>)
          .map((row) => MaterialModel.fromJson(row as Map<String, dynamic>))
          .toList();

      return {'success': true, 'materials': materials};
    } catch (e) {
      return {'success': false, 'message': 'Error (Supabase getMaterials): $e'};
    }
  }

  /// Obtiene los materiales de una habilidad por su ID.
  ///
  /// @param skillId El ID de la habilidad de la que se quieren obtener los materiales.
  /// @return Un mapa con una lista de los materiales de la habilidad.
  static Future<Map<String, dynamic>> getMaterialsBySkill(int skillId) async {
    try {
      final response = await supabase
          .from('materiales_estudio')
          .select('*')
          .eq('id_habilidad', skillId)
          .order('orden', ascending: true);

      final materials = (response as List<dynamic>)
          .map((row) => MaterialModel.fromJson(row as Map<String, dynamic>))
          .toList();

      return {'success': true, 'materials': materials};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase getMaterialsBySkill): $e',
      };
    }
  }

  /// Obtiene un material por su ID.
  ///
  /// @param id El ID del material a obtener.
  /// @return Un mapa con los datos del material.
  static Future<Map<String, dynamic>> getMaterialById(int id) async {
    try {
      final row = await supabase
          .from('materiales_estudio')
          .select('*')
          .eq('id_material', id)
          .single();
      return {
        'success': true,
        'material': MaterialModel.fromJson(row as Map<String, dynamic>),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase getMaterialById): $e',
      };
    }
  }

  /// Crea un nuevo material (para docentes).
  ///
  /// @param habilidadId El ID de la habilidad a la que pertenece el material.
  /// @param titulo El título del material.
  /// @param tipoMaterial El tipo de material (ej. 'pdf', 'video').
  /// @param descripcion La descripción del material (opcional).
  /// @param archivoUrl La URL del archivo del material (opcional).
  /// @param contenidoTexto El contenido de texto del material (opcional).
  /// @param cuestionarioId El ID del cuestionario asociado al material (opcional).
  /// @param esPremium Si el material es premium (por defecto `false`).
  /// @param duracionMinutos La duración en minutos del material (opcional).
  /// @param orden El orden del material (por defecto 1).
  /// @param nivelAcceso El nivel de acceso del material (opcional).
  /// @param creadoPor El ID del docente que crea el material (opcional).
  /// @return Un mapa con los datos del material creado.
  static Future<Map<String, dynamic>> createMaterial({
    required int habilidadId,
    required String titulo,
    required String tipoMaterial,
    String? descripcion,
    String? archivoUrl,
    String? contenidoTexto,
    int? cuestionarioId,
    bool esPremium = false,
    int? duracionMinutos,
    int orden = 1,
    String? nivelAcceso, // opcional
    int? creadoPor, // opcional, puede ser id_docente en tu esquema
  }) async {
    try {
      // Mapear tipo a valores aceptados por CHECK (PDF, Video, Audio, Texto, Imagen)
      String tipoDb;
      switch (tipoMaterial.toLowerCase()) {
        case 'pdf':
          tipoDb = 'PDF';
          break;
        case 'video':
          tipoDb = 'Video';
          break;
        case 'audio':
          tipoDb = 'Audio';
          break;
        case 'text':
        case 'texto':
          tipoDb = 'Texto';
          break;
        case 'image':
        case 'imagen':
          tipoDb = 'Imagen';
          break;
        default:
          tipoDb = 'PDF';
      }

      final payload = <String, dynamic>{
        'id_habilidad': habilidadId,
        'titulo': titulo,
        'tipo_material': tipoDb,
        if (archivoUrl != null && archivoUrl.isNotEmpty)
          'url_recurso': archivoUrl,
        if (contenidoTexto != null && contenidoTexto.isNotEmpty)
          'contenido_texto': contenidoTexto,
        if (cuestionarioId != null) 'id_cuestionario': cuestionarioId,
        if (duracionMinutos != null) 'duracion_minutos': duracionMinutos,
        'orden': orden,
        if (nivelAcceso != null) 'nivel_acceso': nivelAcceso,
        if (creadoPor != null) 'creado_por': creadoPor,
      };

      final inserted = await supabase
          .from('materiales_estudio')
          .insert(payload)
          .select()
          .single();

      return {
        'success': true,
        'material': inserted,
        'message': 'Material creado en Supabase',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase createMaterial): $e',
      };
    }
  }

  /// Actualiza un material existente (para docentes).
  ///
  /// @param materialId El ID del material a actualizar.
  /// @param updates Un mapa con los campos a actualizar.
  /// @return Un mapa con los datos del material actualizado.
  static Future<Map<String, dynamic>> updateMaterial({
    required int materialId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final updated = await supabase
          .from('materiales_estudio')
          .update(updates)
          .eq('id_material', materialId)
          .select()
          .single();
      return {
        'success': true,
        'material': updated,
        'message': 'Material actualizado en Supabase',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase updateMaterial): $e',
      };
    }
  }

  /// Elimina un material (para docentes).
  ///
  /// @param materialId El ID del material a eliminar.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> deleteMaterial(int materialId) async {
    try {
      await supabase
          .from('materiales_estudio')
          .delete()
          .eq('id_material', materialId);
      return {'success': true, 'message': 'Material eliminado en Supabase'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase deleteMaterial): $e',
      };
    }
  }

  // ==================== MÓDULOS ====================

  /// Obtiene los módulos de una habilidad.
  ///
  /// @param skillId El ID de la habilidad de la que se quieren obtener los módulos.
  /// @return Un mapa con una lista de los módulos de la habilidad.
  static Future<Map<String, dynamic>> getModulesBySkill(int skillId) async {
    try {
      final response = await supabase
          .from('modulos')
          .select('*')
          .eq('id_habilidad', skillId)
          .order('orden', ascending: true);

      final modules = (response as List<dynamic>)
          .map((row) => ModuleModel.fromJson(row as Map<String, dynamic>))
          .toList();

      return {'success': true, 'modules': modules};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase getModulesBySkill): $e',
      };
    }
  }

  /// Crea un nuevo módulo.
  ///
  /// @param habilidadId El ID de la habilidad a la que pertenece el módulo.
  /// @param nombre El nombre del módulo.
  /// @param descripcion La descripción del módulo (opcional).
  /// @param orden El orden del módulo (por defecto 1).
  /// @param activo Si el módulo está activo (por defecto `true`).
  /// @return Un mapa con los datos del módulo creado.
  static Future<Map<String, dynamic>> createModule({
    required int habilidadId,
    required String nombre,
    String? descripcion,
    int orden = 1,
    bool activo = true,
  }) async {
    try {
      final inserted = await supabase
          .from('modulos')
          .insert({
            'id_habilidad': habilidadId,
            'nombre_modulo': nombre,
            if (descripcion != null && descripcion.isNotEmpty)
              'descripcion': descripcion,
            'orden': orden,
            'activo': activo,
          })
          .select()
          .single();
      return {'success': true, 'module': inserted};
    } catch (e) {
      return {'success': false, 'message': 'Error (Supabase createModule): $e'};
    }
  }

  /// Actualiza una actividad para asignarle un módulo.
  ///
  /// @param cuestionarioId El ID del cuestionario (actividad) a actualizar.
  /// @param moduloId El ID del módulo a asignar.
  /// @return Un mapa con los datos del cuestionario actualizado.
  static Future<Map<String, dynamic>> updateActivityModule({
    required int cuestionarioId,
    int? moduloId,
  }) async {
    try {
      final updated = await supabase
          .from('cuestionarios')
          .update({'id_modulo': moduloId})
          .eq('id_cuestionario', cuestionarioId)
          .select()
          .single();
      return {'success': true, 'quiz': updated};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (Supabase updateActivityModule): $e',
      };
    }
  }

  // ==================== PREGUNTAS ====================

  /// Obtiene las preguntas de una habilidad por su ID.
  ///
  /// @param skillId El ID de la habilidad de la que se quieren obtener las preguntas.
  /// @return Un mapa con una lista de las preguntas de la habilidad.
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

        return {'success': true, 'questions': questions};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get questions',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene una pregunta por su ID, incluyendo las opciones de respuesta.
  ///
  /// @param id El ID de la pregunta a obtener.
  /// @return Un mapa con los datos de la pregunta.
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
          'question': QuestionModel.fromJson(
            data['data'] as Map<String, dynamic>,
          ),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get question',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Envía la respuesta de un usuario a una pregunta (inserción directa en Supabase).
  ///
  /// @param userId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param opcionSeleccionadaId El ID de la opción seleccionada (opcional).
  /// @param respuestaTexto El texto de la respuesta (opcional).
  /// @param audioUrl La URL del audio de la respuesta (opcional).
  /// @param quizId El ID del cuestionario al que pertenece la pregunta (opcional).
  /// @return Un mapa con los datos de la respuesta insertada.
  static Future<Map<String, dynamic>> submitAnswer({
    required int userId,
    required int preguntaId,
    int? opcionSeleccionadaId,
    String? respuestaTexto,
    String? audioUrl,
    int? quizId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'id_usuario': userId,
        'id_pregunta': preguntaId,
        if (opcionSeleccionadaId != null)
          'id_opcion_seleccionada': opcionSeleccionadaId,
        if (respuestaTexto != null) 'respuesta_texto': respuestaTexto,
        if (audioUrl != null) 'respuesta_audio_url': audioUrl,
        if (quizId != null) 'id_cuestionario': quizId,
      };

      final inserted = await supabase
          .from('respuestas_usuario')
          .insert(payload)
          .select()
          .single();

      return {'success': true, 'answer': inserted};
    } catch (e) {
      return {'success': false, 'message': 'Error (Supabase submitAnswer): $e'};
    }
  }

  /// Crea una fila base de respuesta y devuelve su ID.
  ///
  /// @param userId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param quizId El ID del cuestionario (opcional).
  /// @param extra Datos adicionales a insertar (opcional).
  /// @return El ID de la respuesta creada.
  static Future<int> _createRespuestaBase({
    required int userId,
    required int preguntaId,
    int? quizId,
    Map<String, dynamic>? extra,
  }) async {
    final base = <String, dynamic>{
      'id_usuario': userId,
      'id_pregunta': preguntaId,
      if (quizId != null) 'id_cuestionario': quizId,
      ...?extra,
    };
    final row = await supabase
        .from('respuestas_usuario')
        .insert(base)
        .select('id_respuesta')
        .single();
    return (row['id_respuesta'] as num).toInt();
  }

  /// Envía la respuesta a una pregunta de selección múltiple (multi-selección).
  ///
  /// @param userId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param optionIds La lista de IDs de las opciones seleccionadas.
  /// @param quizId El ID del cuestionario (opcional).
  /// @return Un mapa indicando si la operación fue exitosa y el ID de la respuesta.
  static Future<Map<String, dynamic>> submitAnswerMultipleChoice({
    required int userId,
    required int preguntaId,
    required List<int> optionIds,
    int? quizId,
  }) async {
    try {
      final rid = await _createRespuestaBase(
        userId: userId,
        preguntaId: preguntaId,
        quizId: quizId,
      );
      if (optionIds.isNotEmpty) {
        final list = optionIds
            .map((oid) => {'id_respuesta': rid, 'id_opcion': oid})
            .toList();
        await supabase.from('respuestas_usuario_opciones').insert(list);
      }
      return {'success': true, 'id_respuesta': rid};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (submitAnswerMultipleChoice): $e',
      };
    }
  }

  /// Envía la respuesta a una pregunta de emparejamiento (matching).
  ///
  /// @param userId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param statementToAnswer Un mapa que relaciona el ID de cada enunciado con el ID de la respuesta seleccionada.
  /// @param quizId El ID del cuestionario (opcional).
  /// @return Un mapa indicando si la operación fue exitosa y el ID de la respuesta.
  static Future<Map<String, dynamic>> submitAnswerMatching({
    required int userId,
    required int preguntaId,
    required Map<int, int> statementToAnswer, // statementId -> answerId
    int? quizId,
  }) async {
    try {
      final rid = await _createRespuestaBase(
        userId: userId,
        preguntaId: preguntaId,
        quizId: quizId,
      );
      if (statementToAnswer.isNotEmpty) {
        final list = statementToAnswer.entries
            .map(
              (e) => {
                'id_respuesta': rid,
                'statement_id': e.key,
                'selected_answer_id': e.value,
              },
            )
            .toList();
        await supabase.from('respuestas_usuario_matching').insert(list);
      }
      return {'success': true, 'id_respuesta': rid};
    } catch (e) {
      return {'success': false, 'message': 'Error (submitAnswerMatching): $e'};
    }
  }

  /// Envía la respuesta a una pregunta de completar (completion).
  ///
  /// @param userId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param gapToText Un mapa que relaciona el ID de cada espacio con el texto introducido por el usuario.
  /// @param quizId El ID del cuestionario (opcional).
  /// @return Un mapa indicando si la operación fue exitosa y el ID de la respuesta.
  static Future<Map<String, dynamic>> submitAnswerCompletion({
    required int userId,
    required int preguntaId,
    required Map<int, String> gapToText, // gapId -> value
    int? quizId,
  }) async {
    try {
      final rid = await _createRespuestaBase(
        userId: userId,
        preguntaId: preguntaId,
        quizId: quizId,
      );
      if (gapToText.isNotEmpty) {
        final list = gapToText.entries
            .map(
              (e) => {
                'id_respuesta': rid,
                'gap_id': e.key,
                'text_value': e.value,
              },
            )
            .toList();
        await supabase.from('respuestas_usuario_completion').insert(list);
      }
      return {'success': true, 'id_respuesta': rid};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (submitAnswerCompletion): $e',
      };
    }
  }

  /// Envía la respuesta a una pregunta de escribir texto.
  ///
  /// @param userId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param text El texto escrito por el usuario.
  /// @param quizId El ID del cuestionario (opcional).
  /// @return Un mapa indicando si la operación fue exitosa y el ID de la respuesta.
  static Future<Map<String, dynamic>> submitAnswerWriteText({
    required int userId,
    required int preguntaId,
    required String text,
    int? quizId,
  }) async {
    try {
      // Para planes Pro/Premium (>=3), encolamos a revisión manual
      bool requiresReview = false;
      try {
        final u = await supabase
            .from('usuarios')
            .select('id_plan')
            .eq('id_usuario', userId)
            .single();
        final planId = (u['id_plan'] as num?)?.toInt() ?? 1;
        if (planId >= 3) requiresReview = true;
      } catch (_) {}

      final extra = <String, dynamic>{
        'texto_ensayo': text,
        if (requiresReview) 'requiere_revision': true,
      };

      final rid = await _createRespuestaBase(
        userId: userId,
        preguntaId: preguntaId,
        quizId: quizId,
        extra: extra,
      );
      return {'success': true, 'id_respuesta': rid};
    } catch (e) {
      return {'success': false, 'message': 'Error (submitAnswerWriteText): $e'};
    }
  }

  /// Envía la respuesta a una pregunta de grabar audio.
  ///
  /// @param userId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param audioUrl La URL del audio grabado por el usuario.
  /// @param quizId El ID del cuestionario (opcional).
  /// @return Un mapa indicando si la operación fue exitosa y el ID de la respuesta.
  static Future<Map<String, dynamic>> submitAnswerRecordAudio({
    required int userId,
    required int preguntaId,
    required String audioUrl,
    int? quizId,
  }) async {
    try {
      // Determinar si requiere revisión manual según plan
      bool requiresReview = false;
      try {
        final u = await supabase
            .from('usuarios')
            .select('id_plan')
            .eq('id_usuario', userId)
            .single();
        final planId = (u['id_plan'] as num?)?.toInt() ?? 1;
        if (planId >= 3) requiresReview = true;
      } catch (_) {}

      final extra = <String, dynamic>{
        'url_grabacion': audioUrl,
        if (requiresReview) 'requiere_revision': true,
      };

      final rid = await _createRespuestaBase(
        userId: userId,
        preguntaId: preguntaId,
        quizId: quizId,
        extra: extra,
      );
      return {'success': true, 'id_respuesta': rid};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error (submitAnswerRecordAudio): $e',
      };
    }
  }

  // ==================== CUESTIONARIOS ====================

  /// Obtiene los cuestionarios de una habilidad por su ID.
  ///
  /// @param skillId El ID de la habilidad de la que se quieren obtener los cuestionarios.
  /// @return Un mapa con una lista de los cuestionarios de la habilidad.
  static Future<Map<String, dynamic>> getQuizzesBySkill(int skillId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/quizzes/skill/$skillId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final quizzesData = data['data'] as List<dynamic>;

        return {'success': true, 'quizzes': quizzesData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get quizzes',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene un cuestionario por su ID, incluyendo las preguntas.
  ///
  /// @param id El ID del cuestionario a obtener.
  /// @return Un mapa con los datos del cuestionario y una lista de sus preguntas.
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
              .map(
                (json) => QuestionModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }

        return {'success': true, 'quiz': quizData, 'questions': questions};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get quiz',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Crea un intento de cuestionario.
  ///
  /// @param userId El ID del usuario que inicia el intento.
  /// @param quizId El ID del cuestionario.
  /// @return Un mapa con los datos del intento creado.
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
        return {'success': true, 'attempt': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create attempt',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Actualiza un intento de cuestionario (lo completa).
  ///
  /// @param attemptId El ID del intento a actualizar.
  /// @param puntosObtenidos Los puntos obtenidos en el intento.
  /// @param porcentaje El porcentaje de aciertos en el intento.
  /// @return Un mapa con los datos del intento actualizado.
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
        return {'success': true, 'attempt': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update attempt',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene el mejor intento de un usuario para un cuestionario.
  ///
  /// @param userId El ID del usuario.
  /// @param quizId El ID del cuestionario.
  /// @return Un mapa con los datos del mejor intento.
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
        return {'success': true, 'attempt': data['data']};
      } else if (response.statusCode == 404) {
        return {'success': true, 'attempt': null};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get best attempt',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== PROGRESO ====================

  /// Obtiene el progreso de un usuario en todos los cursos.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con el progreso del usuario.
  static Future<Map<String, dynamic>> getUserProgress(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/progress/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'progress': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get progress',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las estadísticas de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con las estadísticas del usuario.
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stats/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'stats': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get stats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Actualiza el progreso después de un cuestionario.
  ///
  /// @param userId El ID del usuario.
  /// @param courseId El ID del curso.
  /// @param questionsAnswered El número de preguntas respondidas.
  /// @param correctAnswers El número de respuestas correctas.
  /// @param pointsEarned Los puntos ganados.
  /// @return Un mapa con el progreso actualizado.
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
        return {'success': true, 'progress': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update progress',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== VALIDACIÓN DE PLAN ====================

  /// Obtiene la información del plan de un usuario, incluyendo límites y uso.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con la información del plan del usuario.
  static Future<Map<String, dynamic>> getUserPlanInfo(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/plan-validation/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'planInfo': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get plan info',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Valida si un usuario puede tomar un cuestionario (verifica límites diarios y mensuales).
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con el resultado de la validación.
  static Future<Map<String, dynamic>> validateQuizLimits(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/plan-validation/user/$userId/validate-quiz'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'validation': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to validate quiz limits',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Valida si un usuario puede acceder a un curso específico.
  ///
  /// @param userId El ID del usuario.
  /// @param courseId El ID del curso.
  /// @return Un mapa con el resultado de la validación.
  static Future<Map<String, dynamic>> validateCourseAccess({
    required int userId,
    required int courseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/plan-validation/user/$userId/course/$courseId/access',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'access': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to validate course access',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Actualiza el plan de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @param newPlan El nuevo plan a asignar.
  /// @return Un mapa indicando si la operación fue exitosa.
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
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update plan',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== PAGOS ====================

  /// Crea una intención de pago.
  ///
  /// @param userId El ID del usuario.
  /// @param planId El ID del plan.
  /// @param amount El monto del pago.
  /// @return Un mapa con los datos de la intención de pago.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Confirma un pago.
  ///
  /// @param paymentId El ID del pago.
  /// @param paymentIntentId El ID de la intención de pago.
  /// @return Un mapa con los datos del pago confirmado.
  static Future<Map<String, dynamic>> confirmPayment({
    required int paymentId,
    required String paymentIntentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/confirm/$paymentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'payment_intent_id': paymentIntentId}),
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene un pago por su ID.
  ///
  /// @param paymentId El ID del pago a obtener.
  /// @return Un mapa con los datos del pago.
  static Future<Map<String, dynamic>> getPaymentById(int paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/$paymentId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'payment': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get payment',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene los pagos de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con una lista de los pagos del usuario.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las suscripciones de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con una lista de las suscripciones del usuario.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene la suscripción activa de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con la suscripción activa del usuario.
  static Future<Map<String, dynamic>> getActiveSubscription(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/subscriptions/user/$userId/active'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'subscription': data['data']};
      } else if (response.statusCode == 404) {
        return {'success': true, 'subscription': null};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get active subscription',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Cancela una suscripción.
  ///
  /// @param subscriptionId El ID de la suscripción a cancelar.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> cancelSubscription(
    int subscriptionId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/subscriptions/$subscriptionId/cancel'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to cancel subscription',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== RETROALIMENTACIÓN ====================

  /// Crea una nueva retroalimentación.
  ///
  /// @param usuarioId El ID del usuario.
  /// @param preguntaId El ID de la pregunta.
  /// @param docenteId El ID del docente (opcional).
  /// @param tipoRespuesta El tipo de respuesta.
  /// @param respuestaTexto El texto de la respuesta (opcional).
  /// @param respuestaAudioUrl La URL del audio de la respuesta (opcional).
  /// @param puntuacion La puntuación de la retroalimentación (opcional).
  /// @param comentarios Los comentarios de la retroalimentación (opcional).
  /// @param estado El estado de la retroalimentación (opcional).
  /// @return Un mapa con los datos de la retroalimentación creada.
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
          if (respuestaAudioUrl != null)
            'respuesta_audio_url': respuestaAudioUrl,
          if (puntuacion != null) 'puntuacion': puntuacion,
          if (comentarios != null) 'comentarios': comentarios,
          if (estado != null) 'estado': estado,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'feedback': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to create feedback',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene una retroalimentación por su ID.
  ///
  /// @param feedbackId El ID de la retroalimentación.
  /// @return Un mapa con los datos de la retroalimentación.
  static Future<Map<String, dynamic>> getFeedbackById(int feedbackId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/$feedbackId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'feedback': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get feedback',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las retroalimentaciones de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con una lista de las retroalimentaciones del usuario.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las retroalimentaciones pendientes.
  ///
  /// @return Un mapa con una lista de las retroalimentaciones pendientes.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las retroalimentaciones de un docente.
  ///
  /// @param teacherId El ID del docente.
  /// @return Un mapa con una lista de las retroalimentaciones del docente.
  static Future<Map<String, dynamic>> getFeedbacksByTeacher(
    int teacherId,
  ) async {
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Califica una retroalimentación.
  ///
  /// @param feedbackId El ID de la retroalimentación.
  /// @param teacherId El ID del docente.
  /// @param puntuacion La puntuación asignada.
  /// @param comentarios Los comentarios de la retroalimentación (opcional).
  /// @return Un mapa indicando si la operación fue exitosa.
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
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to grade feedback',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las estadísticas de retroalimentación de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con las estadísticas de retroalimentación.
  static Future<Map<String, dynamic>> getUserFeedbackStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/user/$userId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'stats': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get feedback stats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== DOCENTES ====================

  /// Crea un nuevo docente.
  ///
  /// @param usuarioId El ID del usuario.
  /// @param especialidad La especialidad del docente.
  /// @param certificaciones Las certificaciones del docente (opcional).
  /// @param aniosExperiencia Los años de experiencia del docente (opcional).
  /// @param activo Si el docente está activo (opcional).
  /// @return Un mapa con los datos del docente creado.
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
        return {'success': true, 'teacher': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to create teacher',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene un docente por su ID.
  ///
  /// @param teacherId El ID del docente a obtener.
  /// @return Un mapa con los datos del docente.
  static Future<Map<String, dynamic>> getTeacherById(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/$teacherId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'teacher': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teacher',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene un docente por el ID de usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con los datos del docente.
  static Future<Map<String, dynamic>> getTeacherByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'teacher': data['data']};
      } else if (response.statusCode == 404) {
        return {'success': true, 'teacher': null};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teacher',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene todos los docentes.
  ///
  /// @param activo Si se deben obtener solo los docentes activos (opcional).
  /// @return Un mapa con una lista de todos los docentes.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las estadísticas de un docente.
  ///
  /// @param teacherId El ID del docente.
  /// @return Un mapa con las estadísticas del docente.
  static Future<Map<String, dynamic>> getTeacherStats(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/$teacherId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'stats': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get teacher stats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Actualiza un docente.
  ///
  /// @param teacherId El ID del docente a actualizar.
  /// @param updates Un mapa con los campos a actualizar.
  /// @return Un mapa indicando si la operación fue exitosa.
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
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to update teacher',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Desactiva un docente.
  ///
  /// @param teacherId El ID del docente a desactivar.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> deactivateTeacher(int teacherId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/teachers/$teacherId/deactivate'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to deactivate teacher',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Activa un docente.
  ///
  /// @param teacherId El ID del docente a activar.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> activateTeacher(int teacherId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/teachers/$teacherId/activate'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to activate teacher',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== NOTIFICACIONES ====================

  /// Crea una nueva notificación.
  ///
  /// @param idUsuario El ID del usuario al que se le enviará la notificación.
  /// @param titulo El título de la notificación.
  /// @param mensaje El mensaje de la notificación.
  /// @param tipo El tipo de notificación (por defecto 'Info').
  /// @return Un mapa con los datos de la notificación creada.
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
        return {'success': true, 'notification': data['notification']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create notification',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene todas las notificaciones de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con una lista de las notificaciones del usuario.
  static Future<Map<String, dynamic>> getNotificationsByUserId(
    int userId,
  ) async {
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene las notificaciones no leídas de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con una lista de las notificaciones no leídas del usuario.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Obtiene el conteo de notificaciones de un usuario.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con el conteo total y no leído de notificaciones.
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Marca una notificación como leída.
  ///
  /// @param notificationId El ID de la notificación a marcar como leída.
  /// @return Un mapa con los datos de la notificación actualizada.
  static Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'notification': data['notification']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark notification as read',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Marca todas las notificaciones de un usuario como leídas.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
    int userId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$userId/read-all'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Failed to mark all notifications as read',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Elimina una notificación.
  ///
  /// @param notificationId El ID de la notificación a eliminar.
  /// @return Un mapa indicando si la operación fue exitosa.
  static Future<Map<String, dynamic>> deleteNotification(
    int notificationId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$notificationId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete notification',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
