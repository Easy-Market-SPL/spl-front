import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/models/order_models/order_product.dart';
import 'package:spl_front/models/order_models/order_status.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/order/list/products_popup.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_event.dart';
import '../../../bloc/ui_management/order/order_state.dart';

class OrderDetailsDeliveryScreen extends StatelessWidget {
  final UserType userType;
  final OrderModel order;

  const OrderDetailsDeliveryScreen({
    super.key,
    required this.userType,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return OrderDetailsDeliveryPage(userType: userType, order: order);
  }
}

class OrderDetailsDeliveryPage extends StatefulWidget {
  final UserType userType;
  final OrderModel order;

  const OrderDetailsDeliveryPage({
    super.key,
    required this.userType,
    required this.order,
  });

  @override
  State<OrderDetailsDeliveryPage> createState() =>
      _OrderDetailsDeliveryPageState();
}

class _OrderDetailsDeliveryPageState extends State<OrderDetailsDeliveryPage> {
  UserType get userType => widget.userType;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(LoadSingleOrderEvent(widget.order.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _headerOrderDetails(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrdersLoaded) {
                    final currentOrder = state.filteredOrders.isNotEmpty
                        ? state.filteredOrders.first
                        : widget.order;
                    final totalItems =
                        _calculateProductCount(currentOrder.orderProducts);
                    final totalOrder =
                        _calculateOrderTotal(currentOrder.orderProducts);
                    final lastStatus =
                        _extractLastStatus(currentOrder.orderStatuses);
                    final domiciliaryName =
                        (currentOrder.idDomiciliary?.isNotEmpty == true)
                            ? currentOrder.idDomiciliary!
                            : 'Sin Domiciliario';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (SPLVariables.hasRealTimeTracking &&
                            userType == UserType.delivery) ...[
                          const SizedBox(height: 24),
                          _buildSectionTitle(OrderStrings.orderDetailsTitle),
                          _buildInfoRow(
                            OrderStrings.orderNumber,
                            '${currentOrder.id!}',
                          ),
                          _buildInfoRow(
                            OrderStrings.orderDate,
                            currentOrder.creationDate!.toIso8601String(),
                          ),
                          _buildInfoRow(
                            OrderStrings.orderProductCount,
                            '$totalItems',
                            actionText: OrderStrings.viewProducts,
                            onActionTap: () =>
                                _showProductPopup(context, widget.order),
                          ),
                          _buildInfoRow(
                            OrderStrings.orderTotal,
                            '\$${totalOrder.toStringAsFixed(2)}',
                          ),
                          _buildSectionTitle('Último estado'),
                          _buildInfoRow('Estado actual', lastStatus),
                          const SizedBox(height: 20),
                          _buildSectionTitle(OrderStrings.customerDetailsTitle),
                          _buildInfoRow(
                            OrderStrings.customerName,
                            currentOrder.idUser!,
                          ),
                          _buildInfoRow(
                            OrderStrings.deliveryAddress,
                            currentOrder.address!,
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle(OrderStrings.deliveryDetailsTitle),
                          _buildInfoRow(
                            OrderStrings.deliveryPersonName,
                            domiciliaryName,
                          ),
                        ],
                      ],
                    );
                  } else if (state is OrdersError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox();
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
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
            ),
        ],
      ),
    );
  }

  void _showProductPopup(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ProductPopup(
        orderModel: order,
      ),
    );
  }

  int _calculateProductCount(List<OrderProduct> products) {
    return products.fold(0, (sum, p) => sum + p.quantity);
  }

  double _calculateOrderTotal(List<OrderProduct> products) {
    // Supongo que p.price ya es precio total por item
    // Si es precio unitario, haz * p.quantity
    return products.fold(0.0, (sum, p) => sum + (p.price ?? 0.0));
  }

  String _extractLastStatus(List<OrderStatus> statuses) {
    if (statuses.isEmpty) return 'Sin estado';
    return statuses.last.status;
  }
}
