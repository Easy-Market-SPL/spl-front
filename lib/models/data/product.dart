import 'dart:convert';

class Product {
  final String code;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final double? rating;

  Product({
    required this.code,
    required this.name, 
    required this.description,
    required this.price,
    required this.imagePath,
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
}