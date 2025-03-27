import 'dart:convert';

class ProductColor {
  final int idColor;
  final String name;
  final String hexCode;

  ProductColor({required this.idColor,required this.name, required this.hexCode});

  factory ProductColor.fromMap(Map<String, dynamic> map) {
    return ProductColor(
      idColor: map['idColor'] ?? 0,
      name: map['name'] ?? '',
      hexCode: map['hexCode'] ?? '',
    );
  }

  factory ProductColor.fromJson(String json) {
    return ProductColor.fromMap(jsonDecode(json));
  }

  static List<ProductColor> fromJsonList(String json) {
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => ProductColor.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap(ProductColor color) {
    return {
      'idColor': color.idColor,
      'name': color.name,
      'hexCode': color.hexCode,
    };
  }

  String toJson() {
    return jsonEncode(toMap(this));
  }

  static String toJsonList(List<ProductColor> colors) {
    return jsonEncode(colors.map((e) => e.toMap(e)).toList());
  }
  
}