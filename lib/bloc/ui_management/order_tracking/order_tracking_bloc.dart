import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_tracking_event.dart';
import 'order_tracking_state.dart';

class OrderStatusBloc extends Bloc<OrderStatusEvent, OrderStatusState> {
  OrderStatusBloc() : super(OrderStatusLoading()) {
    on<LoadOrderStatusEvent>((event, emit) async {
      // TODO: Implement order load from backend and remove simulated order 
      emit(OrderStatusLoading());
      //await Future.delayed(Duration(seconds: 2));
      emit(OrderStatusLoaded("En camino", "La orden ha salido en camino", "En camino"));
    });

    on<ChangeOrderStatusEvent>((event, emit) {
      // TODO: Implement order status change in backend
      String description;
      switch (event.newStatus) {
        case 'Orden confirmada':
          description = 'La orden ha sido confirmada';
          break;
        case 'Preparando la orden':
          description = 'La orden está siendo preparada';
          break;
        case 'En camino':
          description = 'La orden ha salido en camino';
          break;
        case 'Entregada':
          description = 'La orden ha sido entregada';
          break;
        default:
          description = '';
      }
      emit(OrderStatusLoaded(event.newStatus, description, event.newStatus));
    });

    on<ChangeSelectedStatusEvent>((event, emit) {
      if (state is OrderStatusLoaded) {
        final currentState = state as OrderStatusLoaded;
        emit(OrderStatusLoaded(currentState.currentStatus, currentState.description, event.selectedStatus));
      }
    });
  }
}