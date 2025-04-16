import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_state.dart';

class CustomHorizontalOrderStatus extends StatelessWidget {
  const CustomHorizontalOrderStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded && state.filteredOrders.isNotEmpty) {
          final order = state.filteredOrders.first;
          final currentStatus = _extractLastStatus(order.orderStatuses);
          final step1Active = _isActive(
            currentStatus,
            [
              OrderStrings.orderConfirmed,
              OrderStrings.preparingOrder,
              OrderStrings.onTheWay,
              OrderStrings.delivered
            ],
          );
          final step2Active = _isActive(
            currentStatus,
            [
              OrderStrings.preparingOrder,
              OrderStrings.onTheWay,
              OrderStrings.delivered
            ],
          );
          final step3Active = _isActive(
            currentStatus,
            [OrderStrings.onTheWay, OrderStrings.delivered],
          );
          final step4Active = (currentStatus == OrderStrings.delivered);

          final steps = [
            OrderStep(
              activeTitle: OrderStrings.orderConfirmed,
              activeDescription: OrderStrings.orderConfirmedDescription,
              inactiveTitle: OrderStrings.notConfirmed,
              inactiveDescription: OrderStrings.notConfirmedDescription,
              icon: Icons.shopping_basket,
              isActive: step1Active,
            ),
            OrderStep(
              activeTitle: OrderStrings.preparingOrder,
              activeDescription: OrderStrings.preparingOrderDescription,
              inactiveTitle: OrderStrings.notPrepared,
              inactiveDescription: OrderStrings.notPreparedDescription,
              icon: Icons.access_time,
              isActive: step2Active,
            ),
            OrderStep(
              activeTitle: OrderStrings.onTheWay,
              activeDescription: OrderStrings.onTheWayDescription,
              inactiveTitle: OrderStrings.notOnTheWay,
              inactiveDescription: OrderStrings.notOnTheWayDescription,
              icon: Icons.local_shipping_outlined,
              isActive: step3Active,
            ),
            OrderStep(
              activeTitle: OrderStrings.delivered,
              activeDescription: OrderStrings.deliveredDescription,
              inactiveTitle: OrderStrings.notDelivered,
              inactiveDescription: OrderStrings.notDeliveredDescription,
              icon: Icons.check_circle,
              isActive: step4Active,
            ),
          ];

          final lastActiveIndex = steps.lastIndexWhere((step) => step.isActive);
          final progressFraction =
              (steps.isNotEmpty) ? (lastActiveIndex + 1) / steps.length : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: progressFraction,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF0D4F94)),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: steps.map((step) {
                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 60,
                          child: _buildStatusIcon(step.icon, step.isActive),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.isActive ? step.activeTitle : step.inactiveTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                step.isActive ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.isActive
                              ? step.activeDescription
                              : step.inactiveDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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

  String _extractLastStatus(statuses) {
    if (statuses == null || statuses.isEmpty) return '';
    return statuses.last.status;
  }

  bool _isActive(String currentStatus, List<String> validStatuses) {
    return validStatuses.contains(currentStatus);
  }

  Widget _buildStatusIcon(IconData icon, bool isActive) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF0D4F94) : Colors.white,
        border: Border.all(
          color: isActive ? const Color(0xFF0D4F94) : Colors.grey,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey,
        size: 25,
      ),
    );
  }
}

class OrderStep {
  final String activeTitle;
  final String activeDescription;
  final String inactiveTitle;
  final String inactiveDescription;
  final IconData icon;
  final bool isActive;

  OrderStep({
    required this.activeTitle,
    required this.activeDescription,
    required this.inactiveTitle,
    required this.inactiveDescription,
    required this.icon,
    required this.isActive,
  });
}
