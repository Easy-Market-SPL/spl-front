import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/services/util/retry_request.dart';

class LabelService {
  static final LabelService _instance = LabelService._internal();
  static late final String _url;
  static final _client = http.Client();
  static bool isInitialized = false;

  factory LabelService() {
    return _instance;
  }

  LabelService._internal();

  // Initialize the ProductService with the API URL
  static Future<void> initializeLabelService() async {
    if (isInitialized) return;

    final host = dotenv.env['API_HOST'] ?? 'localhost:8080';
    _url = 'http://$host/products-service/api/v1';
    isInitialized = true;
  }

  // Fetch all labels
  static Future<List<Label>?> getLabels() async {
    var url = '$_url/labels';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return Label.fromJsonList(decodedBody);
    } catch (e) {
      debugPrint('❌: $e');
      return null;
    }
  }

  // Fetch a label by its id
  static Future<Label?> getLabel(int id) async {
    var url = '$_url/labels/$id';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return Label.fromJson(decodedBody);
    } catch (e) {
      //debugPrint('❌ ${ProductStrings.fetchProductError}: $e');
      return null;
    }
  }

  // Fetch products with a label by its id
  static Future<List<Product>?> getLabelProducts(int id) async {
    var url = '$_url/labels/$id/products';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return Product.fromJsonList(decodedBody);
    } catch (e) {
      //debugPrint('❌ ${ProductStrings.fetchProductError}: $e');
      return null;
    }
  }

  // Create a new label
  static Future<Label?> createLabel(Label label) async {
    var url = '$_url/labels';
    try {
      final response = await _client.post(
        Uri.parse(url),
        body: label.toJson(),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Label.fromJson(decodedBody);
      } else {
        debugPrint('❌ Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return null;
    }
  }
}