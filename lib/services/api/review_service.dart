// lib/services/review_service.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/models/data/review.dart';
import 'package:spl_front/services/util/retry_request.dart';

import '../../models/data/review_average.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  static late final String _baseUrl;
  static final _client = http.Client();
  static bool isInitialized = false;

  factory ReviewService() => _instance;
  ReviewService._internal();

  /// Debe llamarse una vez al iniciar la app
  static Future<void> initializeReviewService() async {
    if (isInitialized) return;
    final host = dotenv.env['API_HOST'] ?? 'localhost:8080';
    _baseUrl = 'http://$host/reviews-service/api/v1';
    isInitialized = true;
  }

  /// GET /reviews
  static Future<List<Review>?> getAllReviews() async {
    final url = '$_baseUrl/reviews';
    try {
      final response = await fetchWithRetry(url);
      final decoded = utf8.decode(response.bodyBytes);
      return Review.fromJsonList(decoded);
    } catch (e) {
      debugPrint('❌ Error fetching all reviews: $e');
      return null;
    }
  }

  /// GET /reviews/user/{idUser}
  static Future<List<Review>?> getReviewsByUser(String idUser) async {
    final url = '$_baseUrl/reviews/user/$idUser';
    try {
      final response = await fetchWithRetry(url);
      final decoded = utf8.decode(response.bodyBytes);
      return Review.fromJsonList(decoded);
    } catch (e) {
      debugPrint('❌ Error fetching reviews by user: $e');
      return null;
    }
  }

  /// GET /reviews/product/{idProduct}
  static Future<List<Review>?> getReviewsByProduct(String productCode) async {
    final url = '$_baseUrl/reviews/product/$productCode';
    try {
      final response = await fetchWithRetry(url);
      final decoded = utf8.decode(response.bodyBytes);
      return Review.fromJsonList(decoded);
    } catch (e) {
      debugPrint('❌ Error fetching reviews by product: $e');
      return null;
    }
  }

  /// GET /reviews/average/{idProduct}
  static Future<ReviewAverage?> getReviewAverage(String productCode) async {
    final url = '$_baseUrl/reviews/average/$productCode';
    try {
      final response = await fetchWithRetry(url);
      final map =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ReviewAverage.fromJson(map);
    } catch (e) {
      debugPrint('❌ Error fetching review average: $e');
      return null;
    }
  }

  /// GET /reviews/{idReview}
  static Future<Review?> getReviewById(int idReview) async {
    final url = '$_baseUrl/reviews/$idReview';
    try {
      final response = await fetchWithRetry(url);
      final map = json.decode(utf8.decode(response.bodyBytes));
      return Review.fromJson(map);
    } catch (e) {
      debugPrint('❌ Error fetching review by id: $e');
      return null;
    }
  }

  /// POST /reviews
  static Future<Review?> createReview({
    required String productCode,
    required String idUser,
    required double calification,
    String? commentary,
  }) async {
    final url = '$_baseUrl/reviews';
    final body = json.encode({
      'idProduct': productCode,
      'idUser': idUser,
      'calification': calification,
      if (commentary != null) 'commentary': commentary,
    });

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        final map = json.decode(utf8.decode(response.bodyBytes));
        return Review.fromJson(map);
      } else {
        debugPrint('❌ createReview failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error creating review: $e');
      return null;
    }
  }

  /// PUT /reviews/{idReview}
  static Future<Review?> updateReview({
    required int idReview,
    required double calification,
    String? commentary,
  }) async {
    final url = '$_baseUrl/reviews/$idReview';
    final body = json.encode({
      'calification': calification,
      if (commentary != null) 'commentary': commentary,
    });

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        final map = json.decode(utf8.decode(response.bodyBytes));
        return Review.fromJson(map);
      } else {
        debugPrint('❌ updateReview failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error updating review: $e');
      return null;
    }
  }

  /// DELETE /reviews/{idReview}
  static Future<bool> deleteReview(int idReview) async {
    final url = '$_baseUrl/reviews/$idReview';
    try {
      final response = await _client.delete(Uri.parse(url));
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Error deleting review: $e');
      return false;
    }
  }
}
