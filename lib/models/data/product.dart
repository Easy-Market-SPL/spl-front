import 'dart:convert';

import 'package:spl_front/models/data/label.dart';

class Product {
  final String code;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final List<Label>? labels;
  final double? rating;

  Product({
    required this.code,
    required this.name, 
    required this.description,
    required this.price,
    required this.imagePath,
    this.labels,
    this.rating,
  });
  
  // Factory method to create a Product from a Map (useful for API responses)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      imagePath: map['imgUrl'] ?? '',
      labels: map['labels'] != null ? Label.fromMapList(map['labels']) : [],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
    );
  }

  // Factory method to get a product from a JSON
  factory Product.fromJson(String json) {
    return Product.fromMap(jsonDecode(json));
  }

  // Get a list of products from a JSON
  static List<Product> fromJsonList(String json) {
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => Product.fromMap(e)).toList();
  }

  // Factory method to convert a Product to a Map
  Map<String, dynamic> toMap(Product product) {
    return {
      'code': product.code,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imgUrl': product.imagePath,
    };
  }

  // Method to convert a Product to JSON
  String toJson(){
    return jsonEncode(toMap(this));
  }
}