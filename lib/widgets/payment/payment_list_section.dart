import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/payment/add_payment_dialog.dart';
import 'package:spl_front/widgets/payment/payment_method_card.dart';

class PaymentMethodsSection extends StatelessWidget {
  const PaymentMethodsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> paymentMethods = [
      {
        "type": ProfileStrings.paymentCard,
        "details": "Mastercard *1234",
        "icon": "assets/images/payment_card.jpg"
      },
      {
        "type": ProfileStrings.paymentCard,
        "details": "Visa *5678",
        "icon": "assets/images/payment_card.jpg"
      },
      {
        "type": ProfileStrings.paymentPlatform,
        "details": "Stripe",
        "icon": "assets/images/stripe.png"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          ProfileStrings.paymentMethods,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          ProfileStrings.managePaymentMethods,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: paymentMethods.length,
            itemBuilder: (context, index) {
              final method = paymentMethods[index];
              return PaymentMethodCard(
                type: method["type"]!,
                details: method["details"]!,
                iconPath: method["icon"]!,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AddPaymentDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text(
                ProfileStrings.add,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
