import 'package:flutter/material.dart';

import '../../../../../models/product_models/labels/label.dart';

class ProductDetailsLabels extends StatelessWidget {
  final List<Label> labels;

  const ProductDetailsLabels({
    super.key,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: labels
              .map((label) => Chip(
                    label: Text(label.name,
                        style: const TextStyle(color: Colors.blue)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
