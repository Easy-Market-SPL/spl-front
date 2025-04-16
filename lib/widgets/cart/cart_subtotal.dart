import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/cart_strings.dart';

import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_state.dart';

class Subtotal extends StatelessWidget {
  final bool isEmpty;

  const Subtotal({super.key, this.isEmpty = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final double subtotal = state.currentCartOrder?.orderProducts?.fold(0.0,
                (sum, item) => sum! + item.product!.price * item.quantity) ??
            0.0;
        return Column(
          children: [
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CartStrings.subtotal,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pushNamed('customer_payment');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEmpty
                        ? Colors.grey
                        : const Color.fromARGB(255, 0, 93, 180),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(CartStrings.checkoutButton,
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
