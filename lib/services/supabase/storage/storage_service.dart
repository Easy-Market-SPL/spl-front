import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spl_front/services/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService{
  final storage = SupabaseConfig().client.storage;
  final imagesPath = 'images';
  final productsPath = 'products';


  static bool isLocalImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;

    return !(imageUrl.startsWith('http') || imageUrl.startsWith('https'));
  }

  Future<String?> uploadImage(String filePath, String productCode) async {
    try{
      final File file = File(filePath);
      final storageResponse = await storage.from(imagesPath).upload(
        '$productsPath/$productCode', 
        file,
        fileOptions: const FileOptions(upsert: true)
      );
      if(storageResponse.isEmpty) return null; 

      final String publicUrl = storage
        .from(imagesPath)
        .getPublicUrl('$productsPath/$productCode');

      return publicUrl;

    } catch(e){
      debugPrint('Error uploading image to Supabase: $e');
      return null;
    }
  }
}