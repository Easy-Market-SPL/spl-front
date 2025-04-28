import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/models/data/payment_method.dart';
import 'package:spl_front/models/order_models/order_status.dart';
import 'package:spl_front/models/ui/stripe/stripe_custom_response.dart';
import 'package:spl_front/services/gui/stripe/stripe_service.dart';
import 'package:spl_front/utils/strings/payment_strings.dart';
import 'package:spl_front/utils/ui/format_currency.dart';
import 'package:spl_front/widgets/payment/process/payment_credit_dialog.dart';

import '../../../models/logic/address.dart';
import '../../../pages/customer_user/dashboard_customer_user.dart';

class PaymentCreditTotal extends StatelessWidget {
  final double total;
  final PaymentMethodCard? card;
  final Address? address;

  const PaymentCreditTotal({
    super.key,
    required this.total,
    this.card,
    this.address,
  });

  // Shows a dialog asking the user to select an address before proceeding.
  void _showSelectAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              PaymentStrings.selectAddressBeforePayment,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: const Text(
            PaymentStrings.selectAddressBeforePaymentDescription,
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

  // Shows a dialog asking the user to select a card as payment method.
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

  // Shows a success dialog after payment processing.
  void _showSuccessfullPaymentDialog(BuildContext context) {
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
  }

  // Shows an error dialog when payment fails.
  void _showErrorPaymentDialog(
      BuildContext context, StripeCustomReponse response) {
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

  // Shows a loading dialog during payment processing.
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
              CircularProgressIndicator(color: Colors.blue),
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

  // Shows a dialog for successful cash payment.
  void _showSucessfullCashPaymentDialog(BuildContext context) {
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
                PaymentStrings.confirmCashPaymentAssertion,
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

  // Processes the credit payment
  void _showCreditPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreditPaymentDialog(
        total: total,
        address: address,
        card: card,
        onLoadingDialog: () => _showLoadingDialog(context),
        onSuccessPaymentDialog: () => _showSuccessfullPaymentDialog(context),
        onErrorPaymentDialog: (response) =>
            _showErrorPaymentDialog(context, response),
      ),
    );
  }

  /// THE SHIPPING COST FOR ALL ORDERS WILL BE 0.00
  // Processes the payment
  Future<void> _processPayment(BuildContext context) async {
    var order = BlocProvider.of<OrdersBloc>(context).state.currentCartOrder;

    if (address == null) {
      _showSelectAddressDialog(context);
      return;
    }
    if (card == null) {
      _showSucessfullCashPaymentDialog(context);
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      Navigator.pop(context); // Close dialog

      final orderBloc = BlocProvider.of<OrdersBloc>(context);

      // In this case, the payment is done with cash, so it's neccesary update the order status to confirmed
      orderBloc.add(ConfirmOrderEvent(
          orderId: orderBloc.state.currentCartOrder!.id!,
          shippingCost: 0,
          paymentAmount: total));

      order!.orderStatuses
          .add(OrderStatus(status: 'confirmed', startDate: DateTime.now()));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => CustomerMainDashboard()),
        (Route<dynamic> route) => false,
      );
      return;
    }

    _showLoadingDialog(context);
    final stripeService = StripeService();
    final amountInCents = (total * 100).round().toString();
    final StripeCustomReponse response =
        await stripeService.payWithExistingCard(
      amount: amountInCents,
      currency: 'cop',
      card: card!,
    );
    Navigator.pop(context); // Close loading dialog
    if (response.ok) {
      _showSuccessfullPaymentDialog(context);
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      Navigator.pop(context); // Close success dialog

      final orderBloc = BlocProvider.of<OrdersBloc>(context);

      // In this case, the payment is done with card in one installment, so it's neccesary update the order status to confirmed
      orderBloc.add(ConfirmOrderEvent(
          orderId: orderBloc.state.currentCartOrder!.id!,
          shippingCost: 0,
          paymentAmount: total));

      order!.orderStatuses
          .add(OrderStatus(status: 'confirmed', startDate: DateTime.now()));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => CustomerMainDashboard()),
        (Route<dynamic> route) => false,
      );
    } else {
      _showErrorPaymentDialog(context, response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total label and amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PaymentStrings.total,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    /// Show Message to request the user to select an address
                    if (address == null) {
                      _showSelectAddressDialog(context);
                      return;
                    }

                    /// Show Message to request the user to select a card for the credit payment
                    if (card == null) {
                      _showSelectCardDialog(context);
                      return;
                    }
                    _showCreditPaymentDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 93, 180),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    PaymentStrings.creditPayment,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _processPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 93, 180),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    PaymentStrings.payment,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
