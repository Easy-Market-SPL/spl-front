import 'package:flutter/material.dart';

class ShippingGuide extends StatelessWidget {
  final String orderNumber;
  final String estimatedDeliveryDate;

  const ShippingGuide({
    super.key,
    required this.orderNumber,
    required this.estimatedDeliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Número de orden: #$orderNumber',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Fecha de entrega estimada: $estimatedDeliveryDate',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}