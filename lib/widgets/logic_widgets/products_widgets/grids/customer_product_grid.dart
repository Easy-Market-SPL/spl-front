import 'package:flutter/material.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/grids/product_grid.dart';

import '../../../../models/product_models/product.dart';
import '../cards/customer_product_card.dart';

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
