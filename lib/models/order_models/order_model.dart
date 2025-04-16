import 'dart:convert';

import 'order_product.dart';
import 'order_status.dart';

class OrderModel {
  final int? id;
  final String? idUser;
  final DateTime? creationDate;
  final double? total;
  final String? address;
  final int? shippingCost;
  final String? transportCompany;
  final String? shippingGuide;
  final String? idDomiciliary;
  final double? lat;
  final double? lng;
  final double? debt;

  final List<OrderProduct>? orderProducts;
  final List<OrderStatus>? orderStatuses;

  OrderModel({
    this.id,
    this.idUser,
    this.creationDate,
    this.total,
    this.address,
    this.shippingCost,
    this.transportCompany,
    this.shippingGuide,
    this.idDomiciliary,
    this.lat,
    this.lng,
    this.debt,
    this.orderProducts,
    this.orderStatuses,
  });

  /// CopyWith Method
   copyWith({
    int? id,
    String? idUser,
    DateTime? creationDate,
    double? total,
    String? address,
    int? shippingCost,
    String? transportCompany,
    String? shippingGuide,
    String? idDomiciliary,
    double? lat,
    double? lng,
    double? debt,
    List<OrderProduct>? orderProducts,
    List<OrderStatus>? orderStatuses,
  }) {
    return OrderModel(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      creationDate: creationDate ?? this.creationDate,
      total: total ?? this.total,
      address: address ?? this.address,
      shippingCost: shippingCost ?? this.shippingCost,
      transportCompany: transportCompany ?? this.transportCompany,
      shippingGuide: shippingGuide ?? this.shippingGuide,
      idDomiciliary: idDomiciliary ?? this.idDomiciliary,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      debt: debt ?? this.debt,
      orderProducts: orderProducts ?? this.orderProducts,
      orderStatuses: orderStatuses ?? this.orderStatuses,
    );
  }

  /// Create and order from a JSON string.
  factory OrderModel.fromRawJson(String str) =>
      OrderModel.fromJson(json.decode(str));

  /// Create an order from a Map.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json["id"],
      idUser: json["idUser"],
      creationDate: json["creationDate"] == null
          ? null
          : DateTime.parse(json["creationDate"]),
      total: (json["total"] == null) ? null : json["total"].toDouble(),
      address: json["address"],
      shippingCost: json["shippingCost"],
      transportCompany: json["transportCompany"],
      shippingGuide: json["shippingGuide"],
      idDomiciliary: json["idDomiciliary"],
      lat: json["lat"]?.toDouble(),
      lng: json["lng"]?.toDouble(),
      debt: json["debt"]?.toDouble(),

      // Convert the JSON object \"products\" to List<OrderProduct>
      orderProducts: _parseOrderProducts(
        json["products"],
        idOrder: json["id"],
      ),

      // Covert the JSON object \"status\" to List<OrderStatus>
      orderStatuses: _parseOrderStatuses(json["status"]),
    );
  }

  /// Convert this object to a JSON string.
  static List<OrderModel> fromJsonList(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => OrderModel.fromJson(e)).toList();
  }

  /// Parse the object to a list of List of OrderProduct objects.
  static List<OrderProduct>? _parseOrderProducts(
      Map<String, dynamic>? productsJson,
      {required int? idOrder}) {
    if (productsJson == null || idOrder == null) return null;

    final List<OrderProduct> products = [];
    productsJson.forEach((productCode, quantity) {
      products.add(OrderProduct(
        idOrder: idOrder,
        idProduct: productCode,
        quantity: quantity,
      ));
    });
    return products;
  }

  /// Parse the object to a list of List of OrderStatus objects.
  static List<OrderStatus>? _parseOrderStatuses(
      Map<String, dynamic>? statusJson) {
    if (statusJson == null) return null;
    final List<OrderStatus> statuses = [];
    statusJson.forEach((statusKey, startDateString) {
      statuses.add(OrderStatus(
        status: statusKey,
        startDate: DateTime.parse(startDateString),
      ));
    });
    return statuses;
  }

  /// Convert this object to a JSON string.
  Map<String, dynamic> toJson() => {
        "id": id,
        "idUser": idUser,
        "creationDate": creationDate?.toIso8601String(),
        "total": total,
        "address": address,
        "shippingCost": shippingCost,
        "transportCompany": transportCompany,
        "shippingGuide": shippingGuide,
        "idDomiciliary": idDomiciliary,
        "lat": lat,
        "lng": lng,
        "debt": debt,
        "products": _orderProductsToMap(orderProducts),
        "status": _orderStatusesToMap(orderStatuses),
      };

  static Map<String, dynamic>? _orderProductsToMap(
      List<OrderProduct>? products) {
    if (products == null) return null;
    final Map<String, dynamic> map = {};
    for (var op in products) {
      map[op.idProduct] = op.quantity;
    }
    return map;
  }

  static Map<String, dynamic>? _orderStatusesToMap(
      List<OrderStatus>? statuses) {
    if (statuses == null) return null;
    final Map<String, dynamic> map = {};
    for (var st in statuses) {
      map[st.status] = st.startDate.toIso8601String();
    }
    return map;
  }

  /// Full fetch of all products in the order.
  Future<void> fetchAllProducts() async {
    if (orderProducts == null) return;
    for (var op in orderProducts!) {
      await op.fetchProduct();
    }
  }
}
