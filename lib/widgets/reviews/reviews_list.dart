import 'package:flutter/material.dart';

class ReviewsWidget extends StatelessWidget {
  const ReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final reviews = [
      {
        'userName': 'Nombre de usuario',
        'rating': 4.5,
        'review': 'Reseña del producto Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
      },
      {
        'userName': 'Otro usuario',
        'rating': 5.0,
        'review': 'Otra reseña, lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      },
    ];

    if (reviews.isEmpty) {
      return const Text("Sin reseñas aún");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Reseñas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          children: reviews.map((r) => _buildReviewCard(r)).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    final userName = data['userName'] ?? "Desconocido";
    final double rating = data['rating'] ?? 0.0;
    final reviewText = data['review'] ?? "";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optionally an avatar or icon
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
            // Review content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username + star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildStarRating(rating),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Review text
                  Text(
                    reviewText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    // e.g., 4.5 => 4 full stars + 1 half star
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;

    List<Widget> stars = [];
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
    }
    // If less than 5 stars total, fill the rest with empty
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
    }

    return Row(children: stars);
  }
}
