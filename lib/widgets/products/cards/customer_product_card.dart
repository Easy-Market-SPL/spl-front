import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/product/product_details.dart';
import 'package:spl_front/widgets/products/cards/product_card.dart';

class CustomerProductCard extends StatelessWidget {
  final Product product;

  const CustomerProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      userType: UserType.customer,
      product: product,
      priceButton: SizedBox(
        width: double.infinity,
        height: 43,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewProductDetailsPage(
                  product: product,
                  userType: UserType.customer,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
          ),
          child: Text(
            '\$ ${product.price}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
