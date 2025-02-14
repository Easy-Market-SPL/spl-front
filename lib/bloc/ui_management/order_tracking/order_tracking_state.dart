import 'package:equatable/equatable.dart';

class OrderStatusState extends Equatable {
  final String currentStatus;
  final String description;

  const OrderStatusState(this.currentStatus, this.description);

  @override
  List<Object> get props => [currentStatus, description];
}