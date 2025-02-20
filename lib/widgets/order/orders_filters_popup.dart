import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/order/custom_date_picker.dart';

class FiltersPopup extends StatefulWidget {
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
  State<FiltersPopup> createState() => _FiltersPopupState();
}

class _FiltersPopupState extends State<FiltersPopup> {
  List<String> selectedFilters = [];
  DateTimeRange? selectedDateRange;
  String? selectedSortOption;

  final List<String> sortOptions = [OrderStrings.mostRecent, OrderStrings.leastRecent, OrderStrings.mostItems];

  @override
  void initState() {
    super.initState();
    if (widget.currentAdditionalFilters.isNotEmpty) {
      selectedSortOption = widget.currentAdditionalFilters.firstWhere(
        (filter) => sortOptions.contains(filter),
        orElse: () => OrderStrings.mostRecent,
      );
    } 
    // Most recent filter by default
    else {
      selectedSortOption = OrderStrings.mostRecent;
    }
    selectedDateRange = widget.currentDateRange;
  }

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
            _buildDialogHeader(),
            const SizedBox(height: 10),
            _buildSortSection(),
            const SizedBox(height: 10),
            CustomDateRangePicker(
              initialDateRange: selectedDateRange,
              onDateRangeSelected: (range) {
                setState(() {
                  selectedDateRange = range;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Header with close button
  Widget _buildDialogHeader() {
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

  // Sort section with options
  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          OrderStrings.sortBy,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Column(
          children: sortOptions.map((option) => _buildSortOption(option)).toList(),
        ),
      ],
    );
  }

  // Action buttons: Apply and Clear
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
          onPressed: () {
            setState(() {
              selectedFilters.clear();
              selectedDateRange = null;
              selectedSortOption = OrderStrings.mostRecent;
            });
            widget.onClearFilters();
          },
          child: const Text(OrderStrings.clear, style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
          onPressed: () {
            if (selectedSortOption != null) {
              selectedFilters.add(selectedSortOption!);
            }
            widget.onApplyFilters(selectedFilters, selectedDateRange);
            Navigator.of(context).pop();
          },
          child: const Text(OrderStrings.confirm, style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Sort option row
  Widget _buildSortOption(String option) {
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
          onChanged: (value) {
            setState(() {
              selectedSortOption = value;
            });
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