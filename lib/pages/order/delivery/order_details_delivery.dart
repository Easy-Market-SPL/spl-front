import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_event.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/order/products_popup.dart';
import 'package:spl_front/widgets/order/shipping_company_selection.dart';

import '../../../bloc/ui_management/orders_list/orders_list_bloc.dart';

class OrderDetailsDeliveryScreen extends StatelessWidget {
  final UserType userType;
  final Order? order;

  const OrderDetailsDeliveryScreen(
      {super.key, required this.userType, this.order});

  @override
  Widget build(BuildContext context) {
    return OrderDetailsDeliveryPage(userType: userType, order: order);
  }
}

class OrderDetailsDeliveryPage extends StatefulWidget {
  final UserType userType;
  final Order? order;

  const OrderDetailsDeliveryPage(
      {super.key, required this.userType, this.order});

  @override
  State<OrderDetailsDeliveryPage> createState() =>
      _OrderDetailsDeliveryPageState();
}

class _OrderDetailsDeliveryPageState extends State<OrderDetailsDeliveryPage> {
  UserType get userType => widget.userType;
  String selectedShippingCompany = "Sin seleccionar";

  @override
  Widget build(BuildContext context) {
    // Simulated order and customer data
    final orderData = _getOrderData();
    final customerData = _getCustomerData();
    context.read<OrderStatusBloc>().add(LoadOrderStatusEvent());

    return Scaffold(
      body: Column(
        children: [
          _headerOrderDetails(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlocBuilder<OrderStatusBloc, OrderStatusState>(
                builder: (context, state) {
                  if (state is OrderStatusLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderStatusLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order modification options
                        if (SPLVariables.hasRealTimeTracking &&
                            userType == UserType.delivery) ...[
                          const SizedBox(height: 24.0),

                          // Order details content
                          _buildSectionTitle(OrderStrings.orderDetailsTitle),
                          _buildInfoRow(OrderStrings.orderNumber,
                              orderData['numeroOrden']),
                          _buildInfoRow(
                              OrderStrings.orderDate, orderData['fecha']),
                          _buildInfoRow(OrderStrings.orderProductCount,
                              "${orderData['numProductos']}",
                              actionText: OrderStrings.viewProducts,
                              onActionTap: () {
                            _showProductPopup(
                                context); // Open the product popup
                          }),
                          _buildInfoRow(OrderStrings.orderTotal,
                              "\$${orderData['total'].toStringAsFixed(0)}"),
                          const SizedBox(height: 20),

                          // Customer details content
                          _buildSectionTitle(OrderStrings.customerDetailsTitle),
                          _buildInfoRow(OrderStrings.customerName,
                              customerData['cliente']),
                          _buildInfoRow(OrderStrings.deliveryAddress,
                              customerData['direccion']),

                          // Real-time tracking or company selection
                          const SizedBox(height: 20),
                          _buildSectionTitle(OrderStrings.deliveryDetailsTitle),
                          _buildInfoRow(
                              OrderStrings.deliveryPersonName,
                              widget.order?.deliveryName ??
                                  OrderStrings.noDeliveryPersonAssigned),
                        ],
                      ],
                    );
                  } else {
                    return const Center(
                        child: Text(OrderStrings.errorLoadingOrderStatus));
                  }
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(userType: userType),
    );
  }

  // Helper function to get simulated order data
  Map<String, dynamic> _getOrderData() {
    return {
      'numeroOrden': widget.order?.id ?? "123456",
      'fecha': widget.order?.date.toString() ?? "2025-02-17",
      'numProductos': 5,
      'total': 150.0,
    };
  }

// Helper function to get simulated customer data
  Map<String, dynamic> _getCustomerData() {
    return {
      'cliente': widget.order?.clientName ?? "Juan Ramirez",
      'direccion': widget.order?.address ?? "Calle Falsa 123",
    };
  }

  // Header of the order details page
  Widget _headerOrderDetails(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = screenHeight * 0.05;

    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 10.0, right: 10.0),
      height: 80.0,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper to build a row with action (e.g. "Ver productos")
  Widget _buildInfoRow(String label, String value,
      {String? actionText, VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey)),
            ],
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                children: [
                  Text(actionText,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper to build a selectable row (for company selection)
  Widget _buildSelectableRow(String label, String value,
      {String? subtitle, VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onActionTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black)),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey)),
                    if (subtitle != null)
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show the products in a popup when the user taps "Ver productos"
  void _showProductPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const ProductPopup(); // Open the product popup dialog
      },
    );
  }

  // Show the shipping company selection popup
  void _showShippingCompanyPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ShippingCompanyPopup(
          selectedCompany: selectedShippingCompany,
          onCompanySelected: (company) {
            setState(() {
              selectedShippingCompany = company;
            });
          },
        );
      },
    );
  }
}
