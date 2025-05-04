import 'package:flutter/material.dart';

import '../../../../models/product_models/product.dart';

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
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return cardBuilder(products[index]);
      },
    );
  }
}
