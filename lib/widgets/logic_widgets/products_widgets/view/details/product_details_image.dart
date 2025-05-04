import 'package:flutter/material.dart';

class ProductImageDisplay extends StatelessWidget {
  final String imagePath;

  const ProductImageDisplay({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        image: imagePath.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  debugPrint("Error loading product image: $exception");
                },
              )
            : const DecorationImage(
                image: AssetImage("assets/images/empty_background.jpg"),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}