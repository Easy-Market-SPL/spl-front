import 'dart:convert';

import 'package:spl_front/models/product_models/variants/variant_option.dart';

class Variant {
  String name;
  List<VariantOption> options;

  Variant({required this.name, required this.options});

  factory Variant.fromMap(Map<String, dynamic> map) {
    return Variant(
      name: map['name'] ?? '',
      options: VariantOption.fromMapList(map['options'] ?? ''),
    );
  }

  factory Variant.fromJson(String json) {
    return Variant.fromMap(jsonDecode(json));
  }

  static List<Variant> fromJsonList(String json) {
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => Variant.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap(Variant variant) {
    return {
      'name': variant.name,
      'options': VariantOption.toMapList(variant.options),
    };
  }

  String toJson() {
    return jsonEncode(toMap(this));
  }

  static String toJsonList(List<Variant> variants) {
    return jsonEncode(variants.map((e) => e.toMap(e)).toList());
  }
}
