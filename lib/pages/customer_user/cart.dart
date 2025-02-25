import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_bloc.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_state.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_event.dart';
import 'package:spl_front/utils/strings/cart_strings.dart';
import 'package:spl_front/widgets/cart/cart_item.dart';
import 'package:spl_front/widgets/cart/cart_subtotal.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartBloc()..add(LoadCart()),
      child: CartPage(),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildCartHeader(context),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator(color: Colors.blue));
            }
            return state.items.isEmpty ? _buildEmptyCart(context) : _buildCartWithItems(state.items, context);
          },
        ),
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              CartStrings.cartTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Text(
                    CartStrings.emptyCartMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
        Subtotal(subtotal: 0, isEmpty: true),
      ],
    );
  }

  Widget _buildCartWithItems(List<Map<String, dynamic>> items, BuildContext context) {
    double subtotal = items.fold(0, (sum, item) => sum + item['price'] * item['quantity']);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CartItem(item: items[index]);
            },
          ),
        ),
        _buildClearCartButton(context),
        Subtotal(subtotal: subtotal),
      ],
    );
  }

  Widget _buildClearCartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          context.read<CartBloc>().add(ClearCart());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 220, 76, 92),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(CartStrings.clearCartButton, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}