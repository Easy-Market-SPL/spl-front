import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/widgets/products/view/color/product_custom_color_dialog.dart';

/// Simulates fetching default colors from the backend.
/// // TODO: Replace this with a real API call.
Future<List<ProductColor>> fetchDefaultColors() async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    ProductColor(idColor: 0, name: 'Red', hexCode: '#F44336'),
    ProductColor(idColor: 0, name: 'Pink', hexCode: '#E91E63'),
    ProductColor(idColor: 0, name: 'Purple', hexCode: '#9C27B0'),
    ProductColor(idColor: 0, name: 'Deep Purple', hexCode: '#673AB7'),
    ProductColor(idColor: 0, name: 'Indigo', hexCode: '#3F51B5'),
    ProductColor(idColor: 0, name: 'Blue', hexCode: '#2196F3'),
    ProductColor(idColor: 0, name: 'Cyan', hexCode: '#00BCD4'),
    ProductColor(idColor: 0, name: 'Green', hexCode: '#4CAF50'),
    ProductColor(idColor: 0, name: 'Lime', hexCode: '#CDDC39'),
    ProductColor(idColor: 0, name: 'Yellow', hexCode: '#FFEB3B'),
    ProductColor(idColor: 0, name: 'Amber', hexCode: '#FFC107'),
    ProductColor(idColor: 0, name: 'Orange', hexCode: '#FF9800'),
    ProductColor(idColor: 0, name: 'Brown', hexCode: '#795548'),
    ProductColor(idColor: 0, name: 'Grey', hexCode: '#9E9E9E'),
    ProductColor(idColor: 0, name: 'Blue Grey', hexCode: '#607D8B'),
    ProductColor(idColor: 0, name: 'Black', hexCode: '#000000'),
    ProductColor(idColor: 0, name: 'White', hexCode: '#FFFFFF'),
  ];
}

/// Shows the default color selection dialog.
/// The dialog displays colors fetched from the backend.
/// If the user does not choose one, they can opt for a custom color.
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
                child: Center(child: CircularProgressIndicator(color: Colors.blue,)),
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