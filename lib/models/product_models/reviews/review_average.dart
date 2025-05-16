// lib/models/data/review_average_dto.dart
import 'dart:convert';

class ReviewAverage {
  final String productId;
  final double average;

  ReviewAverage({
    required this.productId,
    required this.average,
  });

  factory ReviewAverage.fromJson(Map<String, dynamic> json) {
    return ReviewAverage(
      productId: json['productId'] as String,
      average: (json['average'] as num).toDouble(),
    );
  }

  static List<ReviewAverage> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((json) => ReviewAverage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'average': average,
      };
}
