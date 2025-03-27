import 'dart:convert';

class Label {
  final int idLabel;
  final String name;
  String description;

  Label({required this.idLabel ,required this.name, required this.description});

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      idLabel: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  static List<Label> fromMapList(List<dynamic> list) {
    return list.map((e) => Label.fromMap(e)).toList();
  }

  factory Label.fromJson(String json) {
    return Label.fromMap(jsonDecode(json));
  }

  static List<Label> fromJsonList(String json) {
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => Label.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap(Label label) {
    return {
      'id': label.idLabel,
      'name': label.name,
      'description': label.description,
    };
  }

  String toJson() {
    return jsonEncode(toMap(this));
  }

  static String toJsonList(List<Label> labels) {
    return jsonEncode(labels.map((e) => e.toMap(e)).toList());
  }
}