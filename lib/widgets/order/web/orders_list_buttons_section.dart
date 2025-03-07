import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback onClearFilters;
  final VoidCallback onApplyFilters;

  const ActionButtonsSection({
    super.key,
    required this.onClearFilters,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        // Clear button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
          onPressed: onClearFilters,
          child: const Text(OrderStrings.clear, style: TextStyle(color: Colors.black)),
        ),
        // Apply button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
          onPressed: onApplyFilters,
          child: const Text(OrderStrings.confirm, style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}