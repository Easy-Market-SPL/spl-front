import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

import '../../../utils/ui/format_currency.dart';

class AddToCartBar extends StatefulWidget {
  final Function(int quantity) onAddToCart;
  final int initialQuantity;
  final double productPrice;

  const AddToCartBar({
    super.key,
    required this.onAddToCart,
    required this.productPrice,
    this.initialQuantity = 1,
  });

  @override
  State<AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<AddToCartBar> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _updateQuantity(int newQuantity) {
    // Ensure quantity doesn't go below 1
    if (newQuantity >= 1) {
      setState(() {
        _quantity = newQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.productPrice * _quantity;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white70,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Take only needed horizontal space
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _updateQuantity(_quantity - 1),
                    iconSize: 15,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _updateQuantity(_quantity + 1),
                    iconSize: 15,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Price display - Expanded to take available space
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                // FittedBox scales down the text if needed to prevent overflow/ellipsis
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency(totalPrice),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Add to cart button - Takes its required width
            ElevatedButton(
              onPressed: () => widget.onAddToCart(_quantity),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // Adjust horizontal padding as needed
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              child: Text(
                ProductStrings.addToCart, // Assuming this is defined elsewhere
                maxLines: 1, // Prevent button text wrapping if too long
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
