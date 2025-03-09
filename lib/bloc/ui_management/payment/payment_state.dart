part of 'payment_bloc.dart';

@immutable
class PaymentState {
  final double paymentAmount;
  final String currency;
  final bool activeCard;
  final PaymentCardModel? card;

  String get paymentAmountString => (paymentAmount * 100).floor().toString();

  const PaymentState(
      {this.paymentAmount = 1.0,
      this.currency = 'USD',
      this.activeCard = false,
      this.card});

  PaymentState copyWith({
    double? paymentAmount,
    String? currency,
    bool? activeCard,
    PaymentCardModel? card,
  }) {
    return PaymentState(
      paymentAmount: paymentAmount ?? this.paymentAmount,
      currency: currency ?? this.currency,
      activeCard: activeCard ?? this.activeCard,
      card: card ?? this.card,
    );
  }
}
