// lib/widgets/reviews_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_event.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_state.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/review.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/models/user.dart';
import 'package:spl_front/services/api/review_service.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/reviews/review_creation.dart';

class ReviewsWidget extends StatelessWidget {
  final Product product;
  final UserType userType;

  const ReviewsWidget({
    super.key,
    required this.product,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        var reviews = state is ProductLoaded
            ? state.products
                .firstWhere((p) => p.code == product.code,
                    orElse: () => product)
                .reviews
            : product.reviews;

        final purchasedReviews =
            reviews?.where((review) => review.purchasedReview == true).toList();

        final nonPurchasedReviews = reviews
            ?.where((review) => review.purchasedReview == false)
            .toList();

        if (reviews == null || state is ProductLoading) {
          return const CustomLoading();
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
            purchasedReviews == null || purchasedReviews.isEmpty
                ? const SizedBox.shrink()
                : _buildCustomersReviews(context, purchasedReviews),
            const SizedBox(height: 8),
            nonPurchasedReviews == null || nonPurchasedReviews.isEmpty
                ? const SizedBox.shrink()
                : _buildVisitorsReviews(context, nonPurchasedReviews),
          ],
        );
      },
    );
  }

  Widget _buildCustomersReviews(
      BuildContext context, List<Review> purchasedReviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clientes: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...purchasedReviews.map((r) => _buildReviewCard(context, r)),
      ],
    );
  }

  Widget _buildVisitorsReviews(
      BuildContext context, List<Review> nonPurchasedReviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visitantes: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...nonPurchasedReviews.map((r) => _buildReviewCard(context, r)),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    final session = context.read<UsersBloc>().state.sessionUser;
    final myUserId = session?.id;
    final rating = review.calification ?? 0.0;
    final commentary = review.commentary ?? '';

    // Determine actions
    final actions = <Widget>[];
    if (userType == UserType.business || userType == UserType.admin) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
          onPressed: () => _confirmDelete(context, review.id!),
        ),
      );
    }
    // allow customers to edit or delete their own review
    if (userType == UserType.customer && review.idUser == myUserId) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
          onPressed: () => _showEditDialog(context, review),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
          onPressed: () => _confirmDelete(context, review.id!),
        ),
      ]);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
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
                // Name, rating, comment
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<UserModel?>(
                        future: UserService.getUser(review.idUser!),
                        builder: (ctx, snap) {
                          if (snap.connectionState != ConnectionState.done ||
                              snap.data == null) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            snap.data!.fullname,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildStarRating(rating),
                      const SizedBox(height: 6),
                      Text(commentary, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                // Actions at top right
                ...actions,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    final stars = <Widget>[];
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

  void _confirmDelete(BuildContext context, int reviewId) {
    final double dialogWidth = MediaQuery.of(context).size.width / 1.5;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Center(
          child: Text(
            'Eliminar reseña',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: Text(
            '¿Estás seguro de eliminar esta reseña?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
                  dialogWidth * 0.4, MediaQuery.of(context).size.height * 0.05),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
                  dialogWidth * 0.4, MediaQuery.of(context).size.height * 0.05),
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ReviewService.deleteReview(reviewId);
              if (success) {
                context
                    .read<ProductBloc>()
                    .add(RemoveReview(product.code, reviewId));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar reseña.')),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Review review) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar reseña'),
        content: WriteReviewWidget(
          product: product,
          idReview: review.id,
          previousRating: review.calification,
        ),
      ),
    );
  }
}
