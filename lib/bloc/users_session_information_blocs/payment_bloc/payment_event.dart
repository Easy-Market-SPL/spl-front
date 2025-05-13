part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class AddCardEvent extends PaymentEvent {
  final PaymentMethodCard card;

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

class LoadPaymentMethodsEvent extends PaymentEvent {
  final String userId;
  const LoadPaymentMethodsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
