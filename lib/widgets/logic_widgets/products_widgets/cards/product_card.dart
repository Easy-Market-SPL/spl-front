import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/pages/product/product_details.dart';
import 'package:spl_front/pages/product/web/product_details_web.dart';
import 'package:spl_front/spl/spl_variables.dart';

import '../../../../models/helpers/intern_logic/user_type.dart';
import '../../../../models/product_models/product.dart';

class ProductCard extends StatelessWidget {
  final UserType userType;
  final Product product;
  final Widget? priceButton;

  const ProductCard({
    super.key,
    required this.userType,
    required this.product,
    this.priceButton,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (kIsWeb) {
          showProductDetailsWeb(
            context,
            product: product,
            userType: userType,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProductDetailsPage(
                product: product,
                userType: userType,
              ),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: product.imagePath.isNotEmpty
                    ? Image.network(
                        product.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'Error loading product image: ${product.code} - $error');
                          return Image.asset(
                            "assets/images/empty_background.jpg",
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        "assets/images/empty_background.jpg",
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Product Reference + Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Product Reference
                        Expanded(
                          child: Text(
                            product.code,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Product Rating
                        if (SPLVariables.isRated &&
                            product.rating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                product.rating == 0
                                    ? '--'
                                    : product.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Description
                    Expanded(
                      child: Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: kIsWeb ? 3 : 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Price Button
            if (priceButton != null) SizedBox(height: 44, child: priceButton!),
          ],
        ),
      ),
    );
  }
}
