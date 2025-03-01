import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_event.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/navigation_bars/business_nav_bar.dart';
import 'package:spl_front/widgets/navigation_bars/customer_nav_bar.dart';
import 'package:spl_front/widgets/navigation_bars/delivery_user_nav_bar.dart';
import 'package:spl_front/widgets/order/modify_order_status_options.dart';
import 'package:spl_front/widgets/order/order_action_buttons.dart';
import 'package:spl_front/widgets/order/products_popup.dart';
import 'package:spl_front/widgets/order/shipping_company_selection.dart';

class OrderDetailsScreen extends StatelessWidget {
  final ChatUserType userType;

  const OrderDetailsScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return OrderDetailsPage(userType: userType);
  }
}

class OrderDetailsPage extends StatefulWidget {
  final ChatUserType userType;

  const OrderDetailsPage({super.key, required this.userType});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  ChatUserType get userType => widget.userType;
  String selectedShippingCompany = "Sin seleccionar";

  @override
  Widget build(BuildContext context) {
    // Simulated order and customer data
    final orderData = _getOrderData();
    final customerData = _getCustomerData();

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
                                userType == ChatUserType.business ||
                            userType == ChatUserType.delivery) ...[
                          const SizedBox(height: 20),
                          ModifyOrderStatusOptions(
                            selectedStatus: state.selectedStatus,
                            onStatusChanged: (status) {
                              context
                                  .read<OrderStatusBloc>()
                                  .add(ChangeSelectedStatusEvent(status));
                            },
                          ),
                          const SizedBox(height: 24.0),
                          OrderActionButtons(
                            selectedStatus: state.selectedStatus,
                            showDetailsButton: false,
                            userType: userType,
                          ),
                          const SizedBox(height: 24.0),
                        ],

                        // Order details content
                        _buildSectionTitle(OrderStrings.orderDetailsTitle),
                        _buildInfoRow(
                            OrderStrings.orderNumber, orderData['numeroOrden']),
                        _buildInfoRow(
                            OrderStrings.orderDate, orderData['fecha']),
                        _buildInfoRow(OrderStrings.orderProductCount,
                            "${orderData['numProductos']}",
                            actionText: OrderStrings.viewProducts,
                            onActionTap: () {
                          _showProductPopup(context); // Open the product popup
                        }),
                        _buildInfoRow(OrderStrings.orderTotal,
                            "\$${orderData['total'].toStringAsFixed(0)}"),
                        const SizedBox(height: 20),

                        // Customer details content
                        _buildSectionTitle(OrderStrings.customerDetailsTitle),
                        _buildInfoRow(
                            OrderStrings.customerName, customerData['cliente']),
                        _buildInfoRow(OrderStrings.deliveryAddress,
                            customerData['direccion']),

                        // Real-time tracking or company selection
                        if (SPLVariables.hasRealTimeTracking) ...[
                          const SizedBox(height: 20),
                          _buildSectionTitle(OrderStrings.deliveryDetailsTitle),
                          _buildInfoRow(OrderStrings.deliveryPersonName,
                              OrderStrings.noDeliveryPersonAssigned),
                        ] else ...[
                          const SizedBox(height: 20),
                          _buildSectionTitle(OrderStrings.shippingCompanyTitle),
                          if (userType == ChatUserType.business) ...[
                            _buildSelectableRow(
                                OrderStrings.selectedShippingCompany,
                                selectedShippingCompany, onActionTap: () {
                              _showShippingCompanyPopup(
                                  context); // Open the shipping company selection popup
                            }),
                          ] else ...[
                            _buildInfoRow(
                              OrderStrings.shippingCompany,
                              selectedShippingCompany,
                            ),
                          ],
                        ]
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
          _getBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _getBottomNavigationBar() {
    if (userType == ChatUserType.customer) {
      return const CustomerBottomNavigationBar();
    } else if (userType == ChatUserType.business) {
      return const BusinessBottomNavigationBar();
    } else if (userType == ChatUserType.delivery) {
      return const DeliveryUserBottomNavigationBar();
    } else {
      return const SizedBox();
    }
  }

  // Helper function to get simulated order data
  Map<String, dynamic> _getOrderData() {
    return {
      'numeroOrden': "123456",
      'fecha': "2025-02-17",
      'numProductos': 5,
      'total': 150.0,
    };
  }

  // Helper function to get simulated customer data
  Map<String, dynamic> _getCustomerData() {
    return {
      'cliente': "Juan Pérez",
      'direccion': "Calle Falsa 123",
      'empresaSeleccionada': "",
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
                      fontWeight: FontWeight.w300,
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
