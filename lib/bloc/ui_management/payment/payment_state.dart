part of 'payment_bloc.dart';

class PaymentState extends Equatable {
  final List<PaymentCardModel> cards;

  const PaymentState({
    this.cards = const [],
  });

  PaymentState copyWith({
    List<PaymentCardModel>? cards,
  }) {
    return PaymentState(
      cards: cards ?? this.cards,
    );
  }

  @override
  List<Object> get props => [cards];
}
