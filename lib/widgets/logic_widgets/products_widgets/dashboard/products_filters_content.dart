import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_filter/product_filter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_filter/product_filter_event.dart';
import 'package:spl_front/bloc/product_blocs/product_form/labels/label_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_form/labels/label_state.dart';
import 'package:spl_front/models/product_models/labels/label.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/prices/price_formatter.dart';
import 'package:spl_front/utils/strings/customer_user_strings.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';

class ProductFilter {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<Label>? selectedLabels;
  ProductFilter({this.minPrice, this.maxPrice, this.minRating, this.selectedLabels});
}

class ProductFiltersForm extends StatefulWidget {
  final ProductFilter? initialFilter;
  final double? minProductPrice, maxProductPrice;
  final VoidCallback? onCancel;
  final void Function(ProductFilter) onApply;
  const ProductFiltersForm({
    super.key,
    this.initialFilter,
    this.minProductPrice,
    this.maxProductPrice,
    this.onCancel,
    required this.onApply,
  });
  @override
  State<ProductFiltersForm> createState() => _ProductFiltersFormState();
}

class _ProductFiltersFormState extends State<ProductFiltersForm> {
  late RangeValues _priceRange;
  late double _minRating;
  late List<Label> _selectedLabels;
  late double _minPriceValue, _maxPriceValue;
  final _labelSearchController = TextEditingController();
  String _labelSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _minPriceValue = widget.minProductPrice ?? 0;
    _maxPriceValue = widget.maxProductPrice ?? 1000000;
    final init = widget.initialFilter;
    _priceRange = RangeValues(init?.minPrice ?? _minPriceValue, init?.maxPrice ?? _maxPriceValue);
    _minRating = init?.minRating ?? 0;
    _selectedLabels = List.from(init?.selectedLabels ?? []);
  }

  @override
  void dispose() {
    _labelSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field for products (web)
        if (kIsWeb) ...[
          const Text(
              CustomerStrings.searchTittle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: CustomerStrings.searchHint,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
              onSubmitted: (value) {
                context.read<ProductFilterBloc>().add(SetSearchQuery(value));
              },
            ),
        ],
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(DashboardStrings.filters, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (widget.onCancel != null)
              IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
          ],
        ),
        const Divider(),

        const SizedBox(height: 16),
        // Price slider
        const Text(DashboardStrings.priceRange, style: TextStyle(fontWeight: FontWeight.bold)),
        RangeSlider(
          values: _priceRange,
          min: _minPriceValue,
          max: _maxPriceValue,
          divisions: 100,
          labels: RangeLabels(
            PriceFormatter.formatPrice(_priceRange.start),
            PriceFormatter.formatPrice(_priceRange.end),
          ),
          onChanged: (v) => setState(() => _priceRange = v),
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
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                      padding: const EdgeInsets.all(5),
                    );
                  }).toList(),
                ),
              );
            } else {
              return const Text(DashboardStrings.errorLoadingLabels);
            }
          },
        ),
        const SizedBox(height: 24),
        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Cancel button
            if (widget.onCancel != null) 
              TextButton(
                onPressed: widget.onCancel,
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.grey[300])),
                child: const Text(DashboardStrings.cancel, style: TextStyle(color: Colors.black)),
              ),
            const SizedBox(width: 8),
            // Apply button
            ElevatedButton(
              onPressed: () {
                widget.onApply(ProductFilter(
                  minPrice: _priceRange.start,
                  maxPrice: _priceRange.end,
                  minRating: _minRating > 0 ? _minRating : null,
                  selectedLabels: _selectedLabels.isEmpty ? null : _selectedLabels,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(DashboardStrings.applyFilters, style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ],
    );
  }
}