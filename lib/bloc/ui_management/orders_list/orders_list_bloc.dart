import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_event.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_state.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:uuid/uuid.dart';

class Order {
  final Uuid id = Uuid();
  final String clientName;
  final String status;
  final DateTime date;
  final int items;
  final LatLng? location;
  final String? address;

  // TODO: Fetch the address and location from the database
  Order({
    required this.clientName,
    required this.status,
    DateTime? date,
    this.location,
    this.address,
    int? items,
  })  : date = date ?? DateTime.now(),
        items = items ?? 0;

  Order copyWith({
    String? clientName,
    String? status,
    DateTime? date,
    int? items,
    LatLng? location,
  }) {
    return Order(
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      date: date ?? this.date,
      items: items ?? this.items,
      location: location ?? this.location,
    );
  }
}

class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  // TODO: Do the fetch of the information with real data (Specially location and address from the database)
  final List<Order> orders = [
    Order(
        clientName: "Ana María",
        status: OrderStrings.statusConfirmed,
        date: DateTime.now().subtract(Duration(days: 3)),
        location: LatLng(4.6408641032, -74.073166374),
        address: 'Calle 22A #52-79',
        items: 7),
    Order(
        clientName: "Juan Peláez",
        status: OrderStrings.statusOnTheWay,
        date: DateTime.now().subtract(Duration(days: 1)),
        location: LatLng(4.6474, -74.1019),
        address: 'Calle 22A #52-79',
        items: 5),
    Order(
        clientName: "Carlos López",
        status: OrderStrings.statusPreparing,
        date: DateTime.now().subtract(Duration(days: 4)),
        location: LatLng(4.628721, -74.0636),
        address: 'Calle 22A #52-79',
        items: 2),
    Order(
        clientName: "Camilo Mora",
        status: OrderStrings.statusPreparing,
        date: DateTime.now().subtract(Duration(days: 2)),
        location: LatLng(4.7021, -74.041),
        address: 'Calle 22A #52-79',
        items: 7),
    Order(
        clientName: "Leonardo Castro",
        status: OrderStrings.statusPreparing,
        date: DateTime.now().subtract(Duration(days: 1)),
        location: LatLng(4.6015, -74.0661),
        address: 'Calle 22A #52-79',
        items: 4),
    Order(
        clientName: "Juan Ramirez",
        status: OrderStrings.statusPreparing,
        date: DateTime.now().subtract(Duration(days: 0)),
        location: LatLng(4.63841, -74.10179),
        address: 'Calle 22A #52-79',
        items: 3),
    Order(
        clientName: "Cristian Camelo",
        status: OrderStrings.statusOnTheWay,
        date: DateTime.now().subtract(Duration(days: 2)),
        location: LatLng(4.6425, -74.1255),
        address: 'Calle 22A #52-79',
        items: 3),
    Order(
        clientName: "María Pérez",
        status: OrderStrings.statusDelivered,
        date: DateTime.now().subtract(Duration(days: 5)),
        location: LatLng(4.6235, -74.1358),
        address: 'Calle 22A #52-79',
        items: 10),
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
    on<ClearAdditionalFiltersDeliveryEvent>(_onClearAdditionalFiltersDelivery);
  }

  void _onLoadOrders(
      LoadOrdersEvent event, Emitter<OrderListState> emit) async {
    // TODO: Implement real data load
    try {
      await Future.delayed(Duration(seconds: 2));
      final filteredOrders = applyFilters(
          orders, selectedFilters, additionalFilters, selectedDateRange);
      emit(OrderListLoaded(
          orders, filteredOrders, selectedFilters, additionalFilters,
          selectedDateRange: selectedDateRange));
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

      final filteredOrders = applyFilters(loadedState.orders, selectedFilters,
          loadedState.additionalFilters, selectedDateRange);
      emit(OrderListLoaded(loadedState.orders, filteredOrders, selectedFilters,
          loadedState.additionalFilters,
          selectedDateRange: selectedDateRange));
    }
  }

  void _onSearchOrders(SearchOrdersEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;
      final query = event.query.toLowerCase();

      final filteredOrders = loadedState.orders.where((order) {
        return order.clientName.toLowerCase().contains(query) ||
            DateHelper.isDateMatchingQuery(order.date, query);
      }).toList();

      emit(OrderListLoaded(loadedState.orders, filteredOrders,
          loadedState.selectedFilters, loadedState.additionalFilters,
          selectedDateRange: selectedDateRange));
    }
  }

  void _onApplyAdditionalFilters(
      ApplyAdditionalFiltersEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;
      final filters = event.filters;

      final filteredOrders = applyFilters(loadedState.orders,
          loadedState.selectedFilters, filters, selectedDateRange);
      emit(OrderListLoaded(loadedState.orders, filteredOrders,
          loadedState.selectedFilters, filters,
          selectedDateRange: selectedDateRange));
    }
  }

  void _onClearAdditionalFilters(
      ClearAdditionalFiltersEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;
      emit(OrderListLoaded(loadedState.orders, loadedState.orders,
          loadedState.selectedFilters, [],
          selectedDateRange: selectedDateRange));
    }
  }

  void _onClearAdditionalFiltersDelivery(
      ClearAdditionalFiltersDeliveryEvent event, Emitter<OrderListState> emit) {
    if (state is OrderListLoaded) {
      final loadedState = state as OrderListLoaded;

      // Emitimos el estado cargado con los filtros aplicados
      emit(OrderListLoaded(
        loadedState.orders.where((order) {
          return order.status == OrderStrings.statusPreparing;
        }).toList(),
        loadedState.orders.where((order) {
          return order.status == OrderStrings.statusPreparing;
        }).toList(),
        loadedState.selectedFilters,
        [],
        selectedDateRange: loadedState.selectedDateRange,
      ));
    }
  }

  List<Order> applyFilters(List<Order> orders, List<String> selectedFilters,
      List<String> additionalFilters, DateTimeRange? dateRange) {
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
        return DateHelper.dateIsBetweenAndSameDay(order.date, dateRange);
      }).toList();
    }

    return filteredOrders;
  }
}
