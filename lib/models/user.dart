// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<UserModel> userFromJson(String str) =>
    List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));

String userToJson(List<UserModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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

  factory UserModel.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return UserModel(
      id: json["id"],
      username: json["username"],
      fullname: json["fullname"],
      email: json["email"],
      rol: json["rol"],
    );
  }

  String toJson() {
    final json = {
      "id": id,
      "username": username,
      "fullname": fullname,
      "email": email,
      "rol": rol,
    };
    return jsonEncode(json);
  }
}
