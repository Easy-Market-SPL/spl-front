// lib/models/data/review_average_dto.dart
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

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'average': average,
      };
}
