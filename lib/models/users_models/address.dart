import 'dart:convert';

class Address {
  final int id;
  final String name;
  final String address;
  final String details;
  final double latitude;
  final double longitude;

  Address({
    required this.id,
    required this.name,
    required this.address,
    required this.details,
    required this.latitude,
    required this.longitude,
  });

  // CopyWith
  Address copyWith({
    int? id,
    String? name,
    String? address,
    String? details,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      details: details ?? this.details,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      details: map['details'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  factory Address.fromJson(String source) =>
      Address.fromMap(jsonDecode(source));

  static List<Address> fromJsonList(String source) {
    final list = jsonDecode(source) as List;
    return list.map((e) => Address.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String toJson() => jsonEncode(toMap());
}
