import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/products/cards/business_product_card.dart';
import 'package:spl_front/widgets/products/grids/product_grid.dart';

class BusinessProductGrid extends StatelessWidget {
  //TODO: Receive the list of products from the provider (Bloc) in connection with the database
  final List<Product> products;

  BusinessProductGrid({super.key, List<Product>? productsList}) 
      : products = productsList ?? List.generate(
          10,
          (index) => Product(
            code: ProductStrings.productReference,
            name: ProductStrings.productName,
            description: ProductStrings.productDescription,
            price: ProductStrings.productPrice,
            imagePath: "assets/images/empty_background.jpg",
            rating: 4.5,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return ProductGrid(
      products: products,
      cardBuilder: (product) => BusinessProductCard(product: product),
    );
  }
}
