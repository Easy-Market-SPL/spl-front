import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spl_front/models/ui/credit_card/credit_card_model.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentState()) {
    on<OnSelectCard>((event, emit) {
      emit(state.copyWith(card: event.card, activeCard: true));
    });

    on<OnDeselectCard>((event, emit) {
      emit(state.copyWith(activeCard: false));
    });
  }
}
