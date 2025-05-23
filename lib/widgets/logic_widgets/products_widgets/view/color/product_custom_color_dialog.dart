import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../../models/product_models/product_color.dart';
import '../../../../../services/api_services/product_services/color_service.dart';

/// Shows the custom color dialog using the flutter_colorpicker plugin.
Future<ProductColor?> showCustomColorDialog(BuildContext context) async {
  final maxColorNameLength = 45;
  TextEditingController nameController = TextEditingController();
  Color selectedColor = Colors.blue;
  return await showDialog<ProductColor>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Añadir color personalizado"),
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    maxLength: maxColorNameLength,
                    decoration: const InputDecoration(
                      hintText: "Nombre color",
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Use ColorPicker to select a color.
                  ColorPicker(
                    pickerColor: selectedColor,
                    hexInputBar: true,
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar",
                    style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    ProductColor newCustom = ProductColor(
                      idColor: -1,
                      name: nameController.text.trim(),
                      hexCode:
                          '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                    );
                    // Simulate integration with the backend.
                    ProductColor? createdColor =
                        await createCustomColor(newCustom);
                    if (createdColor != null) {
                      Navigator.pop(ctx, createdColor);
                    } else {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error al crear el color"),
                        ),
                      );
                    }
                  }
                },
                child:
                    const Text("Añadir", style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<ProductColor?> createCustomColor(ProductColor color) async {
  return await ColorService.createColor(color);
}
