import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/payment/payment_bloc.dart';
import 'package:spl_front/models/logic/address.dart';

import '../../../utils/strings/payment_strings.dart';
import '../../../widgets/payment/methods/add_payment_dialog.dart';

class SelectPaymentMethodScreen extends StatelessWidget {
  final Address? address;
  const SelectPaymentMethodScreen({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          PaymentStrings.selectPaymentMethod,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        color: Colors.white,
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                _buildCashPaymentOption(context),
                const SizedBox(height: 10),
                if (state.cards.isNotEmpty) ...[
                  ...state.cards.map((card) => _buildCardOption(context, card)),
                ] else
                  _buildNoCardsMessage(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: address == null
                      ? (BuildContext context) => AddPaymentDialog()
                      : (BuildContext context) =>
                          AddPaymentDialog(address: address),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                PaymentStrings.addCard,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Payment Option of cash
  Widget _buildCashPaymentOption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, null);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  PaymentStrings.cash,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Payment option of credit/debit card
  Widget _buildCardOption(BuildContext context, card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, card);
          Future.delayed(Duration(seconds: 1));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.credit_card, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "**** ${card.cardNumber.substring(card.cardNumber.length - 4)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Not Available Cards
  Widget _buildNoCardsMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          PaymentStrings.notRegisteredCards,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
