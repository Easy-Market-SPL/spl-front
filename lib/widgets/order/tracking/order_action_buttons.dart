import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../models/logic/user_type.dart';
import '../../../utils/strings/order_strings.dart';

class OrderActionButtons extends StatelessWidget {
  final String selectedStatus;
  final bool showDetailsButton;
  final bool showConfirmButton;
  final UserType userType;

  const OrderActionButtons({
    super.key,
    required this.selectedStatus,
    this.showDetailsButton = true,
    this.showConfirmButton = true,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDetailsButton)
          ElevatedButton(
            onPressed: () {
              _navigateToDetails(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 37, 139, 217),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              OrderStrings.orderDetailsTitle,
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (showDetailsButton) const SizedBox(height: 8.0),
        if (showConfirmButton)
          BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              final currentStatus = _extractCurrentStatus(state);
              if (currentStatus == null) {
                return Container();
              }
              final isEnabled = selectedStatus != currentStatus;
              return ElevatedButton(
                onPressed: isEnabled
                    ? () {
                        _confirmStatusChange(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnabled
                      ? const Color.fromARGB(255, 37, 139, 217)
                      : Colors.grey[350],
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  OrderStrings.confirm,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.black,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context) {
    if (userType == UserType.customer) {
      Navigator.of(context).pushNamed('customer_user_order_details');
    } else if (userType == UserType.business || userType == UserType.delivery) {
      Navigator.of(context).pushNamed('business_user_order_details');
    } else if (userType == UserType.admin) {
      Navigator.of(context).pushNamed('admin_user_order_details');
    }
  }

  void _confirmStatusChange(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(OrderStrings.confirmStatusChangeTitle),
          content:
              Text(OrderStrings.confirmStatusChangeContent(selectedStatus)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                OrderStrings.cancel,
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                /*
                context.read<OrdersBloc>().add(
                 ConfirmOrderEvent(orderId: orderId, shippingCost: shippingCost, paymentAmount: paymentAmount)
               );
                */

                Navigator.of(context).pop();
              },
              child: const Text(
                OrderStrings.accept,
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _extractCurrentStatus(OrdersState state) {
    if (state is OrdersLoaded && state.filteredOrders.isNotEmpty) {
      final order = state.filteredOrders.first;
      final lastStatus = order.orderStatuses;
      if (lastStatus == null || lastStatus.isEmpty) return null;
      return lastStatus.last.status;
    }
    return null;
  }
}
