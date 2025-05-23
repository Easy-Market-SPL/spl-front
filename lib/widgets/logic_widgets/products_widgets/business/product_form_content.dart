import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import '../../../../bloc/product_blocs/product_form/product_form_bloc.dart';
import '../../../../bloc/product_blocs/product_form/product_form_state.dart';
import '../pickers/product_image_picker.dart';
import '../view/color/product_colors.dart';
import '../view/labels/product_label_picker.dart';
import '../view/product_variants.dart';

class ProductFormContent extends StatelessWidget {
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;

  const ProductFormContent({
    super.key,
    this.isEditing = true,
    required this.nameController,
    required this.codeController,
    required this.descriptionController,
    required this.priceController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFormBloc, ProductFormState>(
      builder: (context, state) {
        if (state is !ProductFormLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        // Retrieve data from the Bloc state
        var colors = state.colors;
        var tags = state.labels;
        var variants = state.variants;

        final int maxNameLength = 45;
        final int maxDescriptionLength = 250;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Picker
                  ProductImagePickerWidget(),
                  const SizedBox(height: 5),

                  // Color Picker
                  ColorPickerWidget(
                    initialColors: colors,
                    onColorsChanged: (newColors) {},
                  ),
                  const SizedBox(height: 20),

                  // Product Name
                  TextField(
                    controller: nameController,
                    maxLength: maxNameLength,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: ProductStrings.productName,
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // REF and Price in a row
                  Row(
                    children: [
                      // REF
                      Expanded(
                        child: TextField(
                          controller: codeController,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                          decoration: InputDecoration(
                            labelText: ProductStrings.productReference,
                            enabled: !isEditing,
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Price
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: ProductStrings.productPrice,
                            prefixText: '\$ ',
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
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

                  // Description
                  const Text(
                    ProductStrings.creationDescription,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: descriptionController,
                      maxLines: null,
                      maxLength: maxDescriptionLength,
                      decoration: InputDecoration.collapsed(
                        hintText: ProductStrings.descriptionHint,
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  LabelPicker(
                    labels: tags,
                    onLabelsChanged: (newTags) {},
                  ),
                  const SizedBox(height: 20),

                  // Variants
                  VariantsEditor(
                    variants: variants,
                    onVariantsChanged: () {},
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
