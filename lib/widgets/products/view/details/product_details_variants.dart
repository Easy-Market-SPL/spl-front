import 'package:flutter/material.dart';
import 'package:spl_front/models/data/variant.dart';

class ProductDetailsVariants extends StatelessWidget {
  final List<Variant> variants;
  final Map<String, String> selectedOptions;
  final Function(String variantName, String optionName) onOptionSelected;

  const ProductDetailsVariants({
    super.key,
    required this.variants,
    required this.selectedOptions,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Variantes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Column(
          children: variants.map((variant) => _buildVariantRow(variant)).toList(),
        ),
      ],
    );
  }

  Widget _buildVariantRow(Variant variant) {
    // Get the currently selected option for this variant
    String? selectedOption = selectedOptions[variant.name];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variant name
          Text(
            variant.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Options as selectable chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variant.options.map((option) {
              bool isSelected = selectedOption == option.name;
              return GestureDetector(
                onTap: () => onOptionSelected(variant.name, option.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                  ),
                  child: Text(
                    option.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blue,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}