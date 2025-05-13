import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class StatusSection extends StatelessWidget {
  final List<String> selectedStatusFilters;
  final ValueChanged<String> onStatusChanged;

  const StatusSection({
    super.key,
    required this.selectedStatusFilters,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> statusOptions = [
      OrderStrings.statusConfirmed,
      OrderStrings.statusPreparing,
      OrderStrings.statusOnTheWay,
      OrderStrings.statusDelivered,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          OrderStrings.showByStatus,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Column(
          children: statusOptions.map((option) => _buildStatusOption(context, option)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusOption(BuildContext context, String option) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.blue,
        ),
        child: CheckboxListTile(
          title: Text(option),
          value: selectedStatusFilters.contains(option),
          onChanged: (bool? value) {
            onStatusChanged(option);
          },
          activeColor: Colors.blue,
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}