part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class AddCardEvent extends PaymentEvent {
  final PaymentCardModel card;

  const AddCardEvent(this.card);

  @override
  List<Object> get props => [card];
}

class DeleteCardEvent extends PaymentEvent {
  final int index;

  const DeleteCardEvent(this.index);

  @override
  List<Object> get props => [index];
}
