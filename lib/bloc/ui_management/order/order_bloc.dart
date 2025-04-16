import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/order_models/order_model.dart';
import '../../../services/api/order_service.dart';
import 'order_event.dart';
import 'order_state.dart';

/// - Loading orders for customer or admin/delivery roles
/// - Filtering, searching
/// - Cart-like logic for customer (add/update product, create order if needed)
/// - Changing status (confirm, prepare, onTheWay, delivered)
/// - Updating debt, removing product, deleting order, etc.

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(OrdersInitial()) {
    // Loading
    on<LoadOrdersEvent>(_onLoadOrders);
    on<LoadSingleOrderEvent>(_onLoadSingleOrder);

    // Filtering & searching
    on<FilterOrdersEvent>(_onFilterOrders);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<ApplyAdditionalFiltersEvent>(_onApplyAdditionalFilters);
    on<ClearAdditionalFiltersEvent>(_onClearAdditionalFilters);
    on<SetDateRangeEvent>(_onSetDateRange);
    on<ClearDateRangeEvent>(_onClearDateRange);

    // Updates / cart / status changes
    on<UpdateOrderAddressEvent>(_onUpdateOrderAddress);
    on<ConfirmOrderEvent>(_onConfirmOrder);
    on<PrepareOrderEvent>(_onPrepareOrder);
    on<OnTheWayDomiciliaryOrderEvent>(_onOnTheWayDomiciliary);
    on<OnTheWayTransportOrderEvent>(_onOnTheWayTransport);
    on<DeliveredOrderEvent>(_onDeliveredOrder);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<UpdateDebtEvent>(_onUpdateDebt);

    // Cart-like events
    on<AddProductToOrderEvent>(_onAddProduct);
    on<RemoveProductFromOrderEvent>(_onRemoveProduct);
    on<ClearCartEvent>(_onClearCart);
  }

  //
  // 1) Loading orders
  //
  Future<void> _onLoadOrders(
      LoadOrdersEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());

    final (orderList, error) = (event.userRole == 'customer')
        ? await OrderService.getOrdersByUser(event.userId)
        : await OrderService.getAllOrders();

    if (error != null) {
      emit(OrdersError(error));
      return;
    }

    final safeOrders = orderList ?? [];

    for (var order in safeOrders) {
      await order.fetchAllProducts();
    }

    OrderModel? currentCartOrder;
    if (event.userRole == 'customer') {
      currentCartOrder = safeOrders.firstWhere(
        (order) =>
            order.idUser == event.userId &&
            (order.orderStatuses?.isEmpty ?? true),
        orElse: () => OrderModel(idUser: event.userId),
      );

      // If currentCartOrder is null or has no ID, create a new order
      if (currentCartOrder.id == null) {
        final (newOrder, createError) = await OrderService.createOrder(
          idUser: event.userId,
          address: '',
        );
        if (createError != null) {
          emit(OrdersError(createError));
          return;
        }
        currentCartOrder = newOrder ?? OrderModel();
      }
    }

    emit(OrdersLoaded(
      allOrders: safeOrders,
      filteredOrders: safeOrders,
      selectedFilters: [],
      additionalFilters: [],
      dateRange: null,
      currentCartOrder: currentCartOrder,
      errorMessage: null,
    ));
  }

  //
  // 2) Load a single order
  //
  Future<void> _onLoadSingleOrder(
    LoadSingleOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (order, error) = await OrderService.getOrderById(event.orderId);
    if (error != null) {
      emit(OrdersError(error));
      return;
    }
    if (order == null) {
      emit(const OrdersError("No se encontró la orden solicitada."));
      return;
    }
    // We can display just this one order in allOrders
    emit(OrdersLoaded(
      allOrders: [order],
      filteredOrders: [order],
      selectedFilters: [],
      additionalFilters: [],
      dateRange: null,
      currentCartOrder: null,
    ));
  }

  //
  // 3) Filter orders by status
  //
  void _onFilterOrders(FilterOrdersEvent event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final current = state as OrdersLoaded;
      List<String> updatedFilters = List.from(current.selectedFilters);

      // Toggle the status in the filter list
      if (updatedFilters.contains(event.status)) {
        updatedFilters.remove(event.status);
      } else {
        updatedFilters.add(event.status);
      }

      // Reapply filters
      final newFiltered = _applyFilters(
        orders: current.allOrders,
        selectedFilters: updatedFilters,
        additionalFilters: current.additionalFilters,
        dateRange: current.dateRange,
      );

      emit(current.copyWith(
        filteredOrders: newFiltered,
        selectedFilters: updatedFilters,
      ));
    }
  }

  //
  // 4) Search in the currently filtered orders
  //
  void _onSearchOrders(SearchOrdersEvent event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final current = state as OrdersLoaded;
      final query = event.query.toLowerCase();
      final searched = current.filteredOrders.where((ord) {
        // Example: searching in idUser, address, or creationDate
        final user = ord.idUser?.toLowerCase() ?? '';
        final address = ord.address?.toLowerCase() ?? '';
        final dateStr = ord.creationDate?.toIso8601String() ?? '';
        return user.contains(query) ||
            address.contains(query) ||
            dateStr.contains(query);
      }).toList();

      emit(current.copyWith(filteredOrders: searched));
    }
  }

  //
  // 5) Apply additional filters (like "mostRecent", "leastRecent", "mostItems", etc.)
  //
  void _onApplyAdditionalFilters(
    ApplyAdditionalFiltersEvent event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final current = state as OrdersLoaded;
      final newFiltered = _applyFilters(
        orders: current.allOrders,
        selectedFilters: current.selectedFilters,
        additionalFilters: event.filters,
        dateRange: current.dateRange,
      );
      emit(current.copyWith(
        filteredOrders: newFiltered,
        additionalFilters: event.filters,
      ));
    }
  }

  //
  // 6) Clear additional filters
  //
  void _onClearAdditionalFilters(
    ClearAdditionalFiltersEvent event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final current = state as OrdersLoaded;
      final newFiltered = _applyFilters(
        orders: current.allOrders,
        selectedFilters: current.selectedFilters,
        additionalFilters: [],
        dateRange: current.dateRange,
      );
      emit(current.copyWith(
        filteredOrders: newFiltered,
        additionalFilters: [],
      ));
    }
  }

  //
  // 7) Set a date range
  //
  void _onSetDateRange(SetDateRangeEvent event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final current = state as OrdersLoaded;
      final newFiltered = _applyFilters(
        orders: current.allOrders,
        selectedFilters: current.selectedFilters,
        additionalFilters: current.additionalFilters,
        dateRange: event.dateRange,
      );
      emit(current.copyWith(
        filteredOrders: newFiltered,
        dateRange: event.dateRange,
      ));
    }
  }

  //
  // 8) Clear a date range
  //
  void _onClearDateRange(
    ClearDateRangeEvent event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final current = state as OrdersLoaded;
      final newFiltered = _applyFilters(
        orders: current.allOrders,
        selectedFilters: current.selectedFilters,
        additionalFilters: current.additionalFilters,
        dateRange: null,
      );
      emit(current.copyWith(filteredOrders: newFiltered, dateRange: null));
    }
  }

  //
  // 9) Update order address
  //
  Future<void> _onUpdateOrderAddress(
    UpdateOrderAddressEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (updated, err) = await OrderService.updateOrder(
      orderId: event.orderId,
      address: event.address,
    );
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (updated == null) {
      emit(const OrdersError("No se pudo actualizar la dirección."));
      return;
    }
    // Reload or just patch in the list:
    add(LoadSingleOrderEvent(event.orderId));
  }

  //
  // 10) Confirm order
  //
  Future<void> _onConfirmOrder(
    ConfirmOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (updated, err) = await OrderService.confirmOrder(
      orderId: event.orderId,
      shippingCost: event.shippingCost,
      paymentAmount: event.paymentAmount,
    );
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (updated == null) {
      emit(const OrdersError("No se pudo confirmar la orden."));
      return;
    }
    add(LoadSingleOrderEvent(event.orderId));
  }

  //
  // 11) Prepare order
  //
  Future<void> _onPrepareOrder(
    PrepareOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (updated, err) = await OrderService.prepareOrder(event.orderId);
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (updated == null) {
      emit(const OrdersError("No se pudo cambiar el estado a 'preparing'."));
      return;
    }
    add(LoadSingleOrderEvent(event.orderId));
  }

  //
  // 12) On the way with domiciliary
  //
  Future<void> _onOnTheWayDomiciliary(
    OnTheWayDomiciliaryOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (updated, err) = await OrderService.onTheWayDomiciliaryOrder(
      orderId: event.orderId,
      idDomiciliary: event.idDomiciliary,
      initialLatitude: event.initialLatitude,
      initialLongitude: event.initialLongitude,
    );
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (updated == null) {
      emit(const OrdersError("No se pudo poner la orden 'on the way'."));
      return;
    }
    add(LoadSingleOrderEvent(event.orderId));
  }

  //
  // 13) On the way with transport
  //
  Future<void> _onOnTheWayTransport(
    OnTheWayTransportOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (updated, err) = await OrderService.onTheWayTransportCompanyOrder(
      orderId: event.orderId,
      transportCompany: event.transportCompany,
      shippingGuide: event.shippingGuide,
    );
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (updated == null) {
      emit(const OrdersError(
          "No se pudo poner la orden 'on the way' con empresa de transporte."));
      return;
    }
    add(LoadSingleOrderEvent(event.orderId));
  }

  //
  // 14) Delivered order
  //
  Future<void> _onDeliveredOrder(
    DeliveredOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (updated, err) = await OrderService.deliveredOrder(event.orderId);
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (updated == null) {
      emit(const OrdersError("No se pudo marcar la orden como 'delivered'."));
      return;
    }
    add(LoadSingleOrderEvent(event.orderId));
  }

  //
  // 15) Delete order
  //
  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (success, err) = await OrderService.deleteOrder(event.orderId);
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (!success) {
      emit(const OrdersError("No se pudo eliminar la orden."));
      return;
    }
    // After deletion we can re-load the list or simply revert to initial
    emit(OrdersInitial());
  }

  //
  // 16) Update debt
  //
  Future<void> _onUpdateDebt(
    UpdateDebtEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final (updated, err) = await OrderService.updateDebt(
      orderId: event.orderId,
      paymentAmount: event.paymentAmount,
    );
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (updated == null) {
      emit(const OrdersError("No se pudo actualizar la deuda."));
      return;
    }
    add(LoadSingleOrderEvent(event.orderId));
  }

  //
  // 17) Add or update a product in the order (cart approach if user is costumer).
  // If there's no currentCartOrder, we create it with the given userId/address.
  //
  Future<void> _onAddProduct(
    AddProductToOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    OrderModel? cartOrder;
    List<OrderModel> oldAllOrders = [];
    List<OrderModel> oldFiltered = [];
    List<String> oldFilters = [];
    List<String> oldAdditional = [];
    DateTimeRange? oldRange;

    if (state is OrdersLoaded) {
      final s = state as OrdersLoaded;
      cartOrder = s.currentCartOrder;
      oldAllOrders = s.allOrders;
      oldFiltered = s.filteredOrders;
      oldFilters = s.selectedFilters;
      oldAdditional = s.additionalFilters;
      oldRange = s.dateRange;
    }

    emit(OrdersLoading());

    try {
      if (cartOrder == null || cartOrder.id == null) {
        final (newOrder, createError) = await OrderService.createOrder(
          idUser: event.userId,
          address: event.address,
        );
        if (createError != null) {
          emit(OrdersError(createError));
          return;
        }
        if (newOrder == null) {
          emit(const OrdersError("No se pudo crear la orden para el carrito."));
          return;
        }
        cartOrder = newOrder;
      }

      final orderId = cartOrder.id;
      if (orderId == null) {
        emit(const OrdersError(
            "El ID de la orden es nulo, no se puede agregar producto."));
        return;
      }

      final (updatedOrder, error) = await OrderService.addProductToOrder(
        orderId: orderId,
        productCode: event.productCode,
        quantity: event.quantity,
      );

      if (error != null) {
        emit(OrdersError(error));
        return;
      }
      if (updatedOrder == null) {
        emit(const OrdersError("No se pudo actualizar la orden con producto."));
        return;
      }

      await updatedOrder.fetchAllProducts();
      emit(OrdersLoaded(
        allOrders: oldAllOrders,
        filteredOrders: oldFiltered,
        selectedFilters: oldFilters,
        additionalFilters: oldAdditional,
        dateRange: oldRange,
        currentCartOrder: updatedOrder,
        errorMessage: null,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
      if (state is OrdersLoaded) {
        emit(state as OrdersLoaded);
      } else {
        emit(OrdersInitial());
      }
    }
  }

  //
  // 18) Remove a product from the order
  //
  Future<void> _onRemoveProduct(
    RemoveProductFromOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    OrderModel? cartOrder;
    List<OrderModel> oldAllOrders = [];
    List<OrderModel> oldFiltered = [];
    List<String> oldFilters = [];
    List<String> oldAdditional = [];
    DateTimeRange? oldRange;

    if (state is! OrdersLoaded) {
      // No debería pasar si estás en la página del carrito, pero por si acaso
      emit(const OrdersError("Estado inválido para remover producto."));
      return;
    }

    // Guarda estado actual
    final current = state as OrdersLoaded;
    cartOrder = current.currentCartOrder;
    oldAllOrders = current.allOrders;
    oldFiltered = current.filteredOrders;
    oldFilters = current.selectedFilters;
    oldAdditional = current.additionalFilters;
    oldRange = current.dateRange;

    // Verifica si hay carrito
    if (cartOrder == null || cartOrder.id == null) {
      if (event.orderId == null) {
        emit(const OrdersError(
            "No hay una orden activa o ID de orden válido para remover producto."));
        return;
      }
    }

    final orderIdToRemoveFrom = event.orderId;
    if (orderIdToRemoveFrom == null) {
      emit(const OrdersError(
          "ID de orden no especificado para remover producto."));
      return;
    }

    emit(OrdersLoading());

    try {
      final (success, err) = await OrderService.deleteProductFromOrder(
        orderId: orderIdToRemoveFrom,
        productCode: event.productCode,
      );

      if (err != null) {
        emit(OrdersError(err));
        emit(current);
        return;
      }
      if (!success) {
        emit(const OrdersError("No se pudo eliminar el producto de la orden."));
        emit(current);
        return;
      }

      final (refetchedOrder, refetchErr) =
          await OrderService.getOrderById(orderIdToRemoveFrom);

      if (refetchErr != null) {
        emit(OrdersError(refetchErr));
        emit(current);
        return;
      }

      if (refetchedOrder == null) {
        emit(current.copyWith(currentCartOrder: null));
        return;
      }

      await refetchedOrder.fetchAllProducts();

      emit(OrdersLoaded(
        allOrders: oldAllOrders,
        filteredOrders: oldFiltered,
        selectedFilters: oldFilters,
        additionalFilters: oldAdditional,
        dateRange: oldRange,
        currentCartOrder: refetchedOrder,
        errorMessage: null,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(current);
    }
  }

  //
  // 19) Clear or reset the cart
  //
  Future<void> _onClearCart(
      ClearCartEvent event, Emitter<OrdersState> emit) async {
    // Optionally, if you want to delete the order from server or just reset local
    if (state is OrdersLoaded) {
      final current = (state as OrdersLoaded);
      final cartOrder = current.currentCartOrder;
      if (cartOrder != null && cartOrder.id != null) {
        await OrderService.deleteOrder(cartOrder.id!);
      }
      // Now revert to no cart
      emit(current.copyWith(currentCartOrder: null));
    } else {
      emit(OrdersInitial());
    }
  }

  //
  // Private method to apply filters (status, date range, etc.)
  // If your OrderModel doesn't store a direct 'status' or 'items', adapt accordingly.
  //
  List<OrderModel> _applyFilters({
    required List<OrderModel> orders,
    required List<String> selectedFilters,
    required List<String> additionalFilters,
    required DateTimeRange? dateRange,
  }) {
    // Filter by "status" if you have a direct property or the last status in orderStatuses
    List<OrderModel> filtered = orders;
    if (selectedFilters.isNotEmpty) {
      filtered = filtered.where((o) {
        // Suppose o has a single "currentStatus" or check orderStatuses last entry
        // For demonstration, we'll skip. In real code:
        // return selectedFilters.contains(o.currentStatus);
        return false;
      }).toList();
    }

    // Additional filters example
    for (String flt in additionalFilters) {
      switch (flt) {
        case "mostRecent":
          // Sort descending by creationDate
          filtered.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
          break;
        case "leastRecent":
          filtered.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));
          break;
        case "mostItems":
          // If you had a total item count, you'd do something like:
          // filtered.sort((a, b) => b.totalItems.compareTo(a.totalItems));
          break;
      }
    }

    // Filter by date range
    if (dateRange != null) {
      filtered = filtered.where((o) {
        final d = o.creationDate;
        if (d == null) return false;
        return _isBetweenOrSameDay(d, dateRange.start, dateRange.end);
      }).toList();
    }

    return filtered;
  }

  bool _isBetweenOrSameDay(DateTime check, DateTime start, DateTime end) {
    // Simple check ignoring time, adapt as needed
    final c = DateTime(check.year, check.month, check.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return (c.isAtSameMomentAs(s) || c.isAfter(s)) &&
        (c.isAtSameMomentAs(e) || c.isBefore(e));
  }
}
