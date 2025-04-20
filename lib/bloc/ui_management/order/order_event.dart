import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/models/order_models/order_product.dart';

/// Base class for all orders-related events.
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Loads orders based on the user's role.
/// If role == 'customer', fetch only the user's orders.
/// Otherwise, fetch all orders.
class LoadOrdersEvent extends OrdersEvent {
  final String userId;
  final String userRole;

  const LoadOrdersEvent({required this.userId, required this.userRole});

  @override
  List<Object?> get props => [userId, userRole];
}

/// Loads a specific order by its ID.
class LoadSingleOrderEvent extends OrdersEvent {
  final int orderId;

  const LoadSingleOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadProductEvent extends OrdersEvent {
  final String productCode;

  const LoadProductEvent(this.productCode);

  @override
  List<Object?> get props => [productCode];
}

/// Filters orders by status or other criteria.
class FilterOrdersEvent extends OrdersEvent {
  final String status;

  const FilterOrdersEvent(this.status);

  @override
  List<Object?> get props => [status];
}

/// Searches orders by a given query (could be address, user, date, etc.).
class SearchOrdersEvent extends OrdersEvent {
  final String query;

  const SearchOrdersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filters delivery orders based on the user's role.
class FilterDeliveryOrdersEvent extends OrdersEvent {
  /// true → "Preparing Orders", false → "My deliveries"
  final bool preparacion;

  /// idUser
  final String userId;

  const FilterDeliveryOrdersEvent({
    required this.preparacion,
    required this.userId,
  });
}

/// Applies extra filters like "mostRecent", "leastRecent", "mostItems".
class ApplyAdditionalFiltersEvent extends OrdersEvent {
  final List<String> filters;

  const ApplyAdditionalFiltersEvent(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Clears extra filters.
class ClearAdditionalFiltersEvent extends OrdersEvent {
  const ClearAdditionalFiltersEvent();
}

/// Sets a date range filter.
class SetDateRangeEvent extends OrdersEvent {
  final DateTimeRange dateRange;

  const SetDateRangeEvent(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

/// Clears the date range filter.
class ClearDateRangeEvent extends OrdersEvent {
  const ClearDateRangeEvent();
}

/// Updates the address of an existing order.
class UpdateOrderAddressEvent extends OrdersEvent {
  final int orderId;
  final String address;

  const UpdateOrderAddressEvent({
    required this.orderId,
    required this.address,
  });

  @override
  List<Object?> get props => [orderId, address];
}

/// Confirms the order with shipping cost and payment amount.
class ConfirmOrderEvent extends OrdersEvent {
  final int orderId;
  final int shippingCost;
  final double paymentAmount;

  const ConfirmOrderEvent({
    required this.orderId,
    required this.shippingCost,
    required this.paymentAmount,
  });

  @override
  List<Object?> get props => [orderId, shippingCost, paymentAmount];
}

/// Prepares an order (changes status to 'preparing').
class PrepareOrderEvent extends OrdersEvent {
  final int orderId;

  const PrepareOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Sets an order "on the way" with a domiciliary.
class OnTheWayDomiciliaryOrderEvent extends OrdersEvent {
  final int orderId;
  final String idDomiciliary;
  final double initialLatitude;
  final double initialLongitude;

  const OnTheWayDomiciliaryOrderEvent({
    required this.orderId,
    required this.idDomiciliary,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  List<Object?> get props =>
      [orderId, idDomiciliary, initialLatitude, initialLongitude];
}

/// Sets an order "on the way" with a transport company.
class OnTheWayTransportOrderEvent extends OrdersEvent {
  final int orderId;
  final String transportCompany;
  final String shippingGuide;

  const OnTheWayTransportOrderEvent({
    required this.orderId,
    required this.transportCompany,
    required this.shippingGuide,
  });

  @override
  List<Object?> get props => [orderId, transportCompany, shippingGuide];
}

/// Marks an order as delivered.
class DeliveredOrderEvent extends OrdersEvent {
  final int orderId;

  const DeliveredOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Deletes an order entirely.
class DeleteOrderEvent extends OrdersEvent {
  final int orderId;

  const DeleteOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Updates the debt of an order.
class UpdateDebtEvent extends OrdersEvent {
  final int orderId;
  final double paymentAmount;

  const UpdateDebtEvent({
    required this.orderId,
    required this.paymentAmount,
  });

  @override
  List<Object?> get props => [orderId, paymentAmount];
}

/// Adds or updates a product in the order (like a cart).
/// If user is a customer and there's no current order, we might create one.
class AddProductToOrderEvent extends OrdersEvent {
  final String productCode;
  final int quantity;
  final String userId; // For creating an order if needed
  final String address; // For creating an order if needed

  const AddProductToOrderEvent(
    OrderProduct item, {
    required this.productCode,
    required this.quantity,
    required this.userId,
    required this.address,
  });

  @override
  List<Object?> get props => [productCode, quantity, userId, address];
}

/// Removes a product from the order.
class RemoveProductFromOrderEvent extends OrdersEvent {
  final int orderId;
  final String productCode;

  const RemoveProductFromOrderEvent({
    required this.orderId,
    required this.productCode,
  });

  @override
  List<Object?> get props => [orderId, productCode];
}

/// Clears or resets the "cart" (optional).
class ClearCartEvent extends OrdersEvent {
  const ClearCartEvent();
}

class LoadOrderProductsEvent extends OrdersEvent {
  final int orderId;

  const LoadOrderProductsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
