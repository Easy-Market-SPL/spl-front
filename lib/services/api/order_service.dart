import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spl_front/services/util/retry_request.dart';

import '../../models/exception/api_error.dart';
import '../../models/order_models/order_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  static late final String _baseUrl;
  static final _client = http.Client();
  static bool isInitialized = false;

  factory OrderService() => _instance;

  OrderService._internal();

  static Future<void> initializeOrderService() async {
    if (isInitialized) return;
    final host = dotenv.env['API_HOST'] ?? 'localhost:8080';
    _baseUrl = 'http://$host/orders-service/api/v1';
    isInitialized = true;
  }

  /// GET /orders
  /// Returns a list of orders, or an error message in case of failure.
  static Future<(List<OrderModel>?, String?)> getAllOrders() async {
    final url = '$_baseUrl/orders';
    try {
      final response = await fetchWithRetry(url);
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final orders = OrderModel.fromJsonList(decodedBody);
        // Sort the statuses by date in each order
        for (var order in orders) {
          order.orderStatuses
              .sort((a, b) => a.startDate.compareTo(b.startDate));
        }
        return (orders, null);
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// GET /orders/{id}
  /// Returns a single order, or an error message in case of failure.
  static Future<(OrderModel?, String?)> getOrderById(int id) async {
    final url = '$_baseUrl/orders/$id';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));

        // Sort the statuses by date
        order.orderStatuses.sort((a, b) => a.startDate.compareTo(b.startDate));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// GET /orders/user/{idUser}
  /// Returns all orders that belong to a specific user.
  static Future<(List<OrderModel>?, String?)> getOrdersByUser(
      String userId) async {
    final url = '$_baseUrl/orders/$userId/user';
    try {
      final response = await fetchWithRetry(url);
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final orders = OrderModel.fromJsonList(decodedBody);
        // Print the orders for debugging
        debugPrint('Orders for user $userId: ${orders.length}');

        // Sort the statuses by date in each order
        for (var order in orders) {
          order.orderStatuses
              .sort((a, b) => a.startDate.compareTo(b.startDate));
        }

        return (orders, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()} Order URL: $url');
      return (null, e.toString());
    }
  }

  /// POST /orders
  /// Creates a new order. The API requires `idUser` and `address`.
  static Future<(OrderModel?, String?)> createOrder({
    required String idUser,
    required String address,
  }) async {
    final url = '$_baseUrl/orders';
    final body = jsonEncode({
      "idUser": idUser,
      "address": address,
    });

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: body,
      );
      final decodedBody = utf8.decode(response.bodyBytes);

      // The backend may return 201 (Created) or 200 (OK).
      if (response.statusCode == 201 || response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// PUT /orders/{id}
  /// Updates the address of an order.
  static Future<(OrderModel?, String?)> updateOrder({
    required int orderId,
    required String address,
  }) async {
    final url = '$_baseUrl/orders/$orderId';
    final body = jsonEncode({"address": address});

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: body,
      );
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// PUT /orders/{id}/confirm
  /// Confirms an order, requiring shippingCost and paymentAmount.
  static Future<(OrderModel?, String?)> confirmOrder({
    required int orderId,
    required int shippingCost,
    required double paymentAmount,
  }) async {
    final url = '$_baseUrl/orders/$orderId/confirm';
    final body = jsonEncode({
      "shippingCost": shippingCost,
      "paymentAmount": paymentAmount,
    });

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: body,
      );
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// PUT /orders/{id}/prepare
  /// Changes the status of an order to 'preparing'.
  static Future<(OrderModel?, String?)> prepareOrder(int orderId) async {
    final url = '$_baseUrl/orders/$orderId/preparing';
    try {
      final response = await _client.put(Uri.parse(url));
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// PUT /orders/{id}/onTheWay/domiciliary
  /// Changes the status to 'on the way' with a specific domiciliary and coordinates.
  static Future<(OrderModel?, String?)> onTheWayDomiciliaryOrder({
    required int orderId,
    required String idDomiciliary,
    required double initialLatitude,
    required double initialLongitude,
  }) async {
    final url = '$_baseUrl/orders/$orderId/onTheWay/domiciliary';
    final body = jsonEncode({
      "idDomiciliary": idDomiciliary,
      "initialLatitude": initialLatitude,
      "initialLongitude": initialLongitude,
    });

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: body,
      );
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// PUT /orders/{id}/onTheWay/transport
  /// Changes the status to 'on the way' with a transport company.
  static Future<(OrderModel?, String?)> onTheWayTransportCompanyOrder({
    required int orderId,
    required String transportCompany,
    required String shippingGuide,
  }) async {
    final url = '$_baseUrl/orders/$orderId/onTheWay/transport';
    final body = jsonEncode({
      "transportCompany": transportCompany,
      "shippingGuide": shippingGuide,
    });

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: body,
      );
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// PUT /orders/{id}/delivered
  /// Changes the status of an order to 'delivered'.
  static Future<(OrderModel?, String?)> deliveredOrder(int orderId) async {
    final url = '$_baseUrl/orders/$orderId/delivered';
    try {
      final response = await _client.put(Uri.parse(url));
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// DELETE /orders/{id}
  /// Deletes an order by ID.
  static Future<(bool, String?)> deleteOrder(int orderId) async {
    final url = '$_baseUrl/orders/$orderId';
    try {
      final response = await _client.delete(Uri.parse(url));
      if (response.statusCode == 204) {
        return (true, null);
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (false, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (false, e.toString());
    }
  }

  /// PUT /orders/{id}/debt
  /// Updates the debt of an order, sending { paymentAmount } in the body.
  static Future<(OrderModel?, String?)> updateDebt({
    required int orderId,
    required double paymentAmount,
  }) async {
    final url = '$_baseUrl/orders/$orderId/debt';
    final body = jsonEncode({"paymentAmount": paymentAmount});

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: body,
      );
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// PUT /orders/{id}/products
  /// Adds or updates a product in the order, sending { productCode, quantity } in the body.
  static Future<(OrderModel?, String?)> addProductToOrder({
    required int orderId,
    required String productCode,
    required int quantity,
  }) async {
    final url = '$_baseUrl/orders/$orderId/products/$productCode';
    final body = jsonEncode({
      "quantity": quantity,
    });

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: body,
      );
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(jsonDecode(decodedBody));
        return (order, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (null, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (null, e.toString());
    }
  }

  /// DELETE /orders/{id}/products?productCode=X
  /// Removes a specific product from the order.
  static Future<(bool, String?)> deleteProductFromOrder({
    required int orderId,
    required String productCode,
  }) async {
    final url = '$_baseUrl/orders/$orderId/products/$productCode';
    try {
      final response = await _client.delete(Uri.parse(url));
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        return (true, null);
      } else {
        final err = ApiError.fromJson(jsonDecode(decodedBody));
        return (false, err.message);
      }
    } catch (e) {
      debugPrint('❌ ${e.toString()}');
      return (false, e.toString());
    }
  }
}
