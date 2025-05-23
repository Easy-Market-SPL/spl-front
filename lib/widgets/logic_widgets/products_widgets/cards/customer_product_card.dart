import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/pages/product/product_details.dart';
import 'package:spl_front/pages/product/web/product_details_web.dart';
import 'package:spl_front/utils/ui/format_currency.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/cards/product_card.dart';

import '../../../../models/helpers/intern_logic/user_type.dart';
import '../../../../models/product_models/product.dart';

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
            if (!kIsWeb){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProductDetailsPage(
                    product: product,
                    userType: UserType.customer,
                  ),
                ),
              );
            } else{
              showProductDetailsWeb(
                context,
                product: product,
                userType: UserType.customer,
              );
            }
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
            formatCurrency(product.price),
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
