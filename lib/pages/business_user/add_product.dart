import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/business_user_back_app_bar.dart';
import 'package:spl_front/widgets/inputs/custom_creation_product_input.dart';
import 'package:spl_front/widgets/products/pickers/product_image_picker.dart';
import 'package:spl_front/widgets/tags/tags_input_labels_product.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Create a form provider for handle the interaction with selected tags and image.
    // final productFormProvider = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      appBar: BusinessUserBackAppBar(
        hintText: BusinessStrings.searchHint,
        onFilterPressed: () {
          // TODO: Implement filters action
        },
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const ProductImagePickerWidget(),
              const SizedBox(height: 20),
              const Text(ProductStrings.creationName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomCreationProductInput(
                  label: ProductStrings.creationName,
                  icon: Icons.edit,
                  controller: TextEditingController()),
              const SizedBox(height: 10),
              const Text(ProductStrings.creationReference,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomCreationProductInput(
                  label: ProductStrings.creationReference,
                  controller: TextEditingController()),
              const SizedBox(height: 10),
              const Text(ProductStrings.creationDescription,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomCreationProductInput(
                  label: ProductStrings.creationDescription,
                  maxLines: 3,
                  controller: TextEditingController()),
              const SizedBox(height: 20),
              const TagsInputWidget(),
              const SizedBox(height: 20),
              _buildButtons(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement save functionality on the state and in the backend and then go back to the previous page
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(ProductStrings.save,
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Discard the form and go back to the previous page
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.red),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(ProductStrings.delete,
                style: TextStyle(fontSize: 16, color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
