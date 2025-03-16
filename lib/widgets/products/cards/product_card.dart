import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/spl/spl_variables.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Widget? priceButton;
  
  const ProductCard({
    super.key,
    required this.product,
    this.priceButton,
  });
  
  @override
  Widget build(BuildContext context) {
    
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final double aspectRatio = SPLVariables.isRated && product.rating != null ? 0.60 : 0.65;
    
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: product.imagePath.isNotEmpty
                  ? Image.network(
                      product.imagePath,
                      height: screenWidth * (1 / 3.5),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/images/empty_background.jpg",
                      height: screenWidth * (1 / 3.5),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
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
                        if (SPLVariables.isRated && product.rating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                "${product.rating}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description
                    Expanded(
                      child: Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Price Button (customizable per card type)
            priceButton ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}