import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'orders_list_bloc.dart';

abstract class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object> get props => [];
}

class OrderListLoading extends OrderListState {}

class OrderListLoaded extends OrderListState {
  final List<Order> orders;
  final List<Order> filteredOrders;
  final List<String> selectedFilters;
  final List<String> additionalFilters;
  final DateTimeRange? selectedDateRange;

  const OrderListLoaded(this.orders, this.filteredOrders, this.selectedFilters, this.additionalFilters, {this.selectedDateRange});

  @override
  List<Object> get props => [orders, filteredOrders, selectedFilters, additionalFilters, selectedDateRange ?? DateTimeRange(start: DateTime(0), end: DateTime(0))];
}

class OrderListError extends OrderListState {
  final String message;

  const OrderListError(this.message);

  @override
  List<Object> get props => [message];
}