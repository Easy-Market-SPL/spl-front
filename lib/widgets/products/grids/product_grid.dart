import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product.dart';

typedef ProductCardBuilder = Widget Function(Product product);

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ProductCardBuilder cardBuilder;

  const ProductGrid({
    super.key,
    required this.products,
    required this.cardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final crossAxisCount = kIsWeb
          ? (width ~/ 200).clamp(2, 6)  // at least 2 and at most 6 columns
          : 2;                          // mobile layout with 2 columns
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return cardBuilder(products[index]);
        },
      );
    });
  }
}