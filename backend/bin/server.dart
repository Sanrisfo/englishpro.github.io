import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';
import 'package:englishpro_backend/routes/auth_routes.dart';
import 'package:englishpro_backend/routes/course_routes.dart';
import 'package:englishpro_backend/routes/skill_routes.dart';
import 'package:englishpro_backend/routes/material_routes.dart';
import 'package:englishpro_backend/routes/question_routes.dart';
import 'package:englishpro_backend/routes/quiz_routes.dart';
import 'package:englishpro_backend/routes/progress_routes.dart';
import 'package:englishpro_backend/routes/stats_routes.dart';
import 'package:englishpro_backend/routes/plan_validation_routes.dart';
import 'package:englishpro_backend/routes/payment_routes.dart';
import 'package:englishpro_backend/routes/feedback_routes.dart';
import 'package:englishpro_backend/routes/teacher_routes.dart';
import 'package:englishpro_backend/routes/notification_routes.dart';
import 'package:englishpro_backend/services/database_service.dart';
import 'package:englishpro_backend/services/question_service.dart';
import 'package:englishpro_backend/services/quiz_service.dart';
import 'package:englishpro_backend/services/progress_service.dart';
import 'package:englishpro_backend/services/plan_validation_service.dart';
import 'package:englishpro_backend/services/payment_service.dart';
import 'package:englishpro_backend/services/feedback_service.dart';
import 'package:englishpro_backend/services/teacher_service.dart';

void main() async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final log = Logger('Server');

  // Load environment variables
  final env = DotEnv()..load();

  // Connect to database
  final db = DatabaseService();
  await db.connect();

  // Get port from environment or use default
  final port = int.parse(env['PORT'] ?? '8080');

  // Create router
  final router = Router();

  // Health check endpoint
  router.get('/health', (Request request) {
    return Response.ok('{"status": "healthy", "timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'Content-Type': 'application/json'});
  });

  // API info endpoint
  router.get('/', (Request request) {
    return Response.ok('''
{
  "name": "EnglishPro API",
  "version": "1.0.0",
  "status": "running",
  "endpoints": {
    "health": "/health",
    "auth": "/api/auth",
    "users": "/api/users",
    "courses": "/api/courses",
    "skills": "/api/skills",
    "materials": "/api/materials",
    "questions": "/api/questions",
    "quizzes": "/api/quizzes",
    "progress": "/api/progress",
    "stats": "/api/stats",
    "plan-validation": "/api/plan-validation",
    "payments": "/api/payments",
    "feedback": "/api/feedback",
    "teachers": "/api/teachers",
    "notifications": "/api/notifications"
  }
}''', headers: {'Content-Type': 'application/json'});
  });

  // API routes
  final authRoutes = AuthRoutes();
  final courseRoutes = CourseRoutes();
  final skillRoutes = SkillRoutes();
  final materialRoutes = MaterialRoutes();
  final questionService = QuestionService(db.connection!);
  final questionRoutes = QuestionRoutes(questionService);
  final quizService = QuizService(db.connection!);
  final planValidationService = PlanValidationService(db);
  final quizRoutes = QuizRoutes(quizService, planValidationService: planValidationService);
  final progressService = ProgressService(db.connection!);
  final progressRoutes = ProgressRoutes(progressService);
  final statsRoutes = StatsRoutes(progressService);
  final planValidationRoutes = PlanValidationRoutes(planValidationService);
  final paymentService = PaymentService(db);
  final paymentRoutes = PaymentRoutes(paymentService);
  final feedbackService = FeedbackService(db.connection!);
  final feedbackRoutes = FeedbackRoutes(feedbackService);
  final teacherService = TeacherService(db.connection!);
  final teacherRoutes = TeacherRoutes(teacherService);
  final notificationRoutes = NotificationRoutes();

  router.mount('/api/auth', authRoutes.router.call);
  router.mount('/api/courses', courseRoutes.router.call);
  router.mount('/api/skills', skillRoutes.router.call);
  router.mount('/api/materials', materialRoutes.router.call);
  router.mount('/api/questions', questionRoutes.router.call);
  router.mount('/api/quizzes', quizRoutes.router.call);
  router.mount('/api/answers', questionRoutes.router.call);
  router.mount('/api/attempts', quizRoutes.router.call);
  router.mount('/api/users', quizRoutes.router.call);
  router.mount('/api/progress', progressRoutes.router.call);
  router.mount('/api/stats', statsRoutes.router.call);
  router.mount('/api/plan-validation', planValidationRoutes.router.call);
  router.mount('/api/payments', paymentRoutes.router.call);
  router.mount('/api/feedback', feedbackRoutes.router.call);
  router.mount('/api/teachers', teacherRoutes.router.call);
  router.mount('/api/notifications', notificationRoutes.router.call);

  // Middleware pipeline
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  // Start server
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  log.info('✅ EnglishPro Backend API running on http://${server.address.host}:${server.port}');
  log.info('📊 Database: PostgreSQL');
  log.info('🔥 Firebase: Configured');
  log.info('🚀 Environment: Development');
}
