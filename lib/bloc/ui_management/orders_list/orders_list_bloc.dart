import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_event.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_state.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class Order {
  final String clientName;
  final String status;
  final DateTime date;
  final int items;

  Order({required this.clientName, required this.status, DateTime? date, int? items})
      : date = date ?? DateTime.now(),
        items = items ?? 0;
}

class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final List<Order> orders = [
    Order(clientName: "Ana María", status: OrderStrings.statusConfirmed, date: DateTime.now().subtract(Duration(days: 3)), items: 7),
    Order(clientName: "Juan Peláez", status: OrderStrings.statusOnTheWay, date: DateTime.now().subtract(Duration(days: 1)), items: 5),
    Order(clientName: "Carlos López", status: OrderStrings.statusPreparing, date: DateTime.now().subtract(Duration(days: 4)), items: 2),
    Order(clientName: "Cristian Camelo", status: OrderStrings.statusOnTheWay, date: DateTime.now().subtract(Duration(days: 2)), items: 3),
    Order(clientName: "María Pérez", status: OrderStrings.statusDelivered, date: DateTime.now().subtract(Duration(days: 5)), items: 10),
  ];

  List<String> selectedFilters = [];
  List<String> additionalFilters = [OrderStrings.mostRecent];
  DateTimeRange? selectedDateRange;

  OrderListBloc() : super(OrderListLoading()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<FilterOrdersEvent>(_onFilterOrders);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<ApplyAdditionalFiltersEvent>(_onApplyAdditionalFilters);
    on<ClearAdditionalFiltersEvent>(_onClearAdditionalFilters);
  }

  void _onLoadOrders(LoadOrdersEvent event, Emitter<OrderListState> emit) async {
    // TODO: Implement real data load
    try {
      await Future.delayed(Duration(seconds: 2));
      final filteredOrders = applyFilters(orders, selectedFilters, additionalFilters, selectedDateRange);
      emit(OrderListLoaded(orders, filteredOrders, selectedFilters, additionalFilters, selectedDateRange: selectedDateRange));
    } catch (e) {
      emit(OrderListError(e.toString()));
    }
  }

  void _onFilterOrders(FilterOrdersEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;
      List<String> selectedFilters = List.from(loadedState.selectedFilters);

      if (selectedFilters.contains(event.status)) {
        selectedFilters.remove(event.status);
      } else {
        selectedFilters.add(event.status);
      }

      final filteredOrders = applyFilters(loadedState.orders, selectedFilters, loadedState.additionalFilters, selectedDateRange);
      emit(OrderListLoaded(loadedState.orders, filteredOrders, selectedFilters, loadedState.additionalFilters, selectedDateRange: selectedDateRange));
    }
  }

  void _onSearchOrders(SearchOrdersEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;
      final query = event.query.toLowerCase();

      final filteredOrders = loadedState.orders.where((order) {
        return order.clientName.toLowerCase().contains(query);
      }).toList();

      emit(OrderListLoaded(loadedState.orders, filteredOrders, loadedState.selectedFilters, loadedState.additionalFilters, selectedDateRange: selectedDateRange));
    }
  }

  void _onApplyAdditionalFilters(ApplyAdditionalFiltersEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;
      final filters = event.filters;

      final filteredOrders = applyFilters(loadedState.orders, loadedState.selectedFilters, filters, selectedDateRange);
      emit(OrderListLoaded(loadedState.orders, filteredOrders, loadedState.selectedFilters, filters, selectedDateRange: selectedDateRange));
    }
  }

  void _onClearAdditionalFilters(ClearAdditionalFiltersEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;
      emit(OrderListLoaded(loadedState.orders, loadedState.orders, loadedState.selectedFilters, [], selectedDateRange: selectedDateRange));
    }
  }

  List<Order> applyFilters(List<Order> orders, List<String> selectedFilters, List<String> additionalFilters, DateTimeRange? dateRange) {
    List<Order> filteredOrders = orders;

    if (selectedFilters.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) {
        return selectedFilters.contains(order.status);
      }).toList();
    }

    if (additionalFilters.isNotEmpty) {
      for (String filter in additionalFilters) {
        if (filter == OrderStrings.mostRecent) {
          filteredOrders.sort((a, b) => b.date.compareTo(a.date));
        } else if (filter == OrderStrings.leastRecent) {
          filteredOrders.sort((a, b) => a.date.compareTo(b.date));
        } else if (filter == OrderStrings.mostItems) {
          filteredOrders.sort((a, b) => b.items.compareTo(a.items));
        }
      }
    }

    if (dateRange != null) {
      filteredOrders = filteredOrders.where((order) {
        return 
          (order.date.isAfter(dateRange.start) || DateUtils.isSameDay(order.date, dateRange.start)) && 
          (order.date.isBefore(dateRange.end) || DateUtils.isSameDay(order.date, dateRange.end));
      }).toList();
    }

    return filteredOrders;
  }
}