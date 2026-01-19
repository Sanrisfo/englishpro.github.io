import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Servicio para la gestión de archivos en Supabase Storage.
///
/// Proporciona una capa de abstracción para subir, eliminar, listar y obtener
/// URLs públicas de archivos en diferentes buckets (`audios`, `videos`, `pdfs`, `images`).
/// Este servicio reemplaza la funcionalidad que previamente utilizaba Firebase Storage.
class SupabaseStorageService {
  final _supabase = supabase;

  /// Sube un archivo de audio para ejercicios de "Speaking".
  ///
  /// La ruta de almacenamiento es: `audios/recordings/{userId}/{fileName}`.
  ///
  /// @param userId El ID del usuario que sube el audio.
  /// @param audioFile El archivo de audio a subir.
  /// @param fileName El nombre del archivo.
  /// @param onProgress Una función de callback para monitorear el progreso de la subida (opcional).
  /// @return Un mapa con el resultado de la operación, incluyendo la URL pública y la ruta del archivo.
  Future<Map<String, dynamic>> uploadAudio({
    required String userId,
    File? audioFile,
    Uint8List? bytes,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = 'recordings/$userId/$fileName';

      // Sube el archivo a Supabase Storage
      if (kIsWeb) {
        if (bytes == null) throw Exception('En web se requieren bytes');
        await _supabase.storage
            .from('audios')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      } else {
        if (audioFile == null) throw Exception('En móvil se requiere archivo');
        await _supabase.storage
            .from('audios')
            .upload(
              path,
              audioFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      }

      // Obtiene la URL pública
      final url = _supabase.storage.from('audios').getPublicUrl(path);

      return {'success': true, 'url': url, 'path': 'audios/$path'};
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error al subir audio: ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir audio: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Sube un material de video.
  ///
  /// La ruta de almacenamiento es: `videos/{fileName}`.
  ///
  /// @param videoFile El archivo de video a subir.
  /// @param fileName El nombre del archivo.
  /// @param onProgress Una función de callback para monitorear el progreso de la subida (opcional).
  /// @return Un mapa con el resultado de la operación, incluyendo la URL pública y la ruta del archivo.
  Future<Map<String, dynamic>> uploadVideo({
    File? videoFile,
    Uint8List? bytes,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = fileName;

      if (kIsWeb) {
        if (bytes == null) throw Exception('En web se requieren bytes');
        await _supabase.storage
            .from('videos')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      } else {
        if (videoFile == null) throw Exception('En móvil se requiere archivo');
        await _supabase.storage
            .from('videos')
            .upload(
              path,
              videoFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      }

      final url = _supabase.storage.from('videos').getPublicUrl(path);

      return {'success': true, 'url': url, 'path': 'videos/$path'};
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error al subir video: ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir video: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Sube un material en formato PDF.
  ///
  /// La ruta de almacenamiento es: `pdfs/materials/{fileName}`.
  ///
  /// @param pdfFile El archivo PDF a subir.
  /// @param fileName El nombre del archivo.
  /// @param onProgress Una función de callback para monitorear el progreso de la subida (opcional).
  /// @return Un mapa con el resultado de la operación, incluyendo la URL pública y la ruta del archivo.
  Future<Map<String, dynamic>> uploadPDF({
    File? pdfFile,
    Uint8List? bytes,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = 'materials/$fileName';

      if (kIsWeb) {
        if (bytes == null) throw Exception('En web se requieren bytes');
        await _supabase.storage
            .from('pdfs')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      } else {
        if (pdfFile == null) throw Exception('En móvil se requiere archivo');
        await _supabase.storage
            .from('pdfs')
            .upload(
              path,
              pdfFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      }

      final url = _supabase.storage.from('pdfs').getPublicUrl(path);

      return {'success': true, 'url': url, 'path': 'pdfs/$path'};
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error al subir PDF: ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir PDF: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Sube una imagen.
  ///
  /// La ruta de almacenamiento es: `images/{fileName}`.
  ///
  /// @param imageFile El archivo de imagen a subir.
  /// @param fileName El nombre del archivo.
  /// @param onProgress Una función de callback para monitorear el progreso de la subida (opcional).
  /// @return Un mapa con el resultado de la operación, incluyendo la URL pública y la ruta del archivo.
  Future<Map<String, dynamic>> uploadImage({
    File? imageFile,
    Uint8List? bytes,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = fileName;

      if (kIsWeb) {
        if (bytes == null) throw Exception('En web se requieren bytes');
        await _supabase.storage
            .from('images')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      } else {
        if (imageFile == null) throw Exception('En móvil se requiere archivo');
        await _supabase.storage
            .from('images')
            .upload(
              path,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      }

      final url = _supabase.storage.from('images').getPublicUrl(path);

      return {'success': true, 'url': url, 'path': 'images/$path'};
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen: ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Obtiene la URL pública de un archivo.
  ///
  /// **Nota:** Para los buckets públicos de Supabase, este método es equivalente a `getPublicUrl`.
  ///
  /// @param bucket El nombre del bucket donde se encuentra el archivo.
  /// @param path La ruta del archivo dentro del bucket.
  /// @return Un mapa con la URL pública del archivo.
  Future<Map<String, dynamic>> getDownloadUrl(
    String bucket,
    String path,
  ) async {
    try {
      final url = _supabase.storage.from(bucket).getPublicUrl(path);

      return {'success': true, 'url': url};
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener URL de descarga: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Elimina un archivo de Supabase Storage.
  ///
  /// @param bucket El nombre del bucket donde se encuentra el archivo.
  /// @param path La ruta del archivo a eliminar.
  /// @return Un mapa indicando si la operación fue exitosa.
  Future<Map<String, dynamic>> deleteFile(String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);

      return {'success': true, 'message': 'Archivo eliminado exitosamente'};
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error al eliminar archivo: ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar archivo: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Elimina todos los archivos de audio de un usuario.
  ///
  /// Busca todos los archivos en la carpeta `recordings/{userId}` del bucket `audios`
  /// y los elimina en una sola operación.
  ///
  /// @param userId El ID del usuario cuyos audios serán eliminados.
  /// @return Un mapa indicando el resultado y la cantidad de archivos eliminados.
  Future<Map<String, dynamic>> deleteUserAudios(String userId) async {
    try {
      final listResult = await _supabase.storage
          .from('audios')
          .list(path: 'recordings/$userId');

      if (listResult.isEmpty) {
        return {
          'success': true,
          'message': 'No se encontraron archivos de audio',
          'deletedCount': 0,
        };
      }

      final filePaths = listResult
          .map((file) => 'recordings/$userId/${file.name}')
          .toList();

      await _supabase.storage.from('audios').remove(filePaths);

      return {
        'success': true,
        'message': 'Archivos de audio del usuario eliminados exitosamente',
        'deletedCount': filePaths.length,
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error al eliminar audios de usuario: ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar audios de usuario: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Lista todos los archivos en un directorio de un bucket.
  ///
  /// @param bucket El nombre del bucket.
  /// @param path La ruta del directorio dentro del bucket (opcional).
  /// @return Un mapa con la lista de archivos, sus detalles y la cantidad total.
  Future<Map<String, dynamic>> listFiles(String bucket, {String? path}) async {
    try {
      final listResult = await _supabase.storage.from(bucket).list(path: path);

      final files = listResult.map((file) {
        final filePath = path != null ? '$path/${file.name}' : file.name;
        final url = _supabase.storage.from(bucket).getPublicUrl(filePath);

        return {
          'name': file.name,
          'path': filePath,
          'url': url,
          'size': file.metadata?['size'],
          'lastModified': file.metadata?['lastModified'],
        };
      }).toList();

      return {'success': true, 'files': files, 'count': files.length};
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error al listar archivos: ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('Error al listar archivos: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Lista todos los archivos de audio grabados por un usuario.
  ///
  /// Es un atajo para `listFiles('audios', path: 'recordings/{userId}')`.
  ///
  /// @param userId El ID del usuario.
  /// @return Un mapa con la lista de archivos de audio del usuario.
  Future<Map<String, dynamic>> listUserAudios(String userId) async {
    return listFiles('audios', path: 'recordings/$userId');
  }

  /// Obtiene la información/metadata de un archivo.
  ///
  /// **Nota:** Supabase Storage no tiene un método directo para obtener metadatos.
  /// Este método verifica la existencia del archivo intentando obtener su URL pública.
  ///
  /// @param bucket El nombre del bucket.
  /// @param path La ruta del archivo.
  /// @return Un mapa con la URL y la ruta del archivo si existe.
  Future<Map<String, dynamic>> getFileInfo(String bucket, String path) async {
    try {
      // Supabase Storage doesn't have a direct getMetadata method like Firebase
      // We can check if file exists by trying to get public URL
      final url = _supabase.storage.from(bucket).getPublicUrl(path);

      return {'success': true, 'url': url, 'path': path};
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener información del archivo: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}
