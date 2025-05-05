import 'package:flutter/material.dart';
import 'package:spl_front/widgets/products/dashboard/products_filters_content.dart';

class ProductFilterDialog extends StatelessWidget {
  final ProductFilter initialFilter;
  final double? minProductPrice;
  final double? maxProductPrice;

  const ProductFilterDialog({
    super.key,
    required this.initialFilter,
    this.minProductPrice,
    this.maxProductPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: ProductFiltersForm(
              initialFilter: initialFilter,
              minProductPrice: minProductPrice,
              maxProductPrice: maxProductPrice,
              onCancel: () => Navigator.of(context).pop(),
              onApply: (filter) => Navigator.of(context).pop(filter),
            ),
          ),
        ),
      ),
    );
  }
}
