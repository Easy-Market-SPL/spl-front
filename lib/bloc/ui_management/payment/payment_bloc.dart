import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/ui/credit_card/credit_card_model.dart';

import '../../../models/ui/credit_card/address_payment_model.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc()
      : super(PaymentState(
          cards: [
            PaymentCardModel(
              cardNumber: '4242424242424242',
              cvv: '123',
              email: 'juanframireze@gmail.com',
              phone: '3219668133',
              expiryDate: '12/25',
              cardHolderName: 'Juan Ramirez',
              addressPayment: genericPaymentAddress(),
            ),
            PaymentCardModel(
              cardNumber: '5555555555554444',
              cvv: '852',
              email: 'pachoramirez13@gmail.com',
              phone: '3222472264',
              expiryDate: '12/25',
              cardHolderName: 'Luis Ramirez',
              addressPayment: genericPaymentAddress(),
            ),
          ],
        )) {
    on<AddCardEvent>((event, emit) {
      final List<PaymentCardModel> newCards = List.from(state.cards)
        ..add(event.card);
      emit(state.copyWith(cards: newCards));
    });

    on<DeleteCardEvent>((event, emit) {
      final List<PaymentCardModel> newCards = List.from(state.cards)
        ..removeAt(event.index);
      emit(state.copyWith(cards: newCards));
    });
  }
}
