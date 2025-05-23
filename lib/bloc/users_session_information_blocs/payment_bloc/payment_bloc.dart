import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/users_models/payment_method.dart';
import '../../../services/api_services/user_service/user_service.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc()
      : super(PaymentState(
          cards: [],
        )) {
    on<AddCardEvent>((event, emit) {
      final List<PaymentMethodCard> newCards = List.from(state.cards)
        ..add(event.card);
      emit(state.copyWith(cards: newCards));
    });

    on<DeleteCardEvent>((event, emit) {
      final List<PaymentMethodCard> newCards = List.from(state.cards)
        ..removeAt(event.index);
      emit(state.copyWith(cards: newCards));
    });

    on<LoadPaymentMethodsEvent>((event, emit) async {
      try {
        final cards = await UserService.getUserPaymentMethods(event.userId);
        if (cards == null || cards.isEmpty) {
          emit(state.copyWith(cards: []));
        } else {
          emit(state.copyWith(cards: cards));
        }
      } catch (e) {
        emit(state.copyWith(cards: []));
      }
    });
  }
}
