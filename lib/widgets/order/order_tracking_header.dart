import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class OrderTrackingHeader extends StatelessWidget {
  const OrderTrackingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = screenHeight * 0.05;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 10.0, right: 10.0),
      child: Stack(
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
                OrderStrings.orderTrackingTittle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}