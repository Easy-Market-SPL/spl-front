// lib/widgets/reviews_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_state.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/product_models/reviews/review.dart';
import 'package:spl_front/widgets/logic_widgets/reviews_widgets/review_creation.dart';

import '../../../bloc/product_blocs/products_management/product_bloc.dart';
import '../../../bloc/product_blocs/products_management/product_event.dart';
import '../../../models/helpers/intern_logic/user_type.dart';
import '../../../models/product_models/product.dart';
import '../../../models/users_models/user.dart';
import '../../../services/api_services/review_service/review_service.dart';
import '../../../services/api_services/user_service/user_service.dart';

class ReviewsWidget extends StatefulWidget {
  final Product product;
  final UserType userType;

  const ReviewsWidget({
    super.key,
    required this.product,
    required this.userType,
  });

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  // Cache for user data
  final Map<String, UserModel?> _userCache = {};
  final Map<int, Widget> _reviewCardCache = {};
  
  // Review data caching
  List<Review>? _cachedReviews;
  List<Widget>? _cachedCustomerReviews;
  List<Widget>? _cachedVisitorReviews;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _preloadUserData();
    _initializeCache();
  }

  void _initializeCache() {
    // We'll initialize cache on first build
    if (widget.product.reviews != null && !_initialized) {
      _processReviewsForCache(widget.product.reviews!);
    }
  }
  
  void _processReviewsForCache(List<Review> reviews) {
    _cachedReviews = reviews;
    
    // Build all review cards upfront and store in cache
    final purchasedReviews = reviews.where((r) => r.purchasedReview == true).toList();
    final nonPurchasedReviews = reviews.where((r) => r.purchasedReview == false).toList();
    
    if (purchasedReviews.isNotEmpty) {
      _cachedCustomerReviews = purchasedReviews.map((r) {
        final key = r.id ?? DateTime.now().millisecondsSinceEpoch;
        _reviewCardCache[key] = _buildReviewCard(context, r);
        return _reviewCardCache[key]!;
      }).toList();
    }
    
    if (nonPurchasedReviews.isNotEmpty) {
      _cachedVisitorReviews = nonPurchasedReviews.map((r) {
        final key = r.id ?? DateTime.now().millisecondsSinceEpoch;
        _reviewCardCache[key] = _buildReviewCard(context, r);
        return _reviewCardCache[key]!;
      }).toList();
    }
    
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProductDetailsBloc, ProductDetailsState, List<Review>?>(
      selector: (state) {
        if (state is ProductDetailsLoaded) {
          try {
            final product = state.product;
            return product.reviews;
          } catch (e) {
            return widget.product.reviews;
          }
        }
        return widget.product.reviews;
      },
      builder: (context, reviews) {
        // If reviews changed from our cached version, rebuild cache
        if (reviews != null && 
            (_cachedReviews == null || 
             _cachedReviews!.length != reviews.length ||
             _reviewsChanged(_cachedReviews!, reviews))) {
          _processReviewsForCache(reviews);
        }
        
        if (reviews == null || reviews.isEmpty) {
          return const Text(
            'El producto no cuenta con reseñas aún',
            style: TextStyle(
              fontSize: 16,
              fontFamilyFallback: ['Roboto'],
              fontStyle: FontStyle.italic,
            ),
          );
        }

        // Return cached UI
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cachedCustomerReviews == null || _cachedCustomerReviews!.isEmpty
                ? const SizedBox.shrink()
                : _buildCachedCustomersReviews(),
            const SizedBox(height: 4),
            _cachedVisitorReviews == null || _cachedVisitorReviews!.isEmpty
                ? const SizedBox.shrink()
                : _buildCachedVisitorsReviews(),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    final session = context.read<UsersBloc>().state.sessionUser;
    final myUserId = session?.id;
    final rating = review.calification ?? 0.0;
    final commentary = review.commentary ?? '';

    // Determine actions
    final actions = <Widget>[];
    if (widget.userType == UserType.business || widget.userType == UserType.admin) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
          onPressed: () => _confirmDelete(context, review.id!),
        ),
      );
    }
    // allow customers to edit or delete their own review
    if (widget.userType == UserType.customer && review.idUser == myUserId) {
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
                        future: _getUser(review.idUser!),
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

  // Cached user data fetch
  Future<UserModel?> _getUser(String userId) async {
    // Return from cache if available
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    
    // Otherwise fetch and cache
    final user = await UserService.getUser(userId);
    if (user != null) {
      _userCache[userId] = user;
    }
    return user;
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
                    .add(RemoveReview(widget.product.code, reviewId));
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
          product: widget.product,
          idReview: review.id,
          previousRating: review.calification,
        ),
      ),
    );
  }

  void _preloadUserData() async {
    // Get all unique user IDs from reviews
    final uniqueUserIds = <String>{}; 
    final reviews = widget.product.reviews ?? [];

    for (final review in reviews) {
      if (review.idUser != null) {
        uniqueUserIds.add(review.idUser!);
      }
    }

    // Preload all users in parallel
    await Future.wait(
      uniqueUserIds.map((id) => _getUser(id))
    );
  }

  bool _reviewsChanged(List<Review> oldReviews, List<Review> newReviews) {
    if (oldReviews.length != newReviews.length) return true;
    
    for (int i = 0; i < oldReviews.length; i++) {
      if (oldReviews[i].id != newReviews[i].id ||
          oldReviews[i].commentary != newReviews[i].commentary ||
          oldReviews[i].calification != newReviews[i].calification) {
        return true;
      }
    }
    return false;
  }

  Widget _buildCachedCustomersReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reseñas Compradores: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._cachedCustomerReviews!,
      ],
    );
  }

  Widget _buildCachedVisitorsReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reseñas Visitantes: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._cachedVisitorReviews!,
      ],
    );
  }
}
