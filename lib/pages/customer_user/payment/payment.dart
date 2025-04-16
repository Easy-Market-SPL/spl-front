import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/address/address_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/bloc/ui_management/order/order_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/models/ui/credit_card/credit_card_model.dart';
import 'package:spl_front/pages/customer_user/payment/payment_address_selection.dart';
import 'package:spl_front/pages/customer_user/payment/payment_method_selection.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/address_strings.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/utils/strings/payment_strings.dart';
import 'package:spl_front/widgets/cart/cart_item.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/payment/process/payment_credit_total.dart';

import '../../../models/order_models/order_product.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersBloc()
        ..add(LoadOrdersEvent(
            userId: 'userId', userRole: 'customer')), // Load orders (cart)
      child: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  Address? selectedAddress;
  PaymentCardModel? selectedCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _buildPaymentHeader(context),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.blue));
            }

            if (state is OrdersLoaded && state.currentCartOrder != null) {
              final cartItems = state.currentCartOrder!.orderProducts!;
              return _buildCartWithItems(cartItems, context);
            }

            return _buildEmptyCart();
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        userType: UserType.customer,
        context: context,
      ),
    );
  }

  Widget _buildPaymentHeader(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              PaymentStrings.paymentTittle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Método de Pago",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () async {
            final selected = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectPaymentMethodScreen(),
              ),
            );
            if (selected != null) {
              setState(() {
                selectedCard = selected;
              });
            } else {
              setState(() {
                selectedCard = null;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    selectedCard != null
                        ? Icon(Icons.payment, color: Colors.blue, size: 24)
                        : Icon(Icons.monetization_on,
                            color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      selectedCard != null
                          ? "**** ${selectedCard!.cardNumber.substring(selectedCard!.cardNumber.length - 4)}"
                          : PaymentStrings.cash,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  PaymentStrings.change,
                  style: TextStyle(
                    color: selectedCard == null ? Colors.green : Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartWithItems(List<OrderProduct> items, BuildContext context) {
    double subtotal = items.fold(0, (sum, item) {
      item.fetchProduct(); // Load product details
      return sum + (item.price ?? 0) * item.quantity;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAddressSelection(context),
        const SizedBox(height: 16),
        const Text(
          OrderStrings.orderElements,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CartItem(item: items[index]);
            },
          ),
        ),
        _buildPaymentMethodSelection(context),
        const SizedBox(height: 16),
        SPLVariables.hasCreditPayment
            ? PaymentCreditTotal(
                total: subtotal,
                card: selectedCard,
                address: selectedAddress,
              )
            : PaymentCreditTotal(
                total: subtotal, card: selectedCard, address: selectedAddress),
      ],
    );
  }

  Widget _buildAddressSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          OrderStrings.addressDelivery,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final selected = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectAddressScreen(),
              ),
            );
            if (selected != null) {
              setState(() {
                selectedAddress = selected;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            width: double.infinity,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAddress?.name ?? AddressStrings.selectAnAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        selectedAddress?.address ??
                            AddressStrings.touchForSelect,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Text('No items in your cart.'),
    );
  }
}
