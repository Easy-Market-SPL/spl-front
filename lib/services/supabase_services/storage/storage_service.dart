import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_config.dart';

class StorageService {
  final storage = SupabaseConfig().client.storage;
  final imagesPath = 'images';
  final productsPath = 'products';
  final chatPath = 'chat';
  final chatImagesPath = 'images';

  static bool isLocalImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;

    return !(imageUrl.startsWith('http') || imageUrl.startsWith('https'));
  }

  Future<String?> _uploadFileToStorage({
    required String bucket,
    required String path,
    required dynamic fileSource,
    Uint8List? webBytes,
    bool upsert = true,
  }) async {
    try {
      String storageResponse = '';

      if (kIsWeb) {
        if (webBytes != null) {
          storageResponse = await storage.from(bucket).uploadBinary(
            path,
            webBytes,
            fileOptions: FileOptions(upsert: upsert),
          );
        } else if (fileSource is XFile) {
          final bytes = await fileSource.readAsBytes();
          storageResponse = await storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: upsert),
          );
        } else {
          debugPrint('Error: Unsupported file type for Web upload');
          return null;
        }
      } 
      
      // Mobile
      else {
        File file;
        if (fileSource is String) {
          file = File(fileSource);
        } else if (fileSource is XFile) {
          file = File(fileSource.path);
        } else if (fileSource is File) {
          file = fileSource;
        } else {
          debugPrint('Error: Unsupported file type for Mobile upload');
          return null;
        }

        storageResponse = await storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(upsert: upsert),
        );
      }

      if (storageResponse.isEmpty) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicUrl = storage.from(bucket).getPublicUrl(path);

      final imageUrl = '$publicUrl?v=$timestamp'; // Add timestamp to avoid caching issues

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploadint to Supabase: $e');
      return null;
    }
  }

  Future<String?> uploadImage(dynamic fileSource, String productCode, [Uint8List? webImageBytes]) async {
    final String filePath = '$productsPath/$productCode';
    
    return _uploadFileToStorage(
      bucket: imagesPath,
      path: filePath,
      fileSource: fileSource,
      webBytes: webImageBytes,
    );
  }

  Future<String?> uploadChatImage(dynamic fileSource, String messageId, Uint8List? webImageBytes) async {
    String fileExt = 'jpg';
    
    if (fileSource is String) {
      fileExt = fileSource.split('.').last;
    } else if (fileSource is XFile) {
      fileExt = fileSource.name.split('.').last;
    }
    
    final String fileName = '$messageId.$fileExt';
    final String filePath = '$chatImagesPath/$fileName';
    
    return _uploadFileToStorage(
      bucket: chatPath,
      path: filePath,
      fileSource: fileSource,
      webBytes: webImageBytes,
    );
  }
}
