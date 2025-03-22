import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/widgets/products/cards/customer_product_card.dart';
import 'package:spl_front/widgets/products/grids/product_grid.dart';

class CustomerProductGrid extends StatelessWidget {
  final List<Product> products;

  CustomerProductGrid({super.key, List<Product>? productsList}) 
      : products = productsList ?? [];

  @override
  Widget build(BuildContext context) {
    return ProductGrid(
      products: products,
      cardBuilder: (product) => CustomerProductCard(product: product),
    );
  }
}
