import 'package:collection/collection.dart'; // firstWhereOrNull
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/pages/order/order_details.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../models/logic/user_type.dart';
import '../../../utils/strings/order_strings.dart';

class OrderActionButtons extends StatelessWidget {
  final String selectedStatus;
  final bool showDetailsButton;
  final bool showConfirmButton;
  final UserType userType;
  final OrderModel? order; // ¡orden recibida!

  const OrderActionButtons({
    super.key,
    required this.selectedStatus,
    this.showDetailsButton = true,
    this.showConfirmButton = true,
    required this.userType,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (showDetailsButton) ...[
          ElevatedButton(
            onPressed: () => _navigateToDetails(context, order!),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 37, 139, 217),
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
          BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              /// 1. Intentamos tomar la orden actualizada del bloc, si existe
              OrderModel currentOrder = order!;
              if (state is OrdersLoaded) {
                final updated =
                    state.allOrders.firstWhereOrNull((o) => o.id == order!.id);
                if (updated != null) currentOrder = updated;
              }

              /// 2. Estado real de la orden
              final currentStatus = _extractCurrentStatus(currentOrder);

              /// 3. ¿El botón debe estar habilitado?
              final isEnabled = selectedStatus != currentStatus;

              return ElevatedButton(
                onPressed:
                    isEnabled ? () => _confirmStatusChange(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnabled
                      ? const Color.fromARGB(255, 37, 139, 217)
                      : Colors.grey,
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

  // ───────────────────────────────── helpers ──────────────────────────────────

  void _navigateToDetails(BuildContext context, OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(userType: userType, order: order),
      ),
    );
  }

  void _confirmStatusChange(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(OrderStrings.confirmStatusChangeTitle),
        content: Text(
          OrderStrings.confirmStatusChangeContent(selectedStatus),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(OrderStrings.cancel,
                style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              // Aquí iría el Dispatch al BLoC para confirmar el cambio de estado
              // context.read<OrdersBloc>().add(MiEventoDeCambio(order!.id, selectedStatus));
              Navigator.pop(context);
            },
            child: const Text(OrderStrings.accept,
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  /// Devuelve el *último* estado registrado para la orden.
  String _extractCurrentStatus(OrderModel order) {
    if (order.orderStatuses.isEmpty) return '';
    return order.orderStatuses.last.status; // usamos el último
  }
}
