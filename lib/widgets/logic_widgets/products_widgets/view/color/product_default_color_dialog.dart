import 'package:flutter/material.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/color/product_custom_color_dialog.dart';

import '../../../../../models/product_models/product_color.dart';
import '../../../../../services/api_services/product_services/color_service.dart';

Future<List<ProductColor>> fetchDefaultColors() async {
  return await ColorService.getColors() ?? [];
}

Future<ProductColor?> showDefaultColorDialog(BuildContext context) async {
  return await showDialog<ProductColor>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Elegir color"),
        backgroundColor: Colors.white,
        content: FutureBuilder<List<ProductColor>>(
          future: fetchDefaultColors(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.blue,
                )),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            final defaults = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: defaults.map((defaultColor) {
                      // Convert the hex code to a Color.
                      Color swatchColor = _colorFromHex(defaultColor.hexCode);
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx, defaultColor);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: swatchColor,
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              defaultColor.name,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      // Call the custom dialog if the user opts for a custom color.
                      await showCustomColorDialog(context);
                    },
                    child: const Text("Color personalizado",
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

/// Helper function to convert a hex code string to a Color.
Color _colorFromHex(String hexCode) {
  final buffer = StringBuffer();
  if (hexCode.length == 6 || hexCode.length == 7) buffer.write('ff');
  buffer.write(hexCode.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
