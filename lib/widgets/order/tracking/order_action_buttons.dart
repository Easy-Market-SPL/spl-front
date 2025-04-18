// lib/widgets/order/tracking/order_action_buttons.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_event.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../models/logic/user_type.dart';
import '../../../pages/order/order_details.dart';
import '../../../utils/strings/order_strings.dart';
import '../../../utils/ui/order_statuses.dart';

class OrderActionButtons extends StatelessWidget {
  final String selectedStatus;
  final bool showDetailsButton;
  final bool showConfirmButton;
  final UserType userType;
  final OrderModel? order;
  final VoidCallback? onConfirmed;

  const OrderActionButtons({
    Key? key,
    required this.selectedStatus,
    this.showDetailsButton = true,
    this.showConfirmButton = true,
    required this.userType,
    this.order,
    this.onConfirmed,
  }) : super(key: key);

  static const List<String> _flow = [
    'confirmed',
    'preparing',
    'on-the-way',
    'delivered',
  ];
  int _idx(String s) => _flow.indexOf(normalizeOnTheWay(s));

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    final blocState = context.watch<OrdersBloc>().state;
    OrderModel current = order!;
    if (blocState is OrdersLoaded) {
      final upd =
          blocState.allOrders.firstWhereOrNull((o) => o.id == order!.id);
      if (upd != null) current = upd;
    }

    final curIdx = _idx(current.orderStatuses.last.status);
    final selIdx = _idx(selectedStatus);
    final canConfirm = selIdx == curIdx + 1;

    return Column(
      children: [
        if (showDetailsButton) ...[
          ElevatedButton(
            onPressed: () => _goToDetails(context, current),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF258BD9),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              OrderStrings.orderDetailsTitle,
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (showConfirmButton)
          ElevatedButton(
            onPressed: canConfirm ? () => _confirm(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canConfirm ? const Color(0xFF258BD9) : Colors.grey,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              OrderStrings.confirm,
              style:
                  TextStyle(color: canConfirm ? Colors.white : Colors.black87),
            ),
          ),
      ],
    );
  }

  void _goToDetails(BuildContext context, OrderModel o) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(userType: userType, order: o),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(OrderStrings.confirmStatusChangeTitle),
        content: Text(OrderStrings.confirmStatusChangeContent(selectedStatus)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(OrderStrings.cancel,
                style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              switch (selectedStatus) {
                case 'preparing':
                  context.read<OrdersBloc>().add(PrepareOrderEvent(order!.id!));
                  break;
                case 'on-the-way':
                  // context.read<OrdersBloc>().add(OnTheWayEvent(order: order!));
                  break;
                case 'delivered':
                  context
                      .read<OrdersBloc>()
                      .add(DeliveredOrderEvent(order!.id!));
                  break;
              }
              Navigator.pop(context);
              onConfirmed?.call();
            },
            child: const Text(OrderStrings.accept,
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
