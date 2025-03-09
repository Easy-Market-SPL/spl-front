part of 'payment_bloc.dart';

@immutable
abstract class PaymentEvent {}

class OnSelectCard extends PaymentEvent {
  final PaymentCardModel card;

  OnSelectCard(this.card);
}

class OnDeselectCard extends PaymentEvent {}
