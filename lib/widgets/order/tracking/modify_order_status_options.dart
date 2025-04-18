// lib/widgets/order/tracking/modify_order_status_options.dart

import 'package:flutter/material.dart';

import '../../../utils/strings/order_strings.dart';

class ModifyOrderStatusOptions extends StatelessWidget {
  /// El único estado posible (ya calculado por el padre).
  final String selectedStatus;

  const ModifyOrderStatusOptions({
    Key? key,
    required this.selectedStatus,
  }) : super(key: key);

  static const List<String> _order = [
    'confirmed',
    'preparing',
    'on-the-way',
    'delivered',
  ];

  static const Map<String, String> _label = {
    'confirmed': OrderStrings.orderConfirmed,
    'preparing': OrderStrings.preparingOrder,
    'on-the-way': OrderStrings.onTheWay,
    'delivered': OrderStrings.delivered,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          OrderStrings.modifyOrderStatus,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._order.map((code) {
          final bool isSelected = code == selectedStatus;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isSelected ? Colors.grey : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(15),
              color: isSelected ? Colors.white : Colors.grey.shade100,
            ),
            child: RadioListTile<String>(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                _label[code] ?? code,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: code,
              groupValue: selectedStatus,
              onChanged: null, // no permite otro click
              activeColor: Colors.blue,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        }).toList(),
      ],
    );
  }
}
