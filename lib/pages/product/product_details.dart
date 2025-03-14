import 'package:flutter/material.dart';
import 'package:spl_front/widgets/products/product_add_to_cart.dart';
import 'package:spl_front/widgets/reviews/review_creation.dart';
import 'package:spl_front/widgets/reviews/reviews_list.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/widgets/app_bars/customer_user_app_bar.dart';

// Replace these with your own model or remove them if you use real data
class ProductVariant {
  final String variantName;
  final List<String> options;

  ProductVariant(this.variantName, this.options);
}

/// Main screen that shows the product detail.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  void _handleAddToCart(int quantity) {
    // TODO: Implement cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agregado $quantity items al carrito')),
    );
  }

  // Dummy data for variants
  final List<ProductVariant> _variants = [
    ProductVariant("Variante 1", ["Op 1", "Op 2", "Op 3"]),
    ProductVariant("Variante 2", ["Op 1", "Op 2", "Op 3", "Op 4"]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomerUserAppBar(
        hintText: BusinessStrings.searchHint,
        onFilterPressed: () {
          // TODO: Implement filters action
        },
      ),
      backgroundColor: Colors.white,
      // We'll use a Stack so we can float the bottom container
      body: Column(
        children: [
          // Esta es la parte scrollable de la pantalla
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text("Imagen del producto")),
                  ),
                  const SizedBox(height: 16),

                  // Product Name + Star Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "Nombre del producto",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Reference code
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "REF: 123456",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    ],
                  ),

                  // Rating if enabled
                  if (SPLVariables.isRated) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text("4.5", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 2),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star_half, color: Colors.amber, size: 18),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Short description
                  Text(
                    "Descripción general del producto Lorem ipsum dolor sit amet, "
                    "consectetur adipiscing elit, sed do eiusmod tempor incididunt "
                    "ut labore et dolore magna aliqua.",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTagChip("Etiqueta 1"),
                      _buildTagChip("Etiqueta 2"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Variants
                  _buildVariantsSection(_variants),
                  const SizedBox(height: 16),

                  // Reviews section if enabled
                  if (SPLVariables.isRated) ...[
                    const ReviewsWidget(),
                    const SizedBox(height: 16),
                    const WriteReviewWidget(),
                  ],
                ],
              ),
            ),
          ),

          // Add to cart bar
          AddToCartBar(
            price: "\$25,000", 
            onAddToCart: _handleAddToCart
          ),
        ],
      ),
    );
  }

  // Tag Chip
  Widget _buildTagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Text(text, style: const TextStyle(color: Colors.blueAccent)),
    );
  }

  // Variants Section
  Widget _buildVariantsSection(List<ProductVariant> variants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Variantes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          children: variants.map((variant) => _buildVariantRow(variant)).toList(),
        ),
      ],
    );
  }

  Widget _buildVariantRow(ProductVariant variant) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildVariantTitleChip(variant.variantName),
          ...variant.options.map((opt) => _buildVariantOptionChip(opt)).toList(),
        ],
      ),
    );
  }

  Widget _buildVariantTitleChip(String title) {
    // e.g. "Variante" chip
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVariantOptionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Text(text, style: const TextStyle(color: Colors.blueAccent)),
    );
  }
}