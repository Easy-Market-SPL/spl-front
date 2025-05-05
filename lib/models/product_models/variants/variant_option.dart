import 'dart:convert';

class VariantOption{
  String name;

  VariantOption({required this.name});

  factory VariantOption.fromMap(Map<String, dynamic> map) {
    return VariantOption(
      name: map['name'] ?? '',
    );
  }

  static List<VariantOption> fromMapList(List<dynamic> list) {
    return list.map((e) => VariantOption.fromMap(e)).toList();
  }

  factory VariantOption.fromJson(String json) {
    return VariantOption.fromMap(jsonDecode(json));
  }

  static List<VariantOption> fromJsonList(String json) {
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => VariantOption.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap(VariantOption option) {
    return {
      'name': option.name,
    };
  }

  static List<Map<String, dynamic>> toMapList(List<VariantOption> options) {
    return options.map((e) => e.toMap(e)).toList();
  }

  String toJson() {
    return jsonEncode(toMap(this));
  }

  static String toJsonList(List<VariantOption> options) {
    return jsonEncode(options.map((e) => e.toMap(e)).toList());
  }
}