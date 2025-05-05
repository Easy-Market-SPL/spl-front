import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/pages/business_user/product_form.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/cards/product_card.dart';

import '../../../../bloc/product_blocs/products_management/product_bloc.dart';
import '../../../../bloc/product_blocs/products_management/product_event.dart';
import '../../../../models/helpers/intern_logic/user_type.dart';
import '../../../../models/product_models/product.dart';
import '../../../../utils/ui/format_currency.dart';

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
                builder: (context) =>
                    ProductFormPage(product: product, isEditing: true),
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
                formatCurrency(product.price),
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
