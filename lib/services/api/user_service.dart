import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  static late final String _url;
  static final _client = http.Client();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  static Future<void> initializeUserService() async {
    await dotenv.load(fileName: '.env');
    final host = dotenv.env['API_HOST'] ?? 'localhost:8080';
    _url = 'http://$host/users-service/api/v1';
  }

  static Future<UserModel?> getUser(String id) async {
    var url = '$_url/users/$id';
    var response = await _client.get(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.body);
    } else {
      return null;
    }
  }

  static Future<List<UserModel>> getUsers() async {
    var url = '$_url/users';
    var response = await _client.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return userFromJson(response.body);
    } else {
      return [];
    }
  }

  static Future<bool> createUser(UserModel user) async {
    var url = '$_url/users';
    var response = await _client.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: user.toJson());
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<bool> deleteUser(String id) async {
    var url = '$_url/users/$id/delete';
    var response = await _client.put(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete user');
    }
  }

  static Future<bool> updateUser(UserModel user, String id) async {
    var url = '$_url/users/$id';
    var response = await _client.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: user.toJson());
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update user');
    }
  }
}
