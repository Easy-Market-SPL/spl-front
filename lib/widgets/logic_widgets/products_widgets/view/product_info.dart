import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

class ProductInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final bool isEditing;

  const ProductInfoForm({
    super.key,
    required this.nameController,
    required this.codeController,
    required this.descriptionController,
    required this.priceController,
    this.isEditing = true,
  });

  @override
  Widget build(BuildContext context) {
    final int maxNameLength = 45;
    final int maxDescriptionLength = 250;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name field
        TextField(
          controller: nameController,
          maxLength: maxNameLength,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          decoration: InputDecoration(
            labelText: ProductStrings.productName,
            labelStyle: TextStyle(color: Colors.grey[700]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            counterText: '', // Hide default counter
          ),
        ),
        const SizedBox(height: 12),

        // Row for REF and PRICE fields
        Row(
          children: [
            // REF field
            Expanded(
              child: TextField(
                controller: codeController,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  labelText: ProductStrings.productReference,
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  enabled: !isEditing,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Price field
            Expanded(
              child: TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  labelText: ProductStrings.productPrice,
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                inputFormatters: <TextInputFormatter>[
                  CurrencyTextInputFormatter.currency(
                    decimalDigits: 0,
                    symbol: '',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Description section
        const Text(
          ProductStrings.productDescription,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 6),

        // Description field with border
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: TextField(
            controller: descriptionController,
            maxLines: null,
            maxLength: maxDescriptionLength,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration.collapsed(
              hintText: ProductStrings.descriptionHint,
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
