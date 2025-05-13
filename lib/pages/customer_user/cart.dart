import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/widgets/logic_widgets/order_widgets/cart/cart_item.dart';

import '../../bloc/orders_bloc/order_bloc.dart';
import '../../bloc/orders_bloc/order_event.dart';
import '../../bloc/orders_bloc/order_state.dart';
import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/helpers/intern_logic/user_type.dart';
import '../../models/order_models/order_product.dart';
import '../../utils/strings/cart_strings.dart';
import '../../widgets/helpers/custom_loading.dart';
import '../../widgets/logic_widgets/order_widgets/cart/cart_subtotal.dart';
import '../../widgets/style_widgets/navigation_bars/nav_bar.dart'; // Assuming Subtotal widget is here

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  void _loadCartData() {
    final ordersBloc = context.read<OrdersBloc>();
    final usersBloc = context.read<UsersBloc>();
    final userId = usersBloc.state.sessionUser?.id;

    if (userId != null) {
      ordersBloc.add(LoadOrdersEvent(userId: userId, userRole: 'customer'));
    } else {
      debugPrint("Error: User ID not found in initState of CartPage.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _buildCartHeader(context),
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            bool showLoadingOverlay =
                (state is OrdersLoaded && state.isLoading);
            Widget content;

            if (state is OrdersInitial || state is OrdersLoading) {
              content = const Center(child: CustomLoading());
            } else if (state is OrdersLoaded) {
              final bool hasItems = state.currentCartOrder != null &&
                  state.currentCartOrder!.orderProducts.isNotEmpty;
              content = hasItems
                  ? _buildCartWithItems(
                      state.currentCartOrder!.orderProducts, context)
                  : _buildEmptyCart(context);
            } else if (state is OrdersError) {
              debugPrint("OrdersError state in CartPage: ${state.message}");
              content = _buildEmptyCart(context);
            } else {
              content = _buildEmptyCart(context);
            }

            return Stack(
              children: [
                content,
                if (showLoadingOverlay)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: Center(child: CustomLoading()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        userType: UserType.customer,
        context: context,
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            CartStrings.cartTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    // Build empty cart view.
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      CartStrings.emptyCartMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Subtotal will correctly show 0.00 and disabled button via its own BlocBuilder.
        const Subtotal(isEmpty: true),
      ],
    );
  }

  Widget _buildCartWithItems(List<OrderProduct> items, BuildContext context) {
    // Build cart view with items.
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return CartItem(key: ValueKey(item.idProduct), item: item);
            },
          ),
        ),
        _buildClearCartButton(context),
        const SizedBox(height: 8),
        // Subtotal will correctly show calculated value and enabled button.
        const Subtotal(),
      ],
    );
  }

  Widget _buildClearCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<OrdersBloc>().add(ClearCartEvent());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 239, 83, 80),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          CartStrings.clearCartButton,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
