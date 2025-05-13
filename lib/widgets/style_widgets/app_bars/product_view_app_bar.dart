import 'package:flutter/material.dart';
import 'package:spl_front/pages/customer_user/cart.dart';

import '../../../models/helpers/intern_logic/user_type.dart';

class ProductViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTittle;
  final UserType userType;

  const ProductViewAppBar({
    super.key,
    required this.appBarTittle,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        appBarTittle,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (userType == UserType.customer)
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
