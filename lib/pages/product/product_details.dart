import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
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

import '../../bloc/ui_management/address/address_bloc.dart';
import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_event.dart';
import '../../bloc/ui_management/product/details/product_details_bloc.dart';
import '../../bloc/ui_management/product/details/product_details_event.dart';
import '../../bloc/ui_management/product/details/product_details_state.dart';
import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/order_models/order_product.dart';
import '../../widgets/reviews/review_creation.dart';
import '../../widgets/reviews/reviews_list.dart';

class ViewProductDetailsPage extends StatefulWidget {
  final UserType userType;
  final Product product;

  const ViewProductDetailsPage(
      {super.key, required this.product, required this.userType});

  @override
  State<ViewProductDetailsPage> createState() => _ViewProductDetailsPageState();
}

class _ViewProductDetailsPageState extends State<ViewProductDetailsPage> {
  ProductColor? selectedColor;
  Map<String, String> selectedVariantOptions = {};

  @override
  void initState() {
    super.initState();
    context
        .read<ProductDetailsBloc>()
        .add(LoadProductDetails(widget.product.code));
  }

  @override
  Widget build(BuildContext context) {
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
            return const Center(child: CustomLoading());
          } else if (state is ProductDetailsError) {
            return Center(child: Text(state.message));
          } else if (state is ProductDetailsLoaded) {
            return _buildProductDetails(context, state, isCustomer);
          } else {
            return const Center(child: Text("Error loading product details"));
          }
        },
      ),
    );
  }

  Widget _buildProductDetails(
      BuildContext context, ProductDetailsLoaded state, bool isCustomer) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImageDisplay(imagePath: state.product.imagePath),
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
                ProductDetailsInfo(product: state.product),
                if (state.labels.isNotEmpty) ...[
                  ProductDetailsLabels(labels: state.labels),
                  const SizedBox(height: 16),
                ],
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

                // Reviews section
                if (SPLVariables.isRated) ...[
                  ReviewsWidget(
                      product: widget.product, userType: widget.userType),
                  const SizedBox(height: 16),
                  if (isCustomer) WriteReviewWidget(product: widget.product),
                ],
              ],
            ),
          ),
        ),
        if (isCustomer)
          AddToCartBar(
            productPrice: state.product.price,
            onAddToCart: (quantity) => _handleAddToCart(quantity, state),
          ),
      ],
    );
  }

  // Handle Add to Cart functionality
  void _handleAddToCart(int quantity, ProductDetailsLoaded state) {
    if (state.colors.isNotEmpty && selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleccione un color"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
              idOrder: 0, // New order will be created if it doesn't exist
            ),
            productCode: state.product.code,
            quantity: quantity,
            userId: userId,
            address: address,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto añadido al carrito'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
