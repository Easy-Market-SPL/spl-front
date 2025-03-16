import 'package:flutter/material.dart';

class ProductInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;

  const ProductInfoForm({
    super.key,
    required this.nameController,
    required this.codeController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final int maxNameLength = 45;
    final int maxDescriptionLength = 200;
    final int nameLength = nameController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del producto con contador personalizado
        Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  TextField(
                    controller: nameController,
                    maxLength: maxNameLength,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      border: InputBorder.none,
                      counterText: '', // Oculta el contador por defecto
                      // 
                    ),
                    cursorColor: Colors.blue,
                    onChanged: (_) {},
                    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  // Posicionado un poco más abajo para evitar superposición
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Text(
                      '$nameLength/$maxNameLength',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
            ),
          ],
        ),
        // REF (code)
        TextField(
          controller: codeController,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          decoration: const InputDecoration(
            labelText: 'REF',
            border: InputBorder.none,
            enabled: false,
          ),
        ),
        const SizedBox(height: 12),
        // Descripción
        const Text(
          'Descripción',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              TextField(
                controller: descriptionController,
                maxLines: null,
                maxLength: maxDescriptionLength,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Descripción general del producto...',
                ),
                buildCounter: (
                  BuildContext context, {
                  required int currentLength,
                  required int? maxLength,
                  required bool isFocused,
                }) {
                  return null;
                },
                onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: descriptionController,
                  builder: (context, value, child) {
                    final descriptionLength = value.text.length;
                    return Text(
                      '$descriptionLength/$maxDescriptionLength',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}