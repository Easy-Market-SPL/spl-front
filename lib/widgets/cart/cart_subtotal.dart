import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/cart_strings.dart';

class Subtotal extends StatelessWidget {
  final double subtotal;
  final bool isEmpty;

  const Subtotal({super.key, required this.subtotal, this.isEmpty = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(CartStrings.subtotal, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              onPressed: isEmpty ? null : () {
                //TODO: Change this to navigate to payment screen
                Navigator.of(context).pushNamed('customer_dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isEmpty ? Colors.grey : const Color.fromARGB(255, 0, 93, 180),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(CartStrings.checkoutButton, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}