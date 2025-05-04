import 'dart:convert';

import '../helpers/ui_models/credit_card/address_payment_model.dart';

class PaymentMethodCard {
  final int? id;
  final String? cardNumber;
  final String? email;
  final String? cvv;
  final String? phone;
  final String? expiryDate;
  final String? cardHolderName;
  final AddressPaymentModel address;

  PaymentMethodCard({
    this.id,
    this.cardNumber,
    this.email,
    this.cvv,
    this.phone,
    this.expiryDate,
    this.cardHolderName,
    required this.address,
  });

  /// ----------- copyWith -----------
  PaymentMethodCard copyWith({
    int? id,
    String? cardNumber,
    String? email,
    String? phone,
    String? cvv,
    String? expiryDate,
    String? cardHolderName,
    AddressPaymentModel? address,
  }) {
    return PaymentMethodCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      email: email ?? this.email,
      cvv: cvv ?? this.cvv,
      phone: phone ?? this.phone,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      address: address ?? this.address,
    );
  }

  /// ----------- String ⇆ JSON helpers -----------
  factory PaymentMethodCard.fromRawJson(String str) =>
      PaymentMethodCard.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  /// ----------- Map ⇆ Model -----------
  factory PaymentMethodCard.fromJson(Map<String, dynamic> json) {
    return PaymentMethodCard(
      id: json['id'] as int?,
      cardNumber: json['cardNumber'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      expiryDate: json['expiryDate'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      cvv:
          '777', // AS THE CVV IS NOT SENT FROM THE BACKEND, WE PUT A DEFAULT VALUE (TEST STRIPE)
      address: AddressPaymentModel(
        city: json['city'] as String? ?? '',
        country: json['country'] as String? ?? '',
        line1: json['firstLine'] as String? ?? '',
        line2: json['secondLine'] as String? ?? '',
        state: json['stateName'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardNumber': cardNumber,
        'email': email,
        'phone': phone,
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
        'city': address.city,
        'country': address.country,
        'firstLine': address.line1,
        'secondLine': address.line2,
        'stateName': address.state,
        'postalCode': address.postalCode,
      };

  /// ----------- List helper -----------
  static List<PaymentMethodCard> fromJsonList(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    return data
        .map((item) => PaymentMethodCard.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
