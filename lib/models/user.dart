// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  String id;
  String username;
  String fullname;
  String email;
  String rol;

  User({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    required this.rol,
  });

  factory User.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return User(
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
