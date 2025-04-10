import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/services/util/retry_request.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

class ColorService {
  static final ColorService _instance = ColorService._internal();
  static late final String _url;
  static final _client = http.Client();
  static bool isInitialized = false;

  factory ColorService() {
    return _instance;
  }

  ColorService._internal();

  // Initialize the ProductService with the API URL
  static Future<void> initializeProductService() async {
    if (isInitialized) return;

    final host = dotenv.env['API_HOST'] ?? 'localhost:8080';
    _url = 'http://$host/products-service/api/v1';
    isInitialized = true;
  }

  // Fetch all colors
  static Future<List<ProductColor>?> getColors() async {
    var url = '$_url/colors';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return ProductColor.fromJsonList(decodedBody);
    } catch (e) {
      debugPrint('❌ ${ProductStrings.fetchProductsError}: $e');
      return null;
    }
  }

  // Fetch a color by its code
  static Future<ProductColor?> getColor(int id) async {
    var url = '$_url/colors/$id';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return ProductColor.fromJson(decodedBody);
    } catch (e) {
      debugPrint('❌ ${ProductStrings.fetchProductError}: $e');
      return null;
    }
  }

  // Create a new color
  static Future<ProductColor?> createColor(ProductColor color) async {
    var url = '$_url/colors';
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: color.toJson(),
      );
      if (response.statusCode == 201) {
        return ProductColor.fromJson(response.body);
      } else {
        debugPrint('❌ ${ProductStrings.createProductError}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ ${ProductStrings.createProductError}: $e');
      return null;
    }
  }
}