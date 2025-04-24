import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/details/product_details_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/details/product_details_event.dart';
import 'package:spl_front/bloc/ui_management/product/details/product_details_state.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/product_view_app_bar.dart';
import 'package:spl_front/widgets/products/product_add_to_cart.dart';
import 'package:spl_front/widgets/products/view/color/product_color_selection.dart';
import 'package:spl_front/widgets/products/view/details/product_details_image.dart';
import 'package:spl_front/widgets/products/view/details/product_details_info.dart';
import 'package:spl_front/widgets/products/view/details/product_details_labels.dart';
import 'package:spl_front/widgets/products/view/details/product_details_variants.dart';
import 'package:spl_front/widgets/reviews/review_creation.dart';
import 'package:spl_front/widgets/reviews/reviews_list.dart';

class ViewProductDetailsPage extends StatefulWidget {
  final UserType userType;
  final Product product;

  const ViewProductDetailsPage(
      {super.key, required this.product, required this.userType});

  @override
  State<ViewProductDetailsPage> createState() => _ViewProductDetailsPageState();
}

class _ViewProductDetailsPageState extends State<ViewProductDetailsPage> {
  // Track selected color and variant options
  ProductColor? selectedColor;
  Map<String, String> selectedVariantOptions = {};

  @override
  void initState() {
    super.initState();
    // Load product details when page initializes
    context.read<ProductDetailsBloc>().add(LoadProductDetails(widget.product.code));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is a customer to determine if cart functionality should be shown
    final bool isCustomer = widget.userType == UserType.customer;

    return Scaffold(
      appBar: ProductViewAppBar(
        appBarTittle: ProductStrings.productDetails,
        userType: widget.userType,
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductDetailsError) {
            return Center(child: Text(state.message));
          } else if (state is ProductDetailsLoaded) {
            return _buildProductDetails(context, state, isCustomer);
          } else {
            // Fallback or initial state
            return const Center(
                child: Text(ProductStrings.productLoadingError));
          }
        },
      ),
    );
  }

  Widget _buildProductDetails(
      BuildContext context, ProductDetailsLoaded state, bool isCustomer) {
    return Column(
      children: [
        // Scrollable part of the screen
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ProductImageDisplay(imagePath: state.product.imagePath),

                // Color selection (only show if colors are available)
                if (state.colors.isNotEmpty) ...[
                  ProductColorSelector(
                    colors: state.colors,
                    selectedColor: selectedColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // Product info header (name, code, rating, description)
                ProductDetailsInfo(product: state.product),

                // Tags (only show if labels are available)
                if (state.labels.isNotEmpty) ...[
                  ProductDetailsLabels(labels: state.labels),
                  const SizedBox(height: 16),
                ],

                // Variants (only show if variants are available)
                if (state.variants.isNotEmpty) ...[
                  ProductDetailsVariants(
                    variants: state.variants,
                    selectedOptions: selectedVariantOptions,
                    onOptionSelected: (variantName, optionName) {
                      setState(() {
                        selectedVariantOptions[variantName] = optionName;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // TODO: (PELADO) Implementar reseñas
                // Reviews section
                if (SPLVariables.isRated) ...[
                  const ReviewsWidget(),
                  const SizedBox(height: 16),
                  
                  if (isCustomer) const WriteReviewWidget(),
                ],
              ],
            ),
          ),
        ),

        // Add to cart bar - only show for customers
        if (isCustomer)
          AddToCartBar(
            price: state.product.price.toString(),
            onAddToCart: (quantity) => _handleAddToCart(quantity, state),
          ),
      ],
    );
  }
 // TODO: (PELADO) Implementar añadir al carrito
  void _handleAddToCart(int quantity, ProductDetailsLoaded state) {
    // Verify all required selections are made
    if (state.colors.isNotEmpty && selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleccione un color"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if all variants have a selection
    for (var variant in state.variants) {
      if (!selectedVariantOptions.containsKey(variant.name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Seleccione una opción de ${variant.name}"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // If we get here, all selections have been made
    // This is where you would call the backend API to add to cart
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto añadido'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
