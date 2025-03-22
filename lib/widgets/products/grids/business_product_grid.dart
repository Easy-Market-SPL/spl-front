import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/widgets/products/cards/business_product_card.dart';
import 'package:spl_front/widgets/products/grids/product_grid.dart';

class BusinessProductGrid extends StatelessWidget {
  final List<Product> products;

  BusinessProductGrid({super.key, List<Product>? productsList}) 
      : products = productsList ?? [];

  @override
  Widget build(BuildContext context) {
    return ProductGrid(
      products: products,
      cardBuilder: (product) => BusinessProductCard(product: product),
    );
  }
}
