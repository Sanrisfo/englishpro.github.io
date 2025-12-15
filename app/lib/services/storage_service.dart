import 'package:universal_io/io.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// [DEPRECATED] Servicio de almacenamiento legado para Firebase.
///
/// **Atención:** Esta clase está obsoleta y no debe ser utilizada en nuevo código.
/// La funcionalidad de almacenamiento ha sido migrada a `SupabaseStorageService`.
/// Se mantiene únicamente como referencia de la implementación anterior.
///
/// @nodoc
@deprecated
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// [DEPRECATED] Sube un archivo de audio a Firebase Storage.
  Future<Map<String, dynamic>> uploadAudio({
    required String userId,
    required File audioFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('audio/$userId/$fileName');
      final uploadTask = ref.putFile(audioFile);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'url': downloadUrl,
        'path': 'audio/$userId/$fileName',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading audio: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Sube un archivo de video a Firebase Storage.
  Future<Map<String, dynamic>> uploadVideo({
    required File videoFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('videos/$fileName');
      final uploadTask = ref.putFile(videoFile);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'url': downloadUrl,
        'path': 'videos/$fileName',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading video: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Sube un archivo PDF a Firebase Storage.
  Future<Map<String, dynamic>> uploadPDF({
    required File pdfFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('pdfs/$fileName');
      final uploadTask = ref.putFile(pdfFile);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'url': downloadUrl,
        'path': 'pdfs/$fileName',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading PDF: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Sube una imagen a Firebase Storage.
  Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('images/$fileName');
      final uploadTask = ref.putFile(imageFile);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'url': downloadUrl,
        'path': 'images/$fileName',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Obtiene la URL de descarga de un archivo.
  Future<Map<String, dynamic>> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();

      return {
        'success': true,
        'url': url,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download URL: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Elimina un archivo de Firebase Storage.
  Future<Map<String, dynamic>> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();

      return {
        'success': true,
        'message': 'File deleted successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Elimina los archivos de audio de un usuario.
  Future<Map<String, dynamic>> deleteUserAudios(String userId) async {
    try {
      final ref = _storage.ref().child('audio/$userId');
      final listResult = await ref.listAll();

      for (var item in listResult.items) {
        await item.delete();
      }

      return {
        'success': true,
        'message': 'User audio files deleted successfully',
        'deletedCount': listResult.items.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user audios: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Lista los archivos en un directorio.
  Future<Map<String, dynamic>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final listResult = await ref.listAll();

      final files = <Map<String, String>>[];
      for (var item in listResult.items) {
        final url = await item.getDownloadURL();
        files.add({
          'name': item.name,
          'path': item.fullPath,
          'url': url,
        });
      }

      return {
        'success': true,
        'files': files,
        'count': files.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error listing files: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// [DEPRECATED] Lista los archivos de audio de un usuario.
  Future<Map<String, dynamic>> listUserAudios(String userId) async {
    return listFiles('audio/$userId');
  }

  /// [DEPRECATED] Obtiene los metadatos de un archivo.
  Future<Map<String, dynamic>> getMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = await ref.getMetadata();

      return {
        'success': true,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated?.toIso8601String(),
        'updated': metadata.updated?.toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting metadata: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
