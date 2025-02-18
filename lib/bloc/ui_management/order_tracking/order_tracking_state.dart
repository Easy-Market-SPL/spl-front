import 'package:equatable/equatable.dart';

abstract class OrderStatusState extends Equatable {
  const OrderStatusState();

  @override
  List<Object> get props => [];
}

class OrderStatusLoading extends OrderStatusState {}

class OrderStatusLoaded extends OrderStatusState {
  final String currentStatus;
  final String description;
  final String selectedStatus;

  const OrderStatusLoaded(this.currentStatus, this.description, this.selectedStatus);

  @override
  List<Object> get props => [currentStatus, description, selectedStatus];
}