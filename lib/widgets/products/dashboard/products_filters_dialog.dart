import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_state.dart';
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/prices/price_formatter.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';

class ProductFilter {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<Label>? selectedLabels;

  ProductFilter({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.selectedLabels,
  });

  // Method to create a copy of the filter with updated values
  ProductFilter copyWith({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<Label>? selectedLabels,
  }) {
    return ProductFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      selectedLabels: selectedLabels ?? this.selectedLabels,
    );
  }
}

class ProductFilterDialog extends StatefulWidget {
  final ProductFilter? initialFilter;
  final double? maxProductPrice;
  final double? minProductPrice; 

  const ProductFilterDialog({
    super.key, 
    this.initialFilter,
    this.maxProductPrice,
    this.minProductPrice,
  });

  @override
  State<ProductFilterDialog> createState() => _ProductFilterDialogState();
}

class _ProductFilterDialogState extends State<ProductFilterDialog> {
  late RangeValues _priceRange;
  late double _minRating;
  late List<Label> _selectedLabels;
  late double _minPriceValue;
  late double _maxPriceValue;

  final TextEditingController _labelSearchController = TextEditingController();
  String _labelSearchQuery = '';

  @override
  void initState() {
    super.initState();
    
    _minPriceValue = widget.minProductPrice ?? 0;
    _maxPriceValue = widget.maxProductPrice != null 
        ? widget.maxProductPrice!
        : 1000000;
    
    double initialMin = widget.initialFilter?.minPrice ?? _minPriceValue;
    double initialMax = widget.initialFilter?.maxPrice ?? _maxPriceValue;
    
    _priceRange = RangeValues(initialMin, initialMax);
    _minRating = widget.initialFilter?.minRating ?? 0.0;
    _selectedLabels = widget.initialFilter?.selectedLabels ?? [];
    
    // context.read<LabelBloc>().add(LoadDashboardLabels());
  }

  @override
  void dispose() {
    _labelSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    DashboardStrings.filters,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              
              // Price range
              const Text(
                DashboardStrings.priceRange,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                values: _priceRange,
                min: _minPriceValue,
                max: _maxPriceValue,
                divisions: 100,
                labels: RangeLabels(
                  PriceFormatter.formatPrice(_priceRange.start),
                  PriceFormatter.formatPrice(_priceRange.end),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(PriceFormatter.formatPrice(_priceRange.start, withDecimal: false)),
                  Text(PriceFormatter.formatPrice(_priceRange.end, withDecimal: false)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Rating slider
              if (SPLVariables.isRated) ...[
                const Text(
                  DashboardStrings.minRating,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _minRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: _minRating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _minRating = value;
                          });
                        },
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        thumbColor: Colors.blue,
                      ),
                    ),
                    Row(
                      children: [
                        Text(_minRating.toStringAsFixed(1)),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Labels
              const Text(
                DashboardStrings.labels,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Search field for labels
              TextField(
                controller: _labelSearchController,
                decoration: const InputDecoration(
                  hintText: DashboardStrings.searchLabels,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _labelSearchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 12),

              BlocBuilder<LabelBloc, LabelState>(
                builder: (context, state) {
                  if (state is LabelLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LabelDashboardLoaded) {
                    List<Label> labels = state.labels.toList();
                    if (labels.isNotEmpty) {
                      labels.removeAt(0); // Removes the first label "todos"
                    }
                    
                    // Filter labels based on search query
                    if (_labelSearchQuery.isNotEmpty) {
                      labels = labels.where((label) => 
                        label.name.toLowerCase().contains(_labelSearchQuery)
                      ).toList();
                    }
                    
                    if (labels.isEmpty && _labelSearchQuery.isNotEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(DashboardStrings.noLabelsFound),
                        ),
                      );
                    }
                    
                    // Display labels
                    return Wrap(
                      spacing: 8,
                      children: labels.map((label) {
                        final isSelected = _selectedLabels.any((l) => l.idLabel == label.idLabel);
                        return FilterChip(
                          label: Text(label.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedLabels.add(label);
                              } else {
                                _selectedLabels.removeWhere((l) => l.idLabel == label.idLabel);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  } else {
                    return const Text(DashboardStrings.errorLoadingLabels);
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.grey[300])),
                    child: const Text(DashboardStrings.cancel, style: TextStyle(color: Colors.black),),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final filter = ProductFilter(
                        minPrice: _priceRange.start,
                        maxPrice: _priceRange.end,
                        minRating: _minRating > 0 ? _minRating : null,
                        selectedLabels: _selectedLabels.isEmpty ? null : _selectedLabels,
                      );
                      Navigator.of(context).pop(filter);
                    },
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    child: const Text(DashboardStrings.applyFilters, style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}