import 'package:flutter/material.dart';
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/data/variant.dart';
import 'package:spl_front/models/data/variant_option.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/widgets/app_bars/customer_user_app_bar.dart';
import 'package:spl_front/widgets/products/product_add_to_cart.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/widgets/products/view/color/product_color_selection.dart';
import 'package:spl_front/widgets/products/view/details/product_details_image.dart';
import 'package:spl_front/widgets/products/view/details/product_details_info.dart';
import 'package:spl_front/widgets/products/view/details/product_details_labels.dart';
import 'package:spl_front/widgets/products/view/details/product_details_variants.dart';
import 'package:spl_front/widgets/reviews/review_creation.dart';
import 'package:spl_front/widgets/reviews/reviews_list.dart';

class ViewProductDetailsPage extends StatefulWidget {
  final Product product;

  const ViewProductDetailsPage({super.key, required this.product});

  @override
  State<ViewProductDetailsPage> createState() => _ViewProductDetailsPageState();
}

class _ViewProductDetailsPageState extends State<ViewProductDetailsPage> {
  // Track selected color and variant options
  ProductColor? selectedColor;
  Map<String, String> selectedVariantOptions = {};
  
  // Demo data - in a real app these would come from the product
  late List<ProductColor> availableColors;
  late List<Variant> availableVariants;
  late List<Label> availableLabels;

  @override
  void initState() {
    super.initState();
    // Initialize with sample data - this would come from API
    availableColors = [
      ProductColor(idColor: 1, name: 'Red', hexCode: '#F44336'),
      ProductColor(idColor: 2, name: 'Blue', hexCode: '#2196F3'),
      ProductColor(idColor: 3, name: 'Green', hexCode: '#4CAF50'),
    ];

    availableLabels = [
      Label(idLabel: 1, name: 'Label 1', description: ''),
      Label(idLabel: 3, name: 'Label 3', description: ''),
      Label(idLabel: 2, name: 'Label 2', description: ''),
    ];
    
    availableVariants = [
      Variant(
        name: "Size",
        options: [
          VariantOption(name: "Small"), 
          VariantOption(name: "Medium"), 
          VariantOption(name: "Large"),
        ],
      ),
      Variant(
        name: "Material",
        options: [
          VariantOption(name: "Cotton"), 
          VariantOption(name: "Polyester"), 
          VariantOption(name: "Blend"),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomerUserAppBar(
        hintText: BusinessStrings.searchHint,
        onFilterPressed: () {},
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Scrollable part of the screen
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ProductImageDisplay(imagePath: widget.product.imagePath),
                  
                  // Color selection
                  ProductColorSelector(
                    colors: availableColors,
                    selectedColor: selectedColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Product info header (name, code, rating, description)
                  ProductDetailsInfo(product: widget.product),

                  // Tags
                  ProductDetailsLabels(labels: availableLabels,),
                  const SizedBox(height: 16),

                  // Variants
                  ProductDetailsVariants(
                    variants: availableVariants,
                    selectedOptions: selectedVariantOptions,
                    onOptionSelected: (variantName, optionName) {
                      setState(() {
                        selectedVariantOptions[variantName] = optionName;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Reviews section
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
            price: widget.product.price,
            onAddToCart: _handleAddToCart,
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(int quantity) {
    // Verify all required selections are made
    if (selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleccione un color"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if all variants have a selection
    for (var variant in availableVariants) {
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