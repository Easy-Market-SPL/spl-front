import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_tracking_event.dart';
import 'order_tracking_state.dart';

class OrderStatusBloc extends Bloc<OrderStatusEvent, OrderStatusState> {
  OrderStatusBloc() : super(const OrderStatusState('En camino', 'La orden ha salido en camino')) {
    on<LoadOrderStatusEvent>((event, emit) {
      emit(const OrderStatusState('En camino', 'La orden ha salido en camino'));
    });

    on<ChangeOrderStatusEvent>((event, emit) {
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
      emit(OrderStatusState(event.newStatus, description)); // Actualizamos el estado
    });
  }
}