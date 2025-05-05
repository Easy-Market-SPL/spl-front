import 'package:flutter/material.dart';
import 'package:spl_front/models/product_models/variants/variant.dart';
import 'package:spl_front/models/product_models/variants/variant_option.dart';

class VariantsEditor extends StatefulWidget {
  final List<Variant> variants;
  final VoidCallback onVariantsChanged;

  const VariantsEditor({
    super.key,
    required this.variants,
    required this.onVariantsChanged,
  });

  @override
  State<VariantsEditor> createState() => _VariantsEditorState();
}

class _VariantsEditorState extends State<VariantsEditor> {
  final maxVariantNameLength = 45;
  // Allows the user to add a new variant to the product.
  Future<void> _addVariant() async {
    final variantName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String input = '';
        return AlertDialog(
          title: const Text("Agregar Variante"),
          backgroundColor: Colors.white,
          content: TextField(
            onChanged: (value) => input = value,
            maxLength: maxVariantNameLength,
            decoration: const InputDecoration(
              hintText: "Nombre de la variante",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, input),
              child: const Text(
                "Agregar",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
    if (variantName != null && variantName.trim().isNotEmpty) {
      //       // Instead of directly adding with setState, call a backend service.
      // try {
      //   // Example: await variantRepository.createVariant(variantName.trim())
      //   // and then, with the returned variant (which includes its id), update the UI.
      //   final newVariant = await VariantRepository.createVariant(variantName.trim());
      //   setState(() {
      //     widget.variants.add(newVariant);
      //   });
      //   widget.onVariantsChanged();
      // } catch (error) {
      //   // Display error message.
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Error creating variant: $error")),
      //   );
      // }
      setState(() {
        widget.variants.add(Variant(name: variantName.trim(), options: []));
      });
      widget.onVariantsChanged();
    }
  }

  void _removeVariant(int index) {
    setState(() {
      widget.variants.removeAt(index);
    });
    widget.onVariantsChanged();
  }

  // Allows the user to add a new option to a variant.
  void _addOption(int variantIndex) async {
    final optionName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String input = '';
        return AlertDialog(
          title: const Text("Agregar Opción"),
          content: TextField(
            onChanged: (value) => input = value,
            decoration: const InputDecoration(hintText: "Nombre de la opción"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, input),
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
    if (optionName != null && optionName.trim().isNotEmpty) {
      setState(() {
        widget.variants[variantIndex].options
            .add(VariantOption(name: optionName.trim()));
      });
      widget.onVariantsChanged();
    }
  }

  void _removeOption(int variantIndex, int optionIndex) {
    setState(() {
      widget.variants[variantIndex].options.removeAt(optionIndex);
    });
    widget.onVariantsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variants title and add button
        Row(
          children: [
            const Text(
              "Variantes de producto",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addVariant,
              icon: const Icon(Icons.add_circle, color: Colors.blue),
            )
          ],
        ),
        const SizedBox(height: 8),

        // Variants
        for (int i = 0; i < widget.variants.length; i++) // i = variant index
          // Variant Card
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            color: const Color.fromARGB(235, 255, 255, 255),
            shadowColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Variant name and delete button
                  Row(
                    children: [
                      Text(
                        widget.variants[i].name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _removeVariant(i),
                        icon: const Icon(Icons.delete, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Variant Option
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // j = option index
                      for (int j = 0;
                          j < widget.variants[i].options.length;
                          j++)
                        // Option Chip
                        Chip(
                          label: Text(
                            widget.variants[i].options[j].name,
                            style: TextStyle(color: Colors.blue),
                          ),
                          backgroundColor: Colors.white,
                          deleteIconColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(color: Colors.blue),
                          ),
                          onDeleted: () => _removeOption(i, j),
                        ),
                      ActionChip(
                        backgroundColor: Colors.blue,
                        label: const Text(
                          "Agregar Opción",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _addOption(i),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
