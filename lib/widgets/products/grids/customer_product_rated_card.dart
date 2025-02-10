import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/products/cards/customer_product_rated_card.dart';

class CustomerProductRatedGrid extends StatelessWidget {
  //TODO: Receive the list of products from the provider (Bloc) in connection with the database
  final List<Map<String, dynamic>> products = List.generate(
    10,
    (index) => {
      "name": ProductStrings.productName,
      "reference": ProductStrings.productReference,
      "description": ProductStrings.productDescription,
      "price": ProductStrings.productPrice,
      "image": "assets/images/empty_background.jpg",
    },
  );

  CustomerProductRatedGrid({super.key});

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
        final product = products[index];
        return CustomerProductRatedCard(
          name: product["name"],
          reference: product["reference"],
          description: product["description"],
          price: product["price"],
          imagePath: product["image"],
          rating: 5.0,
        );
      },
    );
  }
}
