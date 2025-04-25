import 'dart:convert';

import 'package:spl_front/models/logic/user_type.dart';

/// Parse a JSON string into a List of UserModel
List<UserModel> userFromJson(String str) =>
    List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJsonMap(x)));

/// Convert a List of UserModel into a JSON string
String userToJson(List<UserModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJsonMap())));

class UserModel {
  String id;
  String username;
  String fullname;
  String email;
  String rol;

  UserModel({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    required this.rol,
  });

  /// Factory constructor to parse a single JSON string (usado en getUser)
  factory UserModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserModel(
      id: json["id"],
      username: json["username"],
      fullname: json["fullname"],
      email: json["email"],
      rol: json["rol"],
    );
  }

  /// Factory constructor to parse a Map (usado en userFromJson para la lista)
  factory UserModel.fromJsonMap(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      username: json["username"],
      fullname: json["fullname"],
      email: json["email"],
      rol: json["rol"],
    );
  }

  /// Convert a UserModel instance into a JSON string
  String toJson() => jsonEncode(toJsonMap());

  /// Convert a UserModel instance into a Map (usado en userToJson)
  Map<String, dynamic> toJsonMap() => {
        "id": id,
        "username": username,
        "fullname": fullname,
        "email": email,
        "rol": rol,
      };

  UserType getUserType() {
    if (rol == 'customer') {
      return UserType.customer;
    } else if (rol == 'business') {
      return UserType.business;
    } else if (rol == 'delivery') {
      return UserType.delivery;
    } else {
      return UserType.admin;
    }
  }
}
