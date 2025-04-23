import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/ui/credit_card/credit_card_model.dart';
import 'package:spl_front/models/ui/stripe/stripe_custom_response.dart';
import 'package:spl_front/pages/customer_user/dashboard_customer_user.dart';
import 'package:spl_front/utils/strings/cart_strings.dart';
import 'package:spl_front/utils/strings/payment_strings.dart';
import 'package:spl_front/utils/ui/format_currency.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_event.dart';
import '../../../models/logic/address.dart';
import '../../../models/order_models/order_status.dart';
import '../../../services/gui/stripe/stripe_service.dart';

class PaymentTotal extends StatelessWidget {
  final double total;
  final PaymentCardModel? card;
  final Address? address;

  const PaymentTotal({super.key, required this.total, this.card, this.address});

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

  void _processPayment(BuildContext context) async {
    var order = BlocProvider.of<OrdersBloc>(context).state.currentCartOrder;
    final orderBloc = BlocProvider.of<OrdersBloc>(context);

    if (address == null) {
      _showSelectAddressDialog(context);
      return;
    }

    if (card == null) {
      // Means that the payment is cash
      _showSucessfullCashPaymentDialog(context);
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      Navigator.pop(context); // Close the dialog

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
    final amount = (total * 100).round().toString();

    final StripeCustomReponse response =
        await stripeService.payWithExistingCard(
      amount: amount,
      currency: 'cop',
      card: card!,
    );
    // Close the loading dialog
    Navigator.pop(context);

    if (response.ok) {
      // Show success dialog and redirect to tracking order page
      _showSuccessfullPaymentDialog(context);

      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      Navigator.pop(context); // Close the dialog

      // In this case, the payment is done with card in one installment, so it's neccesary update the order status to confirmed
      orderBloc.add(ConfirmOrderEvent(
          orderId: orderBloc.state.currentCartOrder!.id!,
          shippingCost: 0,
          paymentAmount: total));

      order!.orderStatuses
          .add(OrderStatus(status: 'confirmed', startDate: DateTime.now()));

      // Navigate to the order tracking page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => CustomerMainDashboard()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Mostrar mensaje de error
      _showErrorPaymentDialog(context, response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
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
                  formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
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
