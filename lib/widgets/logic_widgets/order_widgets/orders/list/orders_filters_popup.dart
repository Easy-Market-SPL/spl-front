// lib/widgets/order/list/orders_filters_popup.dart
import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

import 'order_filters_section.dart';

class FiltersPopup extends StatelessWidget {
  final Function(List<String>, DateTimeRange?) onApplyFilters;
  final Function() onClearFilters;
  final List<String> currentAdditionalFilters;
  final DateTimeRange? currentDateRange;

  const FiltersPopup({
    super.key,
    required this.onApplyFilters,
    required this.onClearFilters,
    required this.currentAdditionalFilters,
    this.currentDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(OrderStrings.filtersTitle,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FiltersSection(
              currentAdditionalFilters: currentAdditionalFilters,
              currentDateRange: currentDateRange,
              onApplyFilters: (f, dr) {
                onApplyFilters(f, dr);
                Navigator.of(context).pop();
              },
              onClearFilters: onClearFilters,
            ),
          ],
        ),
      ),
    );
  }
}
