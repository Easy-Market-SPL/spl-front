import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/bloc/ui_management/order/order_state.dart';
import 'package:spl_front/widgets/cart/cart_item.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';

import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/logic/user_type.dart';
import '../../models/order_models/order_product.dart';
import '../../utils/strings/cart_strings.dart';
import '../../widgets/cart/cart_subtotal.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    final ordersBloc = context.read<OrdersBloc>();
    final usersBloc = context.read<UsersBloc>();
    // Ensure sessionUser is not null before accessing id
    final userId = usersBloc.state.sessionUser?.id;

    if (userId != null) {
      ordersBloc.add(LoadOrdersEvent(userId: userId, userRole: 'customer'));
    } else {
      // Handle case where user ID is not available, maybe navigate to login
      debugPrint("Error: User ID not found in initState of CartPage.");
      // Optionally, show an error message or navigate away
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildCartHeader(context),
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent, // Optional: Customize appearance
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
            16.0, 0, 16.0, 16.0), // Adjust top padding if needed
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.blue));
            }

            // Check condition for showing items: Loaded state, non-null cart, non-empty items list
            if (state is OrdersLoaded &&
                state.currentCartOrder != null &&
                state.currentCartOrder!.orderProducts != null &&
                state.currentCartOrder!.orderProducts!.isNotEmpty) {
              // Pass the non-nullable list
              return _buildCartWithItems(
                  state.currentCartOrder!.orderProducts!, context);
            } else {
              // In all other cases (Initial, Error, Loaded but empty/null cart), show empty cart
              // Optionally handle OrdersError distinctly if needed
              // if (state is OrdersError) { return Center(child: Text('Error: ${state.message}'));}
              return _buildEmptyCart(context);
            }
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
      alignment: Alignment.center, // Center the title easily
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
            padding: EdgeInsets.zero, // Remove default padding
            constraints: BoxConstraints(), // Remove default constraints
          ),
        ),
        Padding(
          // Ensure title doesn't overlap the button if too long
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            CartStrings.cartTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Handle long titles
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // Use Expanded to take available space
          child: Center(
            child: SingleChildScrollView(
              // Allow scrolling if content overflows on small screens
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                      Icons
                          .shopping_cart_outlined, // Use outlined version perhaps
                      size: 80,
                      color: Colors.grey),
                  const SizedBox(height: 24), // Increased spacing
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      CartStrings.emptyCartMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                      height: 24), // Add space before potential actions
                  // Optional: Add a button to go back to shopping
                  // ElevatedButton(
                  //   onPressed: () { /* Navigate to products page */ },
                  //   child: Text('Seguir Comprando'),
                  // )
                ],
              ),
            ),
          ),
        ),
        // Subtotal should be outside the Expanded/Center part
        const Subtotal(isEmpty: true),
      ],
    );
  }

  Widget _buildCartWithItems(List<OrderProduct> items, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              // Use a key for better list item identification if needed
              return CartItem(key: ValueKey(item.idProduct), item: item);
            },
          ),
        ),
        // Place buttons and subtotal below the list
        _buildClearCartButton(context),
        const SizedBox(height: 8), // Add spacing
        const Subtotal(), // Assuming this needs no parameters when not empty
      ],
    );
  }

  Widget _buildClearCartButton(BuildContext context) {
    return SizedBox(
      // Use SizedBox to control width if needed
      width: double.infinity, // Make button full width
      child: ElevatedButton(
        onPressed: () {
          context.read<OrdersBloc>().add(ClearCartEvent());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color.fromARGB(255, 239, 83, 80), // Standard Material red
          foregroundColor: Colors.white, // Text color
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)), // Slightly less rounded
          padding: const EdgeInsets.symmetric(vertical: 12), // Adjust padding
        ),
        child: Text(
          CartStrings.clearCartButton,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500), // Adjust text style
        ),
      ),
    );
  }
}
