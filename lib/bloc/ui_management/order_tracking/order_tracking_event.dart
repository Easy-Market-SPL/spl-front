import 'package:equatable/equatable.dart';

abstract class OrderStatusEvent extends Equatable {
  const OrderStatusEvent();

  @override
  List<Object> get props => [];
}

class LoadOrderStatusEvent extends OrderStatusEvent {}

class ChangeOrderStatusEvent extends OrderStatusEvent {
  final String newStatus;

  const ChangeOrderStatusEvent(this.newStatus);

  @override
  List<Object> get props => [newStatus];
}