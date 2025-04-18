import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../utils/strings/order_strings.dart';

class HorizontalOrderStatus extends StatelessWidget {
  final OrderModel order;
  const HorizontalOrderStatus({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded && state.filteredOrders.isNotEmpty) {
          final currentStatus = _extractLastStatus(order);
          final currentStatusDescription = _extractLastStatusDescription(order);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusIcon(
                    Icons.store,
                    _isActive(
                      currentStatus,
                      [
                        OrderStrings.orderConfirmed,
                        OrderStrings.preparingOrder,
                        OrderStrings.onTheWay,
                        OrderStrings.delivered
                      ],
                    ),
                  ),
                  _buildStatusLine(
                    _isActive(
                      currentStatus,
                      [
                        OrderStrings.preparingOrder,
                        OrderStrings.onTheWay,
                        OrderStrings.delivered
                      ],
                    ),
                  ),
                  _buildStatusIcon(
                    Icons.access_time,
                    _isActive(
                      currentStatus,
                      [
                        OrderStrings.preparingOrder,
                        OrderStrings.onTheWay,
                        OrderStrings.delivered
                      ],
                    ),
                  ),
                  _buildStatusLine(
                    _isActive(
                      currentStatus,
                      [OrderStrings.onTheWay, OrderStrings.delivered],
                    ),
                  ),
                  _buildStatusIcon(
                    Icons.local_shipping,
                    _isActive(
                      currentStatus,
                      [OrderStrings.onTheWay, OrderStrings.delivered],
                    ),
                  ),
                  _buildStatusLine(
                    _isActive(currentStatus, [OrderStrings.delivered]),
                  ),
                  _buildStatusIcon(
                    Icons.check,
                    currentStatus == OrderStrings.delivered,
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              Center(
                child: Column(
                  children: [
                    Text(
                      '${OrderStrings.status}: $currentStatus',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentStatusDescription,
                      style: TextStyle(
                          fontSize: 16, color: Color.fromARGB(127, 0, 0, 0)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 4,
              ),
            ],
          );
        } else if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Container();
        }
      },
    );
  }

  String _extractLastStatus(order) {
    final statuses = order.orderStatuses;
    if (statuses == null || statuses.isEmpty) return '';
    switch (statuses.last.status) {
      case 'confirmed':
        return OrderStrings.orderConfirmed;
      case 'preparing':
        return OrderStrings.preparingOrder;
      case 'on-the-way':
        return OrderStrings.onTheWay;
      case 'delivered':
        return OrderStrings.delivered;
      default:
        return 'Desconocido';
    }
  }

  String _extractLastStatusDescription(order) {
    final statuses = order.orderStatuses;
    if (statuses == null || statuses.isEmpty) return '';
    switch (statuses.last.status) {
      case 'confirmed':
        return OrderStrings.orderConfirmedDescription;
      case 'preparing':
        return OrderStrings.preparingOrderDescription;
      case 'on-the-way':
        return OrderStrings.onTheWayDescription;
      case 'delivered':
        return OrderStrings.deliveredDescription;
      default:
        return 'Desconocido';
    }
  }

  bool _isActive(String currentStatus, List<String> validStates) {
    return validStates.contains(currentStatus);
  }

  Widget _buildStatusIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey,
      size: 40,
    );
  }

  Widget _buildStatusLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.0,
        color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey,
      ),
    );
  }
}
