import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/models/data/product.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  static late final String _url;
  static final _client = http.Client();

  factory ProductService() {
    return _instance;
  }

  ProductService._internal();

  static Future<void> initializeProductService() async {
    await dotenv.load(fileName: '.env');
    final host = dotenv.env['API_HOST'] ?? 'localhost:8080';
    _url = 'http://$host/products-service/api/v1';
  }

  // Get all products
  static Future<List<Product>?> getProducts() async {
    var url = '$_url/products';
    try {
      var response = await _client.get(Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Product.fromJsonList(decodedBody);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get a product by code
  static Future<Product?> getProduct(String code) async {
    var url = '$_url/products/$code';
    var response = await _client.get(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Product.fromMap(jsonDecode(decodedBody));
    } else {
      return null;
    }
  }
}