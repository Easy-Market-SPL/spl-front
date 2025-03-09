class PaymentCardModel {
  final String cardNumberHidden;
  final String cardNumber;
  final String brand;
  final String cvv;
  final String expiracyDate;
  final String cardHolderName;
  final String email;

  PaymentCardModel(
      {required this.cardNumberHidden,
      required this.cardNumber,
      required this.brand,
      required this.cvv,
      required this.email,
      required this.expiracyDate,
      required this.cardHolderName});
}
