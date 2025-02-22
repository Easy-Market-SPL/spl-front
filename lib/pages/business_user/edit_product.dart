import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/business_user_back_app_bar.dart';
import 'package:spl_front/widgets/inputs/custom_creation_product_input.dart';
import 'package:spl_front/widgets/products/pickers/product_image_picker.dart';
import 'package:spl_front/widgets/tags/tags_input_labels_product.dart';

class EditProductPage extends StatelessWidget {
  // TODO: Implement the logic to get the product data and fill the form with it using BLOC or Provider, per now we are using simple strings that later will be replaced with the real data
  final String productId;
  const EditProductPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // TODO: Create a form provider for handle the interaction with selected tags and image.
    // final productFormProvider = Provider.of<ProductFormProvider>(context);

    // Fill those strings with the real data
    final String productName = "";
    final String productReference = "";
    final String productDescription = "";

    final TextEditingController nameController = TextEditingController();
    final TextEditingController referenceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

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
              Text(
                  productName.isNotEmpty
                      ? productName
                      : ProductStrings.creationName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomCreationProductInput(
                  label: productReference.isNotEmpty
                      ? productReference
                      : ProductStrings.creationReference,
                  icon: Icons.edit,
                  controller: nameController),
              const SizedBox(height: 10),
              Text(
                  productDescription.isNotEmpty
                      ? ProductStrings.creationDescription
                      : productDescription,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomCreationProductInput(
                  label: ProductStrings.creationReference,
                  controller: referenceController),
              const SizedBox(height: 10),
              const Text(ProductStrings.creationDescription,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomCreationProductInput(
                  label: ProductStrings.creationDescription,
                  maxLines: 3,
                  controller: descriptionController),
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
