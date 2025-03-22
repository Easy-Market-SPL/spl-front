import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_state.dart';

class ProductImagePickerWidget extends StatelessWidget {
  const ProductImagePickerWidget({super.key});

  // Method to pick an image from the gallery
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFormBloc, ProductFormState>(
      builder: (context, state) {
        String? imagePath;
        if (state is ProductFormLoaded) {
          imagePath = state.imagePath;
        }

        Widget imageWidget;
        if (imagePath != null && imagePath.isNotEmpty) {
          // Internet image
          if (imagePath.startsWith('http')) {
            imageWidget = Image.network(
              imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: 320,
            );
          } else {
            // Local image
            imageWidget = Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
              height: 320,
            );
          }
        } else {
          // Placeholder
          imageWidget = Image.asset(
            'assets/images/empty_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 320,
          );
        }

        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageWidget,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () async {
                    final path = await _pickImage();
                    if (path != null) {
                      context.read<ProductFormBloc>().add(UpdateProductImage(path));
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}