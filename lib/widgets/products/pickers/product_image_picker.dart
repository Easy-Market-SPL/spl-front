import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/providers/product_form_provider.dart';
import 'package:spl_front/services/gui/pick_image_from_device.dart';

class ProductImagePickerWidget extends StatelessWidget {
  const ProductImagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final productFormProvider = Provider.of<ProductFormProvider>(context);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            image: productFormProvider.selectedImage != null
                ? DecorationImage(
                    image: FileImage(productFormProvider.selectedImage!),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage("assets/images/empty_background.jpg"),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              onPressed: () async {
                final image = await ImagePickerService().pickImage(context);
                if (image != null) {
                  productFormProvider.setSelectedImage(image);
                }
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
