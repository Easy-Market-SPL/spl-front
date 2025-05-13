import 'dart:io';

import 'package:flutter/foundation.dart';
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

  Future<String?> uploadImage(String filePath, String productCode, [Uint8List? webImageBytes]) async {
    try {
      String storageResponse = '';

      if (kIsWeb) {
        if (webImageBytes == null) {
          debugPrint('Error: No image bytes provided for web upload');
          return null;
        }

        storageResponse = await storage.from(imagesPath).uploadBinary(
          '$productsPath/$productCode', 
          webImageBytes,
          fileOptions: const FileOptions(upsert: true),
        );
      } else {
        final file = File(filePath);
        storageResponse = await storage.from(imagesPath).upload(
          '$productsPath/$productCode', 
          file,
          fileOptions: const FileOptions(upsert: true),
        );
      }

      if (storageResponse.isEmpty) return null;

      final String publicUrl =
          storage.from(imagesPath).getPublicUrl('$productsPath/$productCode');

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image to Supabase: $e');
      return null;
    }
  }

  Future<String?> uploadChatImage(String filePath, String messageId) async {
    try {
      final File file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName = '$messageId.$fileExt';

      final storageResponse = await storage.from(chatPath).upload(
          '$chatImagesPath/$fileName', file,
          fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) return null;

      final String publicUrl =
          storage.from(chatPath).getPublicUrl('$chatImagesPath/$fileName');

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading chat image to Supabase: $e');
      return null;
    }
  }
}
