import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/order_models/order_model.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];

  // Getter for currentCartOrder
  OrderModel? get currentCartOrder {
    if (this is OrdersLoaded) {
      return (this as OrdersLoaded).currentCartOrder;
    }
    return null;
  }
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> allOrders;
  final List<OrderModel> filteredOrders;
  final List<String> selectedFilters;
  final List<String> additionalFilters;
  final DateTimeRange? dateRange;

  // Store the current cart order if needed
  @override
  final OrderModel? currentCartOrder;

  final String? errorMessage;
  final bool isLoading;

  const OrdersLoaded(
      {required this.allOrders,
      required this.filteredOrders,
      required this.selectedFilters,
      required this.additionalFilters,
      this.dateRange,
      this.currentCartOrder,
      this.errorMessage,
      this.isLoading = false});

  @override
  List<Object?> get props => [
        allOrders,
        filteredOrders,
        selectedFilters,
        additionalFilters,
        dateRange,
        currentCartOrder,
        errorMessage,
      ];

  OrdersLoaded copyWith({
    List<OrderModel>? allOrders,
    List<OrderModel>? filteredOrders,
    List<String>? selectedFilters,
    List<String>? additionalFilters,
    DateTimeRange? dateRange,
    OrderModel? currentCartOrder,
    String? errorMessage,
    bool? isLoading,
    bool forceCartNull = false,
  }) {
    return OrdersLoaded(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      additionalFilters: additionalFilters ?? this.additionalFilters,
      dateRange: dateRange ?? this.dateRange,
      currentCartOrder:
          forceCartNull ? null : (currentCartOrder ?? this.currentCartOrder),
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
