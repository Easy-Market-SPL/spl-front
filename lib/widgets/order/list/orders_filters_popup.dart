import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/order/list/order_filters_section.dart';

class FiltersPopup extends StatelessWidget {
  final Function(List<String>, DateTimeRange?) onApplyFilters;
  final Function() onClearFilters;
  final Function(String)? onSearchOrders;
  final Function(String)? onStatusFilter;
  final List<String> currentAdditionalFilters;
  final DateTimeRange? currentDateRange;

  const FiltersPopup({
    super.key,
    required this.onApplyFilters,
    required this.onClearFilters,
    this.onSearchOrders,
    this.onStatusFilter,
    required this.currentAdditionalFilters,
    this.currentDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogHeader(context),
            const SizedBox(height: 10),
            FiltersSection(
              onApplyFilters: (filters, dateRange) {
                onApplyFilters(filters, dateRange);
                Navigator.of(context).pop();
              },
              onClearFilters: onClearFilters,
              onSearchOrders: onSearchOrders,
              onStatusFilter: onStatusFilter,
              currentAdditionalFilters: currentAdditionalFilters,
              currentDateRange: currentDateRange,
            ),
          ],
        ),
      ),
    );
  }

  // Header with close button
  Widget _buildDialogHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          OrderStrings.filtersTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(), // Close the popup
        ),
      ],
    );
  }
}