import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/data/payment_method.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/utils/strings/payment_strings.dart';
import 'package:spl_front/utils/ui/format_currency.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_event.dart';
import '../../../models/logic/address.dart';
import '../../../models/logic/user_type.dart';
import '../../../models/order_models/order_status.dart';
import '../../../models/ui/stripe/stripe_custom_response.dart';
import '../../../pages/order/order_tracking.dart';
import '../../../services/gui/stripe/stripe_service.dart';

class CreditPaymentDialog extends StatefulWidget {
  final double total;
  final Address? address;
  final PaymentMethodCard? card;
  final OrderModel? orderParameter;

  // References to the dialog methods in the parent widget
  final VoidCallback onLoadingDialog;
  final VoidCallback onSuccessPaymentDialog;
  final void Function(StripeCustomReponse) onErrorPaymentDialog;

  const CreditPaymentDialog({
    super.key,
    required this.total,
    required this.address,
    required this.card,
    required this.onLoadingDialog,
    required this.onSuccessPaymentDialog,
    required this.onErrorPaymentDialog,
    this.orderParameter,
  });

  @override
  State<CreditPaymentDialog> createState() => _CreditPaymentDialogState();
}

class _CreditPaymentDialogState extends State<CreditPaymentDialog> {
  /// Minimum number of installments is 1. Increase or decrease with buttons.
  int _installments = 1;

  /// Monthly payment = total / installments
  double _monthlyPayment = 0.0;

  /// Remaining debt = total - first monthlyPayment
  double _remainingDebt = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateInstallments();
  }

  /// Recalculate monthlyPayment and remainingDebt whenever installments change
  void _calculateInstallments() {
    if (_installments < 1) {
      _installments = 1; // Ensure it never goes below 1
    }
    _monthlyPayment = widget.total / _installments;
    _remainingDebt = widget.total - _monthlyPayment;
    setState(() {});
  }

  /// Increase the number of installments
  void _incrementInstallments() {
    setState(() {
      _installments++;
      _calculateInstallments();
    });
  }

  /// Decrease the number of installments, never going below 1
  void _decrementInstallments() {
    if (_installments > 1) {
      setState(() {
        _installments--;
        _calculateInstallments();
      });
    }
  }

  /// Process payment for the first installment
  Future<void> _payFirstInstallment() async {
    // Show loading dialog
    widget.onLoadingDialog();

    var order = widget.orderParameter ??
        BlocProvider.of<OrdersBloc>(context).state.currentCartOrder;

    late OrderModel orderModified;

    // Payment amount = monthlyPayment (first installment)
    final amount = (_monthlyPayment * 100).round().toString();

    /// Always Pay with existing card
    final stripeService = StripeService();
    final response = await stripeService.payWithExistingCard(
      amount: amount,
      currency: 'cop',
      card: widget.card!,
    );

    Navigator.pop(context); // Close loading

    if (response.ok) {
      widget.onSuccessPaymentDialog();
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

      Navigator.pop(context); // Close success dialog
      Navigator.pop(context); // Close installments dialog

      final ordersBloc = BlocProvider.of<OrdersBloc>(context);

      if (widget.orderParameter != null) {
        ordersBloc.add(UpdateDebtEvent(
            orderId: order!.id!,
            paymentAmount: _monthlyPayment)); // Update the order's debt

        orderModified = order.copyWith(
          debt: _remainingDebt,
        );
      } else {
        // Update the order status to confirmed
        ordersBloc.add(ConfirmOrderEvent(
          orderId: ordersBloc.state.currentCartOrder!.id!,
          shippingCost: 0,
          paymentAmount: _monthlyPayment,
        ));

        order!.orderStatuses
            .add(OrderStatus(status: 'confirmed', startDate: DateTime.now()));
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => OrderTrackingPage(
                userType: UserType.customer,
                order: widget.orderParameter == null ? order : orderModified)),
        (Route<dynamic> route) => false,
      );
    } else {
      widget.onErrorPaymentDialog(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodLabel =
        PaymentStrings.prefixCard(widget.card!.cardNumber!);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        /// Constrain the dialog size for a bigger layout
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              /// Align all content to the left
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  PaymentStrings.creditPayment,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),

                // Show total
                Text(
                  formatCurrency(widget.total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 4),

                // Section: Difiere el Pago de tu Pedido
                const Text(
                  PaymentStrings.diferePayment,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const Divider(),
                const SizedBox(height: 4),

                // Row for installments +/- buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      PaymentStrings.installments,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _decrementInstallments,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.blue,
                        ),
                        Text(
                          "$_installments",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _incrementInstallments,
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Monthly Payment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      PaymentStrings.monthlyInstallment,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(formatCurrency(_monthlyPayment)),
                  ],
                ),
                const SizedBox(height: 10),

                // Remaining Debt
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      PaymentStrings.debt,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(formatCurrency(_remainingDebt)),
                  ],
                ),
                const SizedBox(height: 20),

                // Payment method
                const Text(
                  PaymentStrings.paymentMethod,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  paymentMethodLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Pay button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _payFirstInstallment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      PaymentStrings.doPayment,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
