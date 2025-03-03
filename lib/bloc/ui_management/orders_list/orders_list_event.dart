import 'package:equatable/equatable.dart';

abstract class OrderListEvent extends Equatable {
  const OrderListEvent();

  @override
  List<Object> get props => [];
}

class LoadOrdersEvent extends OrderListEvent {}

class FilterOrdersEvent extends OrderListEvent {
  final String status;

  const FilterOrdersEvent(this.status);

  @override
  List<Object> get props => [status];
}

class SearchOrdersEvent extends OrderListEvent {
  final String query;

  const SearchOrdersEvent(this.query);
}

class UpdateDeliveryInformationOrderEvent extends OrderListEvent {
  final String orderId;
  final String deliveryName;
  const UpdateDeliveryInformationOrderEvent(this.orderId, this.deliveryName);
}

class ApplyAdditionalFiltersEvent extends OrderListEvent {
  final List<String> filters;

  const ApplyAdditionalFiltersEvent(this.filters);
}

class ClearAdditionalFiltersEvent extends OrderListEvent {}

class ClearAdditionalFiltersDeliveryEvent extends OrderListEvent {}
