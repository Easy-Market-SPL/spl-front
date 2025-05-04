import 'package:flutter/material.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/color/product_default_color_dialog.dart';

import '../../../../../models/product_models/product_color.dart';

class ColorPickerWidget extends StatefulWidget {
  final List<ProductColor> initialColors;
  final ValueChanged<List<ProductColor>> onColorsChanged;

  const ColorPickerWidget({
    super.key,
    this.initialColors = const [],
    required this.onColorsChanged,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late List<ProductColor> _colors;

  @override
  void initState() {
    super.initState();
    _colors = widget.initialColors;
  }

  // Converts a hex code to a Color object.
  Color _colorFromHex(String hexCode) {
    final buffer = StringBuffer();
    if (hexCode.length == 6 || hexCode.length == 7) buffer.write('ff');
    buffer.write(hexCode.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Opens the default color picker dialog
  Future<void> _addNewColor() async {
    ProductColor? newColor = await showDefaultColorDialog(context);
    if (newColor != null) {
      // Prevent duplicate colors by comparing hex codes (case insensitive)
      bool duplicate = _colors.any(
          (c) => c.hexCode.toUpperCase() == newColor.hexCode.toUpperCase());
      if (duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This color has already been added to the product."),
          ),
        );
        return;
      }
      setState(() {
        _colors.add(newColor);
      });
      widget.onColorsChanged(_colors);
    }
  }

  // Removes the color at the given index.
  void _removeColor(int index) {
    setState(() {
      _colors.removeAt(index);
    });
    widget.onColorsChanged(_colors);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              // Button to add a color.
              GestureDetector(
                onTap: _addNewColor,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              // Display existing colors.
              ..._colors.asMap().entries.map((entry) {
                final index = entry.key;
                final productColor = entry.value;
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Add selection logic if needed.
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _colorFromHex(productColor.hexCode),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeColor(index),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
