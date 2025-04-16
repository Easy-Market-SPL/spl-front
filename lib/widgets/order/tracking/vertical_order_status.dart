import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_state.dart';

class VerticalOrderStatus extends StatelessWidget {
  const VerticalOrderStatus({super.key});

  @override
  Widget build(BuildContext context) {
    // Uso OrdersBloc para acceder a la orden actual con su último estado
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded && state.filteredOrders.isNotEmpty) {
          final order = state.filteredOrders.first;
          final currentStatus = _extractLastStatus(order.orderStatuses);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusItem(
                icon: Icons.store,
                title: OrderStrings.orderConfirmed,
                description: OrderStrings.orderConfirmedDescription,
                notReachedTitle: OrderStrings.notConfirmed,
                notReachedDescription: OrderStrings.notConfirmedDescription,
                isActive: _isActive(
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
                _isActive(currentStatus, [
                  OrderStrings.preparingOrder,
                  OrderStrings.onTheWay,
                  OrderStrings.delivered
                ]),
              ),
              _buildStatusItem(
                icon: Icons.access_time,
                title: OrderStrings.preparingOrder,
                description: OrderStrings.preparingOrderDescription,
                notReachedTitle: OrderStrings.notPrepared,
                notReachedDescription: OrderStrings.notPreparedDescription,
                isActive: _isActive(
                  currentStatus,
                  [
                    OrderStrings.preparingOrder,
                    OrderStrings.onTheWay,
                    OrderStrings.delivered
                  ],
                ),
              ),
              _buildStatusLine(
                _isActive(currentStatus,
                    [OrderStrings.onTheWay, OrderStrings.delivered]),
              ),
              _buildStatusItem(
                icon: Icons.local_shipping,
                title: OrderStrings.onTheWay,
                description: OrderStrings.onTheWayDescription,
                notReachedTitle: OrderStrings.notOnTheWay,
                notReachedDescription: OrderStrings.notOnTheWayDescription,
                isActive: _isActive(
                  currentStatus,
                  [OrderStrings.onTheWay, OrderStrings.delivered],
                ),
              ),
              _buildStatusLine(
                _isActive(currentStatus, [OrderStrings.delivered]),
              ),
              _buildStatusItem(
                icon: Icons.check,
                title: OrderStrings.delivered,
                description: OrderStrings.deliveredDescription,
                notReachedTitle: OrderStrings.notDelivered,
                notReachedDescription: OrderStrings.notDeliveredDescription,
                isActive: (currentStatus == OrderStrings.delivered),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  // Devuelve el último estado si existe, de lo contrario, un string vacío
  String _extractLastStatus(orderStatuses) {
    if (orderStatuses == null || orderStatuses.isEmpty) {
      return '';
    }
    return orderStatuses.last.status;
  }

  // Retorna true si el currentStatus está dentro de la lista de statuses
  bool _isActive(String currentStatus, List<String> statuses) {
    return statuses.contains(currentStatus);
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String description,
    required String notReachedTitle,
    required String notReachedDescription,
    required bool isActive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color.fromARGB(255, 0, 73, 143)
                  : Colors.grey,
              size: 45,
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? title : notReachedTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  isActive ? description : notReachedDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusLine(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0),
      height: 50.0,
      width: 3.0,
      color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey,
    );
  }
}
