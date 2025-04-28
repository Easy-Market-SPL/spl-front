import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/models/data/payment_method.dart';
import 'package:spl_front/models/user.dart';

import '../../models/logic/address.dart';
import '../util/retry_request.dart';

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

  /// ADDRESSES METHODS
  static Future<List<Address>?> getUserAddresses(String id) async {
    final url = '$_url/users/$id/addresses';
    try {
      final response = await fetchWithRetry(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final addresses = Address.fromJsonList(decodedBody);
        return addresses;
      } else {
        debugPrint('❌ getUserAddresses failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching user addresses: $e');
      return null;
    }
  }

  static Future<Address?> createUserAddress(String id, String name,
      String address, String details, double latitude, double longitude) async {
    final url = '$_url/users/$id/addresses';
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'address': address,
          'details': details,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      final decodedBody = utf8.decode(response.bodyBytes);
      final addressResponse = Address.fromJson(decodedBody);
      return addressResponse;
    } catch (e) {
      debugPrint('❌ Error creating user address: $e');
      throw Exception('Failed to create user address');
    }
  }

  static Future<Address?> updateUserAddress(
      String idUser, Address address) async {
    final url = '$_url/users/$idUser/addresses/${address.id}';
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: address.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final addressResponse = Address.fromJson(decodedBody);
        return addressResponse;
      } else {
        debugPrint('❌ updateUserAddress failed: ${response.statusCode}');
        throw Exception('Failed to update user address');
      }
    } catch (e) {
      debugPrint('❌ Error updating user address: $e');
      throw Exception('Failed to update user address');
    }
  }

  static Future<bool> deleteUserAddress(String idUser, int addressId) async {
    final url = '$_url/users/$idUser/addresses/$addressId';
    try {
      final response = await _client.delete(Uri.parse(url));
      if (response.statusCode == 204) {
        return true;
      } else {
        debugPrint('❌ deleteUserAddress failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting user address: $e');
      return false;
    }
  }

  /// PAYMENT METHODS FUNCTIONS
  static Future<List<PaymentMethodCard>?> getUserPaymentMethods(
      String id) async {
    final url = '$_url/users/$id/payment-methods';
    try {
      final response = await fetchWithRetry(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final paymentMethods = PaymentMethodCard.fromJsonList(decodedBody);
        return paymentMethods;
      } else {
        debugPrint('❌ getUserPaymentMethods failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching user payment methods: $e');
      return null;
    }
  }

  static Future<PaymentMethodCard?> createUserPaymentMethod(
      String idUser, PaymentMethodCard paymentMethod) async {
    final url = '$_url/users/$idUser/payment-methods';
    try {
      final response = await _client.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'cardNumber': paymentMethod.cardNumber.toString(),
            'email': paymentMethod.email.toString(),
            'phone': paymentMethod.phone.toString(),
            'expiryDate': paymentMethod.expiryDate.toString(),
            'cardHolderName': paymentMethod.cardHolderName.toString(),
            'city': paymentMethod.address.city.toString(),
            'stateName': paymentMethod.address.state.toString(),
            'country': paymentMethod.address.country.toString(),
            'firstLine': paymentMethod.address.line1.toString(),
            'secondLine': paymentMethod.address.line2.toString(),
            'postalCode': paymentMethod.address.postalCode.toString(),
          }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final paymentMethodResponse =
            PaymentMethodCard.fromRawJson(decodedBody);
        return paymentMethodResponse;
      } else {
        debugPrint('❌ createUserPaymentMethod failed: ${response.statusCode}');
        throw Exception('Failed to create user payment method');
      }
    } catch (e) {
      debugPrint('❌ Error creating user payment method: $e');
      throw Exception('Failed to create user payment method');
    }
  }

  static Future<bool> deleteUserPaymentMethod(
      String idUser, int paymentMethodId) async {
    final url = '$_url/users/$idUser/payment-methods/$paymentMethodId';
    try {
      final response = await _client.delete(Uri.parse(url));
      if (response.statusCode == 204) {
        return true;
      } else {
        debugPrint('❌ deleteUserPaymentMethod failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting user payment method: $e');
      return false;
    }
  }
}
