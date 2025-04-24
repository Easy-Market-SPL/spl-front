// lib/widgets/product_details_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_state.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

class ProductDetailsInfo extends StatelessWidget {
  final Product product;

  const ProductDetailsInfo({
    super.key,
    required this.product,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const CustomLoading();
        }
        final productInState = (state is ProductLoaded
            ? state.products.firstWhere((p) => p.code == product.code,
                orElse: () => product)
            : product);

        final double? rating = productInState.rating;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('REF: ${product.code}',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            if (SPLVariables.isRated) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  // Solo N/A si rating es null
                  Text(
                    rating == null ? 'N/A' : rating.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  // Pinta estrellas solo si rating existe
                  if (rating != null) ..._buildStarIcons(rating),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(product.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<Widget> _buildStarIcons(double rating) {
    final int fullStars = rating.floor();
    final bool halfStar = (rating - fullStars) >= 0.5;
    final stars = <Widget>[];
    for (var i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (halfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
    }
    return stars;
  }
}
