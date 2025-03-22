import 'package:flutter/material.dart';
import 'package:spl_front/widgets/products/view/labels/product_new_label_dialog.dart';

/// Simulate fetching default tags from the backend.
/// TODO: Replace this with a real API call.
Future<List<String>> fetchLabels() async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    'Tag 1',
    'Tag 2',
    'Tag 3',
    'Tag 4',
    'Common Tag',
    'Popular Tag',
  ];
}

/// Shows a dialog that lets the user select from default tags.
/// Also offers an option for a custom tag.
Future<String?> showLabelDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Elegir etiqueta"),
        backgroundColor: Colors.white,
        content: FutureBuilder<List<String>>(
          future: fetchLabels(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(backgroundColor: Colors.blue,)),
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
                    children: defaults.map((tag) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx, tag);
                        },
                        child: Chip(
                          label: Text(tag),
                          backgroundColor: Colors.white,
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
                      // If the user wants a custom tag, show the custom tag dialog.
                      await showNewLabelDialog(context);
                    },
                    child: const Text(
                      "Nueva etiqueta",
                      style: TextStyle(color: Colors.blue),
                    ),
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