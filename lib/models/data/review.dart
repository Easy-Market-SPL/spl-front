import 'dart:convert';

class Review {
  final int? id;
  final double? calification;
  final String? commentary;
  final String? productCode;
  final String? idUser;

  Review({
    this.id,
    this.calification,
    this.commentary,
    this.productCode,
    this.idUser,
  });

  Review copyWith({
    int? id,
    double? calification,
    String? commentary,
    String? productCode,
    String? idUser,
  }) {
    return Review(
      id: id ?? this.id,
      calification: calification ?? this.calification,
      commentary: commentary ?? this.commentary,
      productCode: productCode ?? this.productCode,
      idUser: idUser ?? this.idUser,
    );
  }

  /// Create a Review from a `String` JSON
  factory Review.fromRawJson(String str) => Review.fromJson(json.decode(str));

  /// Convert this Review to a `String` JSON
  String toRawJson() => json.encode(toJson());

  /// Create a Review from a `Map<String, dynamic>`
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json["id"] as int?,
      calification: json["calification"] == null
          ? null
          : (json["calification"] as num).toDouble(),
      commentary: json["commentary"] as String?,
      productCode: json["productCode"] as String?,
      idUser: json["idUser"] as String?,
    );
  }

  /// Convert this Review to a `Map<String, dynamic>`
  Map<String, dynamic> toJson() => {
        "id": id,
        "calification": calification,
        "commentary": commentary,
        "productCode": productCode,
        "idUser": idUser,
      };

  /// Create a list of Reviews from a JSON string
  static List<Review> fromJsonList(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr);
    return data
        .map((item) => Review.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
