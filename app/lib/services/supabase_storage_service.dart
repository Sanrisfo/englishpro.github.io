import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Supabase Storage Service for EnglishPro
///
/// Handles file uploads and downloads using Supabase Storage.
/// Replaces Firebase Storage functionality.
class SupabaseStorageService {
  final _supabase = supabase;

  

  /// Upload audio file for Speaking exercises
  /// Path: audios/recordings/{userId}/{fileName}
  Future<Map<String, dynamic>> uploadAudio({
    required String userId,
    required File audioFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = 'recordings/$userId/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage.from('audios').upload(
            path,
            audioFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final url = _supabase.storage.from('audios').getPublicUrl(path);

      return {
        'success': true,
        'url': url,
        'path': 'audios/$path',
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error uploading audio: ${e.message}');
      }
      return {
        'success': false,
        'error': e.message,
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

  /// Upload video material
  /// Path: videos/{fileName}
  Future<Map<String, dynamic>> uploadVideo({
    required File videoFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = fileName;

      await _supabase.storage.from('videos').upload(
            path,
            videoFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _supabase.storage.from('videos').getPublicUrl(path);

      return {
        'success': true,
        'url': url,
        'path': 'videos/$path',
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error uploading video: ${e.message}');
      }
      return {
        'success': false,
        'error': e.message,
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

  /// Upload PDF material
  /// Path: pdfs/materials/{fileName}
  Future<Map<String, dynamic>> uploadPDF({
    required File pdfFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = 'materials/$fileName';

      await _supabase.storage.from('pdfs').upload(
            path,
            pdfFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _supabase.storage.from('pdfs').getPublicUrl(path);

      return {
        'success': true,
        'url': url,
        'path': 'pdfs/$path',
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error uploading PDF: ${e.message}');
      }
      return {
        'success': false,
        'error': e.message,
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

  /// Upload image
  /// Path: images/{fileName}
  Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final path = fileName;

      await _supabase.storage.from('images').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _supabase.storage.from('images').getPublicUrl(path);

      return {
        'success': true,
        'url': url,
        'path': 'images/$path',
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error uploading image: ${e.message}');
      }
      return {
        'success': false,
        'error': e.message,
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

  

  /// Get download URL for a file
  /// Note: For Supabase public buckets, files are already accessible via getPublicUrl
  Future<Map<String, dynamic>> getDownloadUrl(String bucket, String path) async {
    try {
      final url = _supabase.storage.from(bucket).getPublicUrl(path);

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

  

  /// Delete a file from Supabase Storage
  Future<Map<String, dynamic>> deleteFile(String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);

      return {
        'success': true,
        'message': 'File deleted successfully',
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error deleting file: ${e.message}');
      }
      return {
        'success': false,
        'error': e.message,
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

  /// Delete user's audio files
  Future<Map<String, dynamic>> deleteUserAudios(String userId) async {
    try {
      final listResult = await _supabase.storage
          .from('audios')
          .list(path: 'recordings/$userId');

      if (listResult.isEmpty) {
        return {
          'success': true,
          'message': 'No audio files found',
          'deletedCount': 0,
        };
      }

      final filePaths = listResult
          .map((file) => 'recordings/$userId/${file.name}')
          .toList();

      await _supabase.storage.from('audios').remove(filePaths);

      return {
        'success': true,
        'message': 'User audio files deleted successfully',
        'deletedCount': filePaths.length,
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error deleting user audios: ${e.message}');
      }
      return {
        'success': false,
        'error': e.message,
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

  

  /// List all files in a bucket directory
  Future<Map<String, dynamic>> listFiles(String bucket, {String? path}) async {
    try {
      final listResult = await _supabase.storage.from(bucket).list(
            path: path,
          );

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

      return {
        'success': true,
        'files': files,
        'count': files.length,
      };
    } on StorageException catch (e) {
      if (kDebugMode) {
        print('Error listing files: ${e.message}');
      }
      return {
        'success': false,
        'error': e.message,
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

  /// List user's audio files
  Future<Map<String, dynamic>> listUserAudios(String userId) async {
    return listFiles('audios', path: 'recordings/$userId');
  }

  

  /// Get file info/metadata
  Future<Map<String, dynamic>> getFileInfo(String bucket, String path) async {
    try {
      // Supabase Storage doesn't have a direct getMetadata method like Firebase
      // We can check if file exists by trying to get public URL
      final url = _supabase.storage.from(bucket).getPublicUrl(path);

      return {
        'success': true,
        'url': url,
        'path': path,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file info: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
