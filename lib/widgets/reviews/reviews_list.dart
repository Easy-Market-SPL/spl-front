// lib/widgets/reviews_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_state.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/review.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

class ReviewsWidget extends StatelessWidget {
  final Product product;
  const ReviewsWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final reviews = state is ProductLoaded
            ? state.products
                .firstWhere((p) => p.code == product.code,
                    orElse: () => product)
                .reviews
            : product.reviews;

        if (reviews == null) {
          return const Center(child: CustomLoading());
        }
        if (reviews.isEmpty) {
          return const Text(
            'El producto no cuenta con reseñas aún',
            style: TextStyle(
              fontSize: 16,
              fontFamilyFallback: ['Roboto'],
              fontStyle: FontStyle.italic,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reseñas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...reviews.map((r) => _buildReviewCard(r)),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    final userId = review.idUser ?? '';
    final rating = review.calification ?? 0.0;
    final commentary = review.commentary ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder(
                        future: UserService.getUser(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                                  ConnectionState.done ||
                              !snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final fullName =
                              snapshot.data?.fullname ?? 'Desconocido';
                          return Flexible(
                            child: Text(
                              fullName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                      _buildStarRating(rating),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(commentary, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    List<Widget> stars = [];
    for (var i = 0; i < full; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (half) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
    }
    return Row(children: stars);
  }
}
