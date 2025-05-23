import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/models/product_models/variants/variant.dart';
import 'package:spl_front/services/util/retry_request.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

import '../../../models/product_models/labels/label.dart';
import '../../../models/product_models/product.dart';
import '../../../models/product_models/product_color.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  static late final String _url;
  static final _client = http.Client();
  static bool isInitialized = false;

  factory ProductService() {
    return _instance;
  }

  ProductService._internal();

  // Initialize the ProductService with the API URL
  static Future<void> initializeProductService() async {
    if (isInitialized) return;

    final host = dotenv.env['API_HOST'] ?? 'localhost:8080';
    _url = 'http://$host/products-service/api/v1';
    isInitialized = true;
  }

  // Fetch all products
  static Future<List<Product>?> getProducts() async {
    var url = '$_url/products';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return Product.fromJsonList(decodedBody);
    } catch (e) {
      debugPrint('❌ ${ProductStrings.fetchProductsError}: $e');
      return null;
    }
  }

  // Fetch a product by its code
  static Future<Product?> getProduct(String code) async {
    var url = '$_url/products/$code';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return Product.fromJson(decodedBody);
    } catch (e) {
      debugPrint('❌ ${ProductStrings.fetchProductError}: $e');
      return null;
    }
  }

  // Fetch a products colors
  static Future<List<ProductColor>?> getProductColors(String code) async {
    var url = '$_url/products/$code/colors';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return ProductColor.fromJsonList(decodedBody);
    } catch (e) {
      debugPrint('❌ ${ProductStrings.productColorsError}: $e');
      return null;
    }
  }

  // Fetch a products variants
  static Future<List<Variant>?> getProductVariants(String code) async {
    var url = '$_url/products/$code/variants';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);
      return Variant.fromJsonList(decodedBody);
    } catch (e) {
      debugPrint('❌ ${ProductStrings.productVariantsError}: $e');
      return null;
    }
  }

  // Create a new product
  static Future<Product?> createProduct(Product product) async {
    var url = '$_url/products';
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: product.toJson(),
      );
      if (response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Product.fromJson(decodedBody);
      } else {
        debugPrint('❌ ${ProductStrings.createProductError}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ ${ProductStrings.createProductError}: $e');
      return null;
    }
  }

  // Update an existing product
  static Future<Product?> updateProduct(Product product) async {
    var url = '$_url/products/${product.code}';
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: product.toJson(),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Product.fromJson(decodedBody);
      } else {
        debugPrint('❌ ${ProductStrings.updateProductError}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ ${ProductStrings.updateProductError}: $e');
      return null;
    }
  }

  // Update products labels
  static Future<List<Label>?> updateProductLabels(
      String code, List<Label> labels) async {
    var url = '$_url/products/$code/labels';
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: Label.toJsonList(labels),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Label.fromJsonList(decodedBody);
      } else {
        debugPrint(
            '❌ ${ProductStrings.productLabelsSaveError}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ ${ProductStrings.productLabelsSaveError}: $e');
      return null;
    }
  }

  // Update products colors
  static Future<List<ProductColor>?> updateProductColors(
      String code, List<ProductColor> colors) async {
    var url = '$_url/products/$code/colors';
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: ProductColor.toJsonList(colors),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return ProductColor.fromJsonList(decodedBody);
      } else {
        debugPrint(
            '❌ ${ProductStrings.productColorsSaveError}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ ${ProductStrings.productColorsSaveError}: $e');
      return null;
    }
  }

  // Update products variants
  static Future<List<Variant>?> updateProductVariants(
      String code, List<Variant> variants) async {
    var url = '$_url/products/$code/variants';
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: Variant.toJsonList(variants),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Variant.fromJsonList(decodedBody);
      } else {
        debugPrint(
            '❌ ${ProductStrings.productVariantsSaveError}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ ${ProductStrings.productVariantsSaveError}: $e');
      return null;
    }
  }

  // Delete a product by its code
  static Future<bool> deleteProduct(String code) async {
    var url = '$_url/products/$code';
    try {
      final response = await _client.delete(Uri.parse(url));
      if (response.statusCode == 204) {
        return true;
      } else {
        debugPrint('❌ ${ProductStrings.deleteProductError}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ ${ProductStrings.deleteProductError}: $e');
      return false;
    }
  }
}
