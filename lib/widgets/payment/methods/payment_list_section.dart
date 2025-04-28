import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/payment/methods/add_payment_dialog.dart';
import 'package:spl_front/widgets/payment/methods/payment_method_card.dart';

import '../../../bloc/ui_management/payment/payment_bloc.dart';

class PaymentMethodsSection extends StatelessWidget {
  const PaymentMethodsSection({super.key});

  String formatCardNumber(String cardNumber) {
    if (cardNumber.length >= 8) {
      return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber; // En caso de error, muestra el número completo
  }

  @override
  Widget build(BuildContext context) {
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
          child: BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state.cards.isEmpty) {
                return const Center(
                  child: Text(
                    "No hay métodos de pago registrados",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.cards.length,
                itemBuilder: (context, index) {
                  final card = state.cards[index];
                  return PaymentMethodCard(
                    details: formatCardNumber(card.cardNumber!),
                    iconPath: "assets/images/payment_card.jpg",
                    index: index,
                    idPaymentMethod: card.id!,
                  );
                },
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
