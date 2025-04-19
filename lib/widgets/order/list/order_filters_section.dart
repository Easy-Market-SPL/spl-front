import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/order/list/custom_date_picker.dart';
import 'package:spl_front/widgets/order/web/orders_list_buttons_section.dart';
import 'package:spl_front/widgets/order/web/orders_list_search_section.dart';
import 'package:spl_front/widgets/order/web/orders_list_sort_section.dart';
import 'package:spl_front/widgets/order/web/orders_list_status_section.dart';

class FiltersSection extends StatefulWidget {
  final Function(List<String>, DateTimeRange?) onApplyFilters;
  final Function() onClearFilters;
  final Function(String)? onSearchOrders;
  final Function(String)? onStatusFilter;
  final List<String> currentAdditionalFilters;
  final DateTimeRange? currentDateRange;

  const FiltersSection({
    super.key,
    required this.onApplyFilters,
    required this.onClearFilters,
    this.onSearchOrders,
    this.onStatusFilter,
    required this.currentAdditionalFilters,
    this.currentDateRange,
  });

  @override
  State<FiltersSection> createState() => _FiltersSectionState();
}

class _FiltersSectionState extends State<FiltersSection> {
  List<String> selectedFilters = [];
  List<String> selectedStatusFilters = [];
  DateTimeRange? selectedDateRange;
  String? selectedSortOption;
  String searchQuery = '';
  late TextEditingController searchController;
  late TextEditingController dateRangeController;

  @override
  void initState() {
    super.initState();
    if (widget.currentAdditionalFilters.isNotEmpty) {
      selectedSortOption = widget.currentAdditionalFilters.firstWhere(
        (filter) => selectedFilters.contains(filter),
        orElse: () => OrderStrings.mostRecent,
      );
    }
    // Most recent filter by default
    else {
      selectedSortOption = OrderStrings.mostRecent;
    }
    selectedDateRange = widget.currentDateRange;
    searchController = TextEditingController();
    dateRangeController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    dateRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kIsWeb) ...[
          Text(
            OrderStrings.filtersTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SearchBarSection(
            searchController: searchController,
            onSearch: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
        ],
        const SizedBox(height: 10),
        SortSection(
          selectedSortOption: selectedSortOption,
          onSortChanged: (value) {
            setState(() {
              selectedSortOption = value;
            });
          },
        ),
        const SizedBox(height: 10),
        // Date range picker
        CustomDateRangePicker(
          initialDateRange: selectedDateRange,
          onDateRangeSelected: (range) {
            setState(() {
              selectedDateRange = range;
            });
          },
          controller: dateRangeController,
        ),
        const SizedBox(height: 20),
        ActionButtonsSection(
          onClearFilters: () {
            setState(() {
              selectedFilters.clear();
              selectedStatusFilters.clear();
              selectedDateRange = null;
              selectedSortOption = OrderStrings.mostRecent;
              searchQuery = '';
              searchController.clear();
              dateRangeController.clear();
            });
            widget.onClearFilters();
          },
          onApplyFilters: () {
            if (selectedSortOption != null) {
              selectedFilters.add(selectedSortOption!);
            }
            widget.onApplyFilters(selectedFilters, selectedDateRange);
            if (widget.onSearchOrders != null) {
              widget.onSearchOrders!(searchQuery);
            }
          },
        ),
        const SizedBox(height: 10),
        if (kIsWeb)
          StatusSection(
            selectedStatusFilters: selectedStatusFilters,
            onStatusChanged: (status) {
              setState(() {
                if (selectedStatusFilters.contains(status)) {
                  selectedStatusFilters.remove(status);
                } else {
                  selectedStatusFilters.add(status);
                }
                widget.onStatusFilter!(status);
              });
            },
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}
