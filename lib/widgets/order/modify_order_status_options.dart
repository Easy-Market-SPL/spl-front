import 'package:flutter/material.dart';

class ModifyOrderStatusOptions extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const ModifyOrderStatusOptions({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modificar estado de la orden',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Column(
          children: [
            _buildStatusOption(context, 'Orden confirmada'),
            _buildStatusOption(context, 'Preparando la orden'),
            _buildStatusOption(context, 'En camino'),
            _buildStatusOption(context, 'Entregada'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(BuildContext context, String status) {
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
        child: RadioListTile<String>(
          title: Text(status),
          value: status,
          groupValue: selectedStatus,
          onChanged: (value) {
            onStatusChanged(value!);
          },
          activeColor: Colors.blue,
          controlAffinity: ListTileControlAffinity.trailing, // Moves the radio button to the right
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}