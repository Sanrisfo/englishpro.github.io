/// Archivo de barril para la exportación centralizada de todos los modelos de la aplicación.
///
/// Importar este archivo permite acceder fácilmente a todas las clases de modelos
/// definidas en el directorio `app/lib/models`, simplificando las importaciones
/// en otras partes del código.
///
/// **Uso:**
/// ```dart
/// import 'package:englishpro/models/models.dart';
///
/// // Ahora puedes usar CourseModel, UserModel, QuestionModel, etc.
/// CourseModel myCourse = CourseModel(...);
/// ```
export 'user_model.dart';
export 'plan_model.dart';
export 'course_model.dart';
export 'skill_model.dart';
export 'activity_type_model.dart';
export 'question_model.dart';
export 'matching_models.dart';
export 'completion_models.dart';
export 'material_model.dart';
export 'progress_model.dart';
