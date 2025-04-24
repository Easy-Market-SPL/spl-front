// lib/widgets/order/tracking/vertical_order_status.dart
import 'package:flutter/material.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class VerticalOrderStatus extends StatelessWidget {
  final OrderModel order;
  const VerticalOrderStatus({super.key, required this.order});

  static const _blue = Color(0xFF00498F);

  @override
  Widget build(BuildContext context) {
    final currentStatus = _extractLastStatus(order);
    final currentDescription = _extractLastStatusDescription(order);

    // Cada “paso” con su icono y label
    final steps = <_StepData>[
      _StepData(
        icon: Icons.store,
        label: OrderStrings.orderConfirmed,
        description: OrderStrings.orderConfirmedDescription,
      ),
      _StepData(
        icon: Icons.access_time,
        label: OrderStrings.preparingOrder,
        description: OrderStrings.preparingOrderDescription,
      ),
      _StepData(
        icon: Icons.local_shipping,
        label: OrderStrings.onTheWay,
        description: OrderStrings.onTheWayDescription,
      ),
      _StepData(
        icon: Icons.check,
        label: OrderStrings.delivered,
        description: OrderStrings.deliveredDescription,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                '${OrderStrings.status}: $currentStatus',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                currentDescription,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // timeline vertical
        for (int i = 0; i < steps.length; i++) ...[
          _buildStatusItem(
            icon: steps[i].icon,
            title: steps[i].label,
            description: steps[i].description,
            isActive: _isActive(currentStatus, steps[i].label),
          ),
          if (i != steps.length - 1)
            _buildStatusLine(
              _isActive(
                currentStatus,
                steps[i + 1].label,
              ),
            ),
        ],
      ],
    );
  }

  /* ──────────── helpers ──────────── */

  String _extractLastStatus(OrderModel order) {
    if (order.orderStatuses.isEmpty) return '';
    switch (order.orderStatuses.last.status) {
      case 'confirmed':
        return OrderStrings.orderConfirmed;
      case 'preparing':
        return OrderStrings.preparingOrder;
      case 'on the way':
        return OrderStrings.onTheWay;
      case 'delivered':
        return OrderStrings.delivered;
      default:
        return 'Desconocido';
    }
  }

  String _extractLastStatusDescription(OrderModel order) {
    if (order.orderStatuses.isEmpty) return '';
    switch (order.orderStatuses.last.status) {
      case 'confirmed':
        return OrderStrings.orderConfirmedDescription;
      case 'preparing':
        return OrderStrings.preparingOrderDescription;
      case 'on the way':
        return OrderStrings.onTheWayDescription;
      case 'delivered':
        return OrderStrings.deliveredDescription;
      default:
        return 'Desconocido';
    }
  }

  bool _isActive(String current, String target) =>
      current == target ||
      (current == OrderStrings.delivered && target == OrderStrings.onTheWay) ||
      (current == OrderStrings.onTheWay &&
          target == OrderStrings.preparingOrder) ||
      (current == OrderStrings.preparingOrder &&
          target == OrderStrings.orderConfirmed);

  /* ──────────── UI helpers ──────────── */

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 40, color: isActive ? _blue : Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black : Colors.grey)),
              Text(description,
                  style: TextStyle(
                      fontSize: 14,
                      color: isActive ? Colors.black : Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 19), // alinea con icono
      height: 38,
      width: 3,
      color: isActive ? _blue : Colors.grey,
    );
  }
}

/* Helper sencillo para mantener los datos de los pasos */
class _StepData {
  final IconData icon;
  final String label;
  final String description;

  const _StepData({
    required this.icon,
    required this.label,
    required this.description,
  });
}
