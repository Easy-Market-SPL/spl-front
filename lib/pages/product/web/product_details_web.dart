import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_event.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_state.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/models/product_models/product.dart';
import 'package:spl_front/models/product_models/product_color.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/utils/ui/snackbar_manager_web.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/color/product_color_selection.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/details/product_details_image.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/details/product_details_info.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/details/product_details_labels.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/details/product_details_variants.dart';
import 'package:spl_front/widgets/logic_widgets/reviews_widgets/review_creation_web.dart';
import 'package:spl_front/widgets/logic_widgets/reviews_widgets/reviews_list.dart';
import 'package:spl_front/bloc/orders_bloc/order_bloc.dart';
import 'package:spl_front/bloc/orders_bloc/order_event.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/bloc/users_session_information_blocs/address_bloc/address_bloc.dart';
import 'package:spl_front/models/order_models/order_product.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/product_add_to_cart.dart';

void showProductDetailsWeb(
  BuildContext context, {
  required Product product,
  required UserType userType,
}) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
        child: ProductDetailsWeb(
          product: product,
          userType: userType,
        ),
      ),
    ),
  );
}

class ProductDetailsWeb extends StatefulWidget {
  final Product product;
  final UserType userType;

  const ProductDetailsWeb({
    super.key,
    required this.product,
    required this.userType,
  });

  @override
  State<ProductDetailsWeb> createState() => _ProductDetailsWebState();
}

class _ProductDetailsWebState extends State<ProductDetailsWeb> {
  ProductColor? selectedColor;
  Map<String, String> selectedVariantOptions = {};

  @override
  void initState() {
    super.initState();
    context.read<ProductDetailsBloc>().add(LoadProductDetails(widget.product.code));
  }

  @override
  Widget build(BuildContext context) {
    final bool isCustomer = widget.userType == UserType.customer;

    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, state) {
        Widget body;

        if (state is ProductDetailsLoading) {
          body = const Center(child: CustomLoading());
        } else if (state is ProductDetailsError) {
          body = Center(child: Text(state.message));
        } else if (state is ProductDetailsLoaded) {
          body = _buildProductDetails(context, state, isCustomer);
        } else {
          body = const Center(child: Text("Error loading product details"));
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ProductStrings.productDetails,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Content
              Expanded(child: body),
              
              // Footer - Add to cart button for customers
              if (isCustomer && state is ProductDetailsLoaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(48, 0, 0, 0),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: AddToCartBar(
                    productPrice: state.product.price,
                    onAddToCart: (quantity) => _handleAddToCart(quantity, state),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductDetails(BuildContext context, ProductDetailsLoaded state, bool isCustomer) {
    return SingleChildScrollView(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Product overview with image and basic info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 12),
                // Left: Product image
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 350,
                    child: ProductImageDisplay(imagePath: state.product.imagePath),
                  ),
                ),
                const SizedBox(width: 24),

                // Right: Product info and action area
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Product details section
                      ProductDetailsInfo(product: state.product),

                      // Color selection in horizontal layout
                      if (state.colors.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text("Colores:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ProductColorSelector(
                          colors: state.colors,
                          selectedColor: selectedColor,
                          onColorSelected: (color) => setState(() => selectedColor = color),
                        ),
                      ],

                      // Variants in horizontal layout when possible
                      if (state.variants.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ProductDetailsVariants(
                          variants: state.variants,
                          selectedOptions: selectedVariantOptions,
                          onOptionSelected: (variant, option) => 
                              setState(() => selectedVariantOptions[variant] = option) // Add this property to make variants display more compactly
                        ),
                      ],

                      // Labels as horizontal chips
                      if (state.labels.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ProductDetailsLabels(labels: state.labels),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs for additional content like reviews
          if (SPLVariables.isRated) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Text(
                    "Reseñas",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Fixed height container for reviews instead of Expanded
                  ReviewsWidget(
                      product: widget.product,
                      userType: widget.userType,
                    ),

                  // Review form for customers
                  if (isCustomer) ...[
                    const Divider(),
                    CompactReviewForm(
                      product: widget.product,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      )
    );
  }

  void _handleAddToCart(int quantity, ProductDetailsLoaded state) {
    if (state.colors.isNotEmpty && selectedColor == null) {
      SnackbarManager.showError(context, message: "Seleccione un color");
      return;
    }
  
    for (var variant in state.variants) {
      if (!selectedVariantOptions.containsKey(variant.name)) {
        SnackbarManager.showError(
          context, 
          message: "Seleccione una opción de ${variant.name}"
        );
        return;
      }
    }

    final userId = context.read<UsersBloc>().state.sessionUser!.id;
    final addressBloc = BlocProvider.of<AddressBloc>(context);
    String address = addressBloc.state.addresses.isNotEmpty
        ? addressBloc.state.addresses.first.address
        : '';

    context.read<OrdersBloc>().add(
          AddProductToOrderEvent(
            OrderProduct(
              idProduct: state.product.code,
              quantity: quantity,
              idOrder: 0,
            ),
            productCode: state.product.code,
            quantity: quantity,
            userId: userId,
            address: address,
          ),
        );

    SnackbarManager.showSuccess(context, message: "Producto añadido al carrito");
  
    Navigator.pop(context);
  }
}