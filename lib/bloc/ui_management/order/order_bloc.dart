import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

import '../../../models/order_models/order_model.dart';
import '../../../models/order_models/order_product.dart';
import '../../../services/api/order_service.dart';
import '../../../utils/ui/order_statuses.dart';
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
  //
  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final (orderList, error) = (event.userRole == 'customer')
          ? await OrderService.getOrdersByUser(event.userId)
          : await OrderService.getAllOrders();

      if (error != null) {
        emit(OrdersError(error));
        return;
      }

      final List<OrderModel> safeOrders = List.from(orderList ?? []);
      OrderModel? currentCartOrder;
      List<OrderModel> filtered = safeOrders;

      if (event.userRole == 'customer') {
        final cartIndex = safeOrders.indexWhere((order) =>
            order.idUser == event.userId && order.orderStatuses.isEmpty);

        if (cartIndex != -1) {
          currentCartOrder = safeOrders[cartIndex];
          await currentCartOrder.fetchAllProducts();
        } else {
          final (newOrder, createError) = await OrderService.createOrder(
            idUser: event.userId,
            address: 'Address Creating...',
          );
          if (createError != null || newOrder == null) {
            emit(OrdersError(createError ?? "Failed to create cart order"));
            return;
          }
          currentCartOrder = newOrder;
          safeOrders.add(newOrder);
        }
        filtered = safeOrders;
      } else if (event.userRole == 'delivery') {
        filtered = safeOrders.where((o) {
          final lastStatus = o.orderStatuses.isNotEmpty
              ? normalizeOnTheWay(o.orderStatuses.last.status)
              : '';
          return lastStatus == 'preparing' || o.idDomiciliary == event.userId;
        }).toList();
      }

      if (event.userRole != 'delivery') {
        filtered = filtered.where((o) => o.orderStatuses.isNotEmpty).toList();
      }

      if (event.userRole == 'delivery') {
        emit(OrdersLoaded(
          allOrders: filtered,
          filteredOrders: filtered,
          selectedFilters: [],
          additionalFilters: [],
          dateRange: null,
          currentCartOrder: currentCartOrder,
          isLoading: false,
        ));
      } else {
        emit(OrdersLoaded(
          allOrders: safeOrders,
          filteredOrders: filtered,
          selectedFilters: [],
          additionalFilters: [],
          dateRange: null,
          currentCartOrder: currentCartOrder,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  //
  // 2) Load a single order
  //
  Future<void> _onLoadSingleOrder(
    LoadSingleOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    // Only proceed if we already have a loaded list.
    if (state is! OrdersLoaded) return;

    final OrdersLoaded previous = state as OrdersLoaded;
    emit(previous.copyWith(isLoading: true)); // inline loader

    final (remoteOrder, err) = await OrderService.getOrderById(event.orderId);
    if (err != null) {
      emit(OrdersError(err));
      return;
    }
    if (remoteOrder == null) {
      emit(const OrdersError('Requested order was not found.'));
      return;
    }

    await remoteOrder.fetchAllProducts();

    // Replace or append the refreshed order inside the existing list
    final List<OrderModel> updatedAll = List.from(previous.allOrders);
    final int idx = updatedAll.indexWhere((o) => o.id == remoteOrder.id);
    if (idx != -1) {
      updatedAll[idx] = remoteOrder;
    } else {
      updatedAll.add(remoteOrder);
    }

    // Re‑apply filters & other user‑selected criteria
    final List<OrderModel> updatedFiltered = _applyFilters(
      orders: updatedAll,
      selectedFilters: previous.selectedFilters,
      additionalFilters: previous.additionalFilters,
      dateRange: previous.dateRange,
    );

    emit(
      previous.copyWith(
        allOrders: updatedAll,
        filteredOrders: updatedFiltered,
        isLoading: false,
      ),
    );
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
        dateRange: null,
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
      AddProductToOrderEvent event, Emitter<OrdersState> emit) async {
    // Only proceed if current state is Loaded
    if (state is! OrdersLoaded) return;
    final previousState = state as OrdersLoaded;

    // Indicate loading started within the loaded state
    emit(previousState.copyWith(isLoading: true));

    try {
      OrderModel? cartOrder = previousState.currentCartOrder;

      // Create order if it doesn't exist
      if (cartOrder == null || cartOrder.id == null) {
        final (newOrder, createError) = await OrderService.createOrder(
          idUser: event.userId,
          address: event.address, // Ensure address logic is correct
        );
        if (createError != null || newOrder == null) {
          emit(OrdersError(createError ?? "No se pudo crear la orden."));
          emit(previousState.copyWith(isLoading: false)); // Revert loading
          return;
        }
        cartOrder = newOrder;
      }

      final orderId = cartOrder.id;
      if (orderId == null) {
        // This case should ideally not be reached if creation logic above is sound
        emit(const OrdersError("ID de orden nulo inesperado."));
        emit(previousState.copyWith(isLoading: false));
        return;
      }

      final (updatedOrderData, error) = await OrderService.addProductToOrder(
        orderId: orderId,
        productCode: event.productCode,
        quantity: event.quantity,
      );

      if (error != null || updatedOrderData == null) {
        emit(OrdersError(error ?? "No se pudo actualizar la orden."));
        emit(previousState.copyWith(isLoading: false));
        return;
      }

      // Ensure product details are loaded for the updated cart
      await updatedOrderData.fetchAllProducts();
      final OrderModel finalCartData = updatedOrderData;

      // Emit final loaded state with updated data and loading set to false
      emit(previousState.copyWith(
        // Make sure copyWith handles the internal list correctly for immutability
        currentCartOrder: finalCartData.copyWith(
            orderProducts:
                List<OrderProduct>.from(finalCartData.orderProducts)),
        isLoading: false, // Stop loading indicator
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(previousState.copyWith(isLoading: false)); // Revert loading on error
    }
  }

  Future<void> _onRemoveProduct(
      RemoveProductFromOrderEvent event, Emitter<OrdersState> emit) async {
    if (state is! OrdersLoaded) {
      emit(const OrdersError("Estado inválido para remover."));
      return;
    }
    final OrdersLoaded previousState = state as OrdersLoaded;
    final orderIdToRemoveFrom = event.orderId;

    // Indicate loading within the current loaded state
    emit(previousState.copyWith(isLoading: true));

    try {
      final (success, err) = await OrderService.deleteProductFromOrder(
        orderId: orderIdToRemoveFrom,
        productCode: event.productCode,
      );

      if (err != null || !success) {
        emit(OrdersError(err ?? "No se pudo eliminar producto."));
        emit(previousState.copyWith(isLoading: false)); // Revert loading
        return;
      }

      final (refetchedOrderData, refetchErr) =
          await OrderService.getOrderById(orderIdToRemoveFrom);

      if (refetchErr != null) {
        emit(OrdersError(refetchErr));
        emit(previousState.copyWith(isLoading: false)); // Revert loading
        return;
      }

      OrderModel? finalCartData;
      if (refetchedOrderData != null) {
        // Ensure product details are loaded
        await refetchedOrderData.fetchAllProducts();
        finalCartData = refetchedOrderData;
      }

      // Emit final state, turning loading off
      emit(previousState.copyWith(
        // Ensure internal list is new, handle null cart
        currentCartOrder: finalCartData?.copyWith(
            orderProducts:
                List<OrderProduct>.from(finalCartData.orderProducts)),
        isLoading: false, // Stop loading indicator
        forceCartNull: finalCartData ==
            null, // Set cart null if order doesn't exist anymore
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(previousState.copyWith(isLoading: false)); // Revert loading on error
    }
  }

  Future<void> _onClearCart(
      ClearCartEvent event, Emitter<OrdersState> emit) async {
    if (state is! OrdersLoaded) {
      emit(OrdersInitial());
      return;
    }
    final OrdersLoaded current = state as OrdersLoaded;
    final cartOrder = current.currentCartOrder;

    // Indicate loading
    emit(current.copyWith(isLoading: true));

    try {
      if (cartOrder != null && cartOrder.id != null) {
        final (_, err) = await OrderService.deleteOrder(cartOrder.id!);
        if (err != null) {
          emit(OrdersError("Error al vaciar carrito en servidor: $err"));
          emit(current.copyWith(isLoading: false)); // Revert loading
          return;
        }
      }
      // Emit loaded state with cart set to null and loading finished
      emit(current.copyWith(
          forceCartNull: true, // Use flag to set cart to null
          isLoading: false // Stop loading indicator
          ));
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(current.copyWith(
          isLoading: false)); // Revert loading on generic error
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
    List<OrderModel> filtered = orders;
    if (selectedFilters.isNotEmpty) {
      filtered = filtered.where((o) {
        final currentStatus = o.orderStatuses.isNotEmpty
            ? normalizeOnTheWay(o.orderStatuses.last.status)
            : ' ';
        return selectedFilters.contains(currentStatus);
      }).toList();
    }

    for (final flt in additionalFilters) {
      switch (flt) {
        case OrderStrings.mostRecent:
          filtered.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
          break;
        case OrderStrings.leastRecent:
          filtered.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));
          break;
        case OrderStrings.mostItems:
          filtered.sort((a, b) {
            final countA =
                a.orderProducts.fold<int>(0, (sum, p) => sum + p.quantity);
            final countB =
                b.orderProducts.fold<int>(0, (sum, p) => sum + p.quantity);
            return countB.compareTo(countA);
          });
          break;
      }
    }

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
