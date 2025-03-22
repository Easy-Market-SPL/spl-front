import 'package:flutter/material.dart';

/// Shows a dialog to create a custom tag.
/// The tag name is limited to 45 characters with a visible counter.
Future<String?> showNewLabelDialog(BuildContext context) async {
  final maxLabelLength = 45;
  TextEditingController tagController = TextEditingController();

  return await showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Añadir etiqueta"),
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tagController,
                    maxLength: maxLabelLength,
                    decoration: const InputDecoration(
                      hintText: "Nombre etiqueta",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    cursorColor: Colors.blue,
                  ),
                ],
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
                onPressed: () {
                  if (tagController.text.trim().isNotEmpty) {
                    // TODO: Implement API call to save the new tag.
                    Navigator.pop(ctx, tagController.text.trim());
                  }
                },
                child: const Text(
                  "Crear",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}