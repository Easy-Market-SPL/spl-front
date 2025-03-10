import 'package:flutter/material.dart';
import 'package:spl_front/bloc/ui_management/address/address_bloc.dart';
import 'package:spl_front/models/ui/credit_card/credit_card_model.dart';
import 'package:spl_front/models/ui/stripe/stripe_custom_response.dart';
import 'package:spl_front/utils/strings/cart_strings.dart';
import 'package:spl_front/utils/strings/payment_strings.dart';

import '../../../services/gui/stripe/stripe_service.dart';

class Total extends StatelessWidget {
  final double total;
  final PaymentCardModel? card;
  final Address? address;

  const Total({super.key, required this.total, this.card, this.address});

  void _showSelectCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              PaymentStrings.selectCard,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: const Text(
            PaymentStrings.selectCardBeforePayment,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text(
                  PaymentStrings.accept,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              PaymentStrings.processingPayment,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 10),
              CircularProgressIndicator(
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                PaymentStrings.waitAMoment,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _processPayment(BuildContext context) async {
    if (card == null) {
      _showSelectCardDialog(context);
      return;
    }

    _showLoadingDialog(context);

    final stripeService = StripeService();
    final amount = (total * 100).round().toString();

    final StripeCustomReponse response =
        await stripeService.payWithExistingCard(
      amount: amount,
      currency: 'usd',
      card: card!,
    );

    // Close the loading dialog
    Navigator.pop(context);

    if (response.ok) {
      // Show success dialog and redirect to tracking order page
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Center(
              child: Text(
                PaymentStrings.successPayment,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.blue, size: 50),
                SizedBox(height: 10),
                Text(
                  PaymentStrings.confirmPaymentAssertion,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      Navigator.pop(context); // Close the dialog

      // TODO: Redirect to the tracking order page
      Navigator.of(context).pushReplacementNamed('customer_dashboard');
    } else {
      // Mostrar mensaje de error
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Center(
              child: Text(
                PaymentStrings.errorInPayment,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  response.msg ?? PaymentStrings.unknownError,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(120, 45),
                  ),
                  child: const Text(
                    PaymentStrings.accept,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PaymentStrings.total,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _processPayment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 93, 180),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(CartStrings.confirmPaymentButton,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
