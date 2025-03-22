import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_state.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/products/pickers/product_image_picker.dart';
import 'package:spl_front/widgets/products/view/color/product_colors.dart';
import 'package:spl_front/widgets/products/view/labels/product_label_picker.dart';
import 'package:spl_front/widgets/products/view/product_variants.dart';

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
        if (state is! ProductFormLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        // Retrieve data from the Bloc state
        final colors = state.colors;
        final tags = state.tags;
        final variants = state.variants;

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
                    onColorsChanged: (newColors) {
                      if (newColors.length > state.colors.length) {
                        final newColor = newColors.last;
                        context.read<ProductFormBloc>().add(AddProductColor(newColor));
                      } else if (newColors.length < state.colors.length) {
                        // Find the removed color
                        for (int i = 0; i < state.colors.length; i++) {
                          bool found = false;
                          for (var newColor in newColors) {
                            if (newColor.idColor == state.colors[i].idColor &&
                                newColor.name == state.colors[i].name) {
                              found = true;
                              break;
                            }
                          }
                          if (!found) {
                            context.read<ProductFormBloc>().add(RemoveProductColor(i));
                            break;
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Product Name
                  TextField(
                    controller: nameController,
                    maxLength: maxNameLength,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  LabelPicker(
                    tags: tags,
                    onTagsChanged: (newTags) {
                      if (newTags.length > state.tags.length) {
                        final newTag = newTags.last;
                        context.read<ProductFormBloc>().add(AddProductTag(newTag));
                      } else if (newTags.length < state.tags.length) {
                        // Find the removed tag
                        for (int i = 0; i < state.tags.length; i++) {
                          if (!newTags.contains(state.tags[i])) {
                            context.read<ProductFormBloc>().add(RemoveProductTag(i));
                            break;
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Variants
                  VariantsEditor(
                    variants: variants,
                    onVariantsChanged: () {
                      // TODO: Implement onVariantsChanged
                    },
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