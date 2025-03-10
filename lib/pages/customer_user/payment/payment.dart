import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/address/address_bloc.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_bloc.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_event.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_state.dart';
import 'package:spl_front/bloc/ui_management/payment/payment_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/models/ui/credit_card/credit_card_model.dart';
import 'package:spl_front/pages/customer_user/payment/payment_address_selection.dart';
import 'package:spl_front/pages/customer_user/payment/payment_method_selection.dart';
import 'package:spl_front/utils/strings/payment_strings.dart';
import 'package:spl_front/widgets/cart/cart_item.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/payment/process/payment_total.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()..add(LoadCart())),
        BlocProvider(create: (_) => AddressBloc()),
      ],
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
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.blue));
            }
            return state.items.isEmpty
                ? CircularProgressIndicator(color: Colors.blue)
                : _buildCartWithItems(state.items, context);
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
                selectedCard =
                    selected; // Process when the user selects a credit/debit card
              });
            } else {
              setState(() {
                selectedCard = null; // Process when the user selects cash
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
                          : "Efectivo",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Cambiar",
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

  Widget _buildCartWithItems(
      List<Map<String, dynamic>> items, BuildContext context) {
    double subtotal =
        items.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

    final PaymentCardModel card = context.read<PaymentBloc>().state.cards.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAddressSelection(context),
        const SizedBox(height: 16),
        const Text(
          "Elementos de la Orden",
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
        Total(
          total: subtotal,
          card: card,
        ),
      ],
    );
  }

  Widget _buildAddressSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dirección de Entrega",
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
                        selectedAddress?.name ?? "Selecciona una dirección",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        selectedAddress?.address ?? "Toca para seleccionar",
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
}
