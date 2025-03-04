import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final String type;
  final String details;
  final String iconPath;

  const PaymentMethodCard({
    super.key,
    required this.type,
    required this.details,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(
            iconPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                color: Colors.red,
                size: 30,
              );
            },
          ),
        ),
        title: Text(
          details,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
