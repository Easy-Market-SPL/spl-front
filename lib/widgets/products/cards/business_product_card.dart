import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_event.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/business_user/product_form.dart';
import 'package:spl_front/utils/prices/price_formatter.dart';
import 'package:spl_front/widgets/products/cards/product_card.dart';

class BusinessProductCard extends StatelessWidget {
  final Product product;

  const BusinessProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      userType: UserType.business,
      product: product,
      priceButton: SizedBox(
        width: double.infinity,
        height: 43,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductFormPage(product: product, isEditing: true),
              ),
            // Refresh products after editing
            ).then((result) {
              if (result == true) {
                context.read<ProductBloc>().add(RefreshProducts());
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Text
              Text(
                PriceFormatter.formatPrice(product.price),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Edit Icon Button
              Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
