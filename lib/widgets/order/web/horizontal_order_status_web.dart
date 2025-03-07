import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class CustomHorizontalOrderStatus extends StatelessWidget {
  const CustomHorizontalOrderStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderStatusBloc, OrderStatusState>(
      builder: (context, state) {
        if (state is OrderStatusLoaded) {
          final bool step1Active = state.currentStatus == OrderStrings.orderConfirmed ||
              state.currentStatus == OrderStrings.preparingOrder ||
              state.currentStatus == OrderStrings.onTheWay ||
              state.currentStatus == OrderStrings.delivered;
          final bool step2Active = state.currentStatus == OrderStrings.preparingOrder ||
              state.currentStatus == OrderStrings.onTheWay ||
              state.currentStatus == OrderStrings.delivered;
          final bool step3Active = state.currentStatus == OrderStrings.onTheWay ||
              state.currentStatus == OrderStrings.delivered;
          final bool step4Active = state.currentStatus == OrderStrings.delivered;

          final List<OrderStep> steps = [
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

          // Calculates the progress fraction based on the active step
          int lastActiveIndex = steps.lastIndexWhere((step) => step.isActive);
          double progressFraction = (steps.isNotEmpty)
              ? (lastActiveIndex + 1) / steps.length
              : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: progressFraction,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D4F94)),
              ),
              const SizedBox(height: 16),
              // Steps
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns the icons to the top
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
                        // Tittle
                        Text(
                          step.isActive ? step.activeTitle : step.inactiveTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: step.isActive ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Description
                        Text(
                          step.isActive ? step.activeDescription : step.inactiveDescription,
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
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
