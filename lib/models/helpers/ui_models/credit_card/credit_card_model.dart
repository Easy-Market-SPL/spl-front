import 'address_payment_model.dart';

class PaymentCardModel {
  final String cardNumber;
  final String cvv;
  final String expiryDate;
  final String cardHolderName;
  final String email;
  final String phone;
  final AddressPaymentModel addressPayment;

  PaymentCardModel({
    required this.cardNumber,
    required this.cvv,
    required this.email,
    required this.phone,
    required this.expiryDate,
    required this.cardHolderName,
    required this.addressPayment,
  });
}
