import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../bloc/product_blocs/product_form/product_form_bloc.dart';
import '../../../../bloc/product_blocs/product_form/product_form_event.dart';
import '../../../../bloc/product_blocs/product_form/product_form_state.dart';

class ProductImagePickerWidget extends StatefulWidget {
  const ProductImagePickerWidget({super.key});

  @override
  State<ProductImagePickerWidget> createState() => _ProductImagePickerWidgetState();
}

class _ProductImagePickerWidgetState extends State<ProductImagePickerWidget> {
  Uint8List? _webImageBytes;
  
  Future<void> _pickImageAndUpdate(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });
      
      context.read<ProductFormBloc>().add(UpdateProductImage(
        pickedFile.path,
        webImageBytes: bytes,
      ));
    } else {
      context.read<ProductFormBloc>().add(UpdateProductImage(pickedFile.path));
    }
  }
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
            if (kIsWeb) {
              if (_webImageBytes != null) {
                imageWidget = Image.memory(
                  _webImageBytes!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 320,
                );
              } else {

                imageWidget = Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Text('Cargando imagen...'),
                );
              }
            } else {
              imageWidget = Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: 320,
              );
            }
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
                  onPressed: () => _pickImageAndUpdate(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}