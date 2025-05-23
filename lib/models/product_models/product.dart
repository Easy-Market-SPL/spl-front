import 'dart:convert';

import 'package:spl_front/models/product_models/reviews/review.dart';

import '../../services/api_services/review_service/review_service.dart';
import 'labels/label.dart';

class Product {
  final String code;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final List<Label>? labels;
  List<Review>? reviews;
  double? rating;

  Product({
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.labels,
    this.rating,
    this.reviews,
  });

  // CopyWith
  Product copyWith({
    String? code,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    List<Label>? labels,
    double? rating,
    List<Review>? reviews,
  }) {
    return Product(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      labels: labels ?? this.labels,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      imagePath: map['imgUrl'] ?? '',
      labels: map['labels'] != null ? Label.fromMapList(map['labels']) : [],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      // map['reviews'] es una lista de JSON, no String
      reviews: map['reviews'] != null
          ? (map['reviews'] as List)
              .map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  factory Product.fromJson(String source) =>
      Product.fromMap(jsonDecode(source));

  static List<Product> fromJsonList(String source) {
    final list = jsonDecode(source) as List;
    return list.map((e) => Product.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'price': price,
      'imgUrl': imagePath,
    };
  }

  String toJson() => jsonEncode(toMap());

  Future<void> fetchReviewsProduct(String productCode) async {
    reviews = await ReviewService.getReviewsByProduct(productCode);
  }

  Future<void> fetchReviewAverage(String productCode) async {
    final avg = await ReviewService.getReviewAverage(productCode);
    if (avg != null) rating = avg.average;
  }
}
