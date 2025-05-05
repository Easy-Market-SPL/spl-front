import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class SortSection extends StatelessWidget {
  final String? selectedSortOption;
  final ValueChanged<String?> onSortChanged;

  const SortSection({
    super.key,
    required this.selectedSortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> sortOptions = [
      OrderStrings.mostRecent,
      OrderStrings.leastRecent,
      OrderStrings.mostItems,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          OrderStrings.sortBy,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Column(
          children: sortOptions.map((option) => _buildSortOption(context, option)).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOption(BuildContext context, String option) {
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
          title: Text(option),
          value: option,
          groupValue: selectedSortOption,
          onChanged: onSortChanged,
          activeColor: Colors.blue,
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}