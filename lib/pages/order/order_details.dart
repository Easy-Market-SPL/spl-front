import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/utils/ui/format_currency.dart';

import '../../../models/logic/user_type.dart';
import '../../../spl/spl_variables.dart';
import '../../../utils/strings/order_strings.dart';
import '../../../widgets/navigation_bars/nav_bar.dart';
import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_state.dart';
import '../../widgets/order/list/products_popup.dart';
import '../../widgets/order/tracking/modify_order_status_options.dart';
import '../../widgets/order/tracking/order_action_buttons.dart';
import '../../widgets/order/tracking/shipping_company_selection.dart';

class OrderDetailsScreen extends StatelessWidget {
  final UserType userType;
  final OrderModel? order;
  const OrderDetailsScreen({super.key, required this.userType, this.order});

  @override
  Widget build(BuildContext context) {
    return OrderDetailsPage(
      userType: userType,
      order: order,
    );
  }
}

class OrderDetailsPage extends StatefulWidget {
  final UserType userType;
  final Color backgroundColor;
  final OrderModel? order;

  const OrderDetailsPage({
    super.key,
    required this.userType,
    this.order,
    this.backgroundColor = Colors.white,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  UserType get userType => widget.userType;
  String selectedShippingCompany = "Sin seleccionar";

  @override
  Widget build(BuildContext context) {
    // Calculate the total items according with the ProductOrder of the order
    final totalItems = widget.order!.orderProducts
        .map((product) => product.quantity)
        .reduce((a, b) => a + b);

    final orderTotal = widget.order!.total;
    final orderAddress = widget.order!.address;
    final orderId = widget.order!.id.toString();
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Column(
        children: [
          if (!kIsWeb) _headerOrderDetails(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrdersLoaded &&
                      state.filteredOrders.isNotEmpty) {
                    final order = widget.order;
                    final lastStatus = _extractLastStatus(order);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(OrderStrings.orderDetailsTitle),
                        if (userType == UserType.business ||
                            userType == UserType.delivery) ...[
                          const SizedBox(height: 20),
                          ModifyOrderStatusOptions(
                            selectedStatus: lastStatus,
                            onStatusChanged: (status) {
                              // context.read<OrdersBloc>().add(ChangeSelectedStatusEvent(status));
                            },
                          ),
                          const SizedBox(height: 24.0),
                          OrderActionButtons(
                            selectedStatus: lastStatus,
                            showDetailsButton: false,
                            userType: userType,
                          ),
                          const SizedBox(height: 24.0),
                        ],
                        _buildInfoRow(OrderStrings.orderNumber, orderId),
                        _buildInfoRow(
                          OrderStrings.orderDate,
                          order!.creationDate!.toIso8601String(),
                        ),
                        _buildInfoRow(
                          OrderStrings.orderProductCount,
                          totalItems.toString(),
                          actionText: OrderStrings.viewProducts,
                          onActionTap: () => _showProductPopup(context, order),
                        ),
                        _buildInfoRow(
                          OrderStrings.orderTotal,
                          formatCurrency(orderTotal!),
                        ),
                        const SizedBox(height: 20),
                        if (userType == UserType.business ||
                            userType == UserType.delivery) ...[
                          _buildSectionTitle(OrderStrings.customerDetailsTitle),
                          _buildInfoRow(
                              OrderStrings.customerName, order.idUser!),
                          _buildInfoRow(
                              OrderStrings.deliveryAddress, orderAddress!),
                        ],
                        if (SPLVariables.hasRealTimeTracking) ...[
                          const SizedBox(height: 20),
                          _buildSectionTitle(OrderStrings.deliveryDetailsTitle),
                          _buildInfoRow(
                            OrderStrings.deliveryPersonName,
                            order.idDomiciliary?.isNotEmpty == true
                                ? order.idDomiciliary!
                                : OrderStrings.noDeliveryPersonAssigned,
                          ),
                        ] else ...[
                          const SizedBox(height: 20),
                          _buildSectionTitle(OrderStrings.shippingCompanyTitle),
                          if (userType == UserType.business) ...[
                            _buildSelectableRow(
                              OrderStrings.selectedShippingCompany,
                              selectedShippingCompany,
                              onActionTap: () {
                                _showShippingCompanyPopup(context);
                              },
                            ),
                          ] else ...[
                            _buildInfoRow(
                              OrderStrings.shippingCompany,
                              selectedShippingCompany,
                            ),
                          ],
                        ],
                      ],
                    );
                  } else if (state is OrdersError) {
                    return Center(child: Text(state.message));
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
      bottomNavigationBar: CustomBottomNavigationBar(
        userType: userType,
        context: context,
      ),
    );
  }

  Widget _headerOrderDetails(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.05;
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onActionTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (actionText != null)
              Row(
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableRow(
    String label,
    String value, {
    VoidCallback? onActionTap,
  }) {
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
                  color: Colors.black,
                )),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey,
                    )),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductPopup(BuildContext context, OrderModel? order) {
    showDialog(
      context: context,
      builder: (_) => ProductPopup(orderModel: order!),
    );
  }

  void _showShippingCompanyPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ShippingCompanyPopup(
        selectedCompany: selectedShippingCompany,
        onCompanySelected: (company) {
          setState(() {
            selectedShippingCompany = company;
          });
        },
      ),
    );
  }

  String _extractLastStatus(order) {
    final statuses = order.orderStatuses;
    if (statuses == null || statuses.isEmpty) return '';
    return statuses.last.status;
  }
}
