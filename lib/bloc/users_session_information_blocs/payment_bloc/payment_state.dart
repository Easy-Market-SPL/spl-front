part of 'payment_bloc.dart';

class PaymentState extends Equatable {
  final List<PaymentMethodCard> cards;

  const PaymentState({
    this.cards = const [],
  });

  PaymentState copyWith({
    required List<PaymentMethodCard> cards,
  }) {
    return PaymentState(
      cards: cards,
    );
  }

  @override
  List<Object> get props => [cards];
}
