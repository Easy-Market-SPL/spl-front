import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../models/logic/user_type.dart';
import '../../../models/order_models/order_model.dart';
import '../../../models/user.dart';
import '../../../services/api/user_service.dart';
import '../../../spl/spl_variables.dart';
import '../../../utils/strings/order_strings.dart';
import '../../../utils/ui/format_currency.dart';
import '../../../widgets/navigation_bars/nav_bar.dart';
import '../../widgets/order/list/products_popup.dart';
import '../../widgets/order/tracking/modify_order_status_options.dart';
import '../../widgets/order/tracking/order_action_buttons.dart';
import '../../widgets/order/tracking/shipping_company_selection.dart';

class OrderDetailsScreen extends StatelessWidget {
  final UserType userType;
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.userType,
    required this.order,
  });

  @override
  Widget build(BuildContext context) =>
      OrderDetailsPage(userType: userType, order: order);
}

// ──────────────────────────────────────────────────────────────────────────

class OrderDetailsPage extends StatefulWidget {
  final UserType userType;
  final OrderModel order;
  final Color backgroundColor;

  const OrderDetailsPage({
    super.key,
    required this.userType,
    required this.order,
    this.backgroundColor = Colors.white,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

// ──────────────────────────────────────────────────────────────────────────

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late final Future<UserModel?> _customerFuture;
  late final Future<UserModel?>? _domiciliaryFuture;

  String selectedShippingCompany = 'Sin seleccionar';
  UserType get userType => widget.userType;

  @override
  void initState() {
    super.initState();
    // Cargamos nombres una sola vez
    _customerFuture = UserService.getUser(widget.order.idUser!);
    _domiciliaryFuture = widget.order.idDomiciliary?.isNotEmpty == true
        ? UserService.getUser(widget.order.idDomiciliary!)
        : null;
  }

  // ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final int totalItems =
        order.orderProducts.fold(0, (s, op) => s + op.quantity);
    final orderDate = DateFormat('dd/MM/yyyy').format(order.creationDate!);

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Column(
        children: [
          if (!kIsWeb) _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    );
                  }

                  final lastStatus = _extractLastStatus(order);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(OrderStrings.orderDetailsTitle),
                      if (userType == UserType.business ||
                          userType == UserType.delivery) ...[
                        const SizedBox(height: 20),
                        ModifyOrderStatusOptions(
                          selectedStatus: lastStatus,
                          onStatusChanged: (_) {},
                        ),
                        const SizedBox(height: 24),
                        OrderActionButtons(
                          selectedStatus: lastStatus,
                          showDetailsButton: false,
                          userType: userType,
                          order: order,
                        ),
                        const SizedBox(height: 24),
                      ],
                      _infoRow(OrderStrings.orderNumber, '${order.id}'),
                      _infoRow(OrderStrings.orderDate, orderDate),
                      _infoRow(
                        OrderStrings.orderProductCount,
                        '$totalItems',
                        actionText: OrderStrings.viewProducts,
                        onActionTap: () => _showProductPopup(context, order),
                      ),
                      _infoRow(OrderStrings.orderTotal,
                          formatCurrency(order.total!)),
                      const SizedBox(height: 20),

                      // ─── Datos cliente ───
                      if (userType == UserType.business ||
                          userType == UserType.delivery) ...[
                        _sectionTitle(OrderStrings.customerDetailsTitle),
                        FutureBuilder<UserModel?>(
                          future: _customerFuture,
                          builder: (_, snap) => _infoRow(
                            OrderStrings.customerName,
                            snap.data?.fullname ?? '---',
                            isLoading:
                                snap.connectionState == ConnectionState.waiting,
                          ),
                        ),
                        _infoRow(OrderStrings.deliveryAddress, order.address!),
                      ],

                      // ─── Detalles entrega ───
                      if (SPLVariables.hasRealTimeTracking) ...[
                        const SizedBox(height: 20),
                        _sectionTitle(OrderStrings.deliveryDetailsTitle),
                        FutureBuilder<UserModel?>(
                          future: _domiciliaryFuture,
                          builder: (_, snap) => _infoRow(
                            OrderStrings.deliveryPersonName,
                            snap.data?.fullname ??
                                OrderStrings.noDeliveryPersonAssigned,
                            isLoading: _domiciliaryFuture != null &&
                                snap.connectionState == ConnectionState.waiting,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 20),
                        _sectionTitle(OrderStrings.shippingCompanyTitle),
                        if (userType == UserType.business)
                          _selectableRow(
                            OrderStrings.selectedShippingCompany,
                            selectedShippingCompany,
                            onActionTap: () => _showShippingPopup(context),
                          )
                        else
                          _infoRow(OrderStrings.shippingCompany,
                              selectedShippingCompany),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          CustomBottomNavigationBar(userType: userType, context: context),
    );
  }

  // ────────────────────────── UI helpers ──────────────────────────
  Widget _header(BuildContext ctx) => Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(ctx).size.height * .05, left: 10, right: 10),
        height: 80,
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(ctx),
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _infoRow(String label, String value,
          {String? actionText,
          VoidCallback? onActionTap,
          bool isLoading = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GestureDetector(
          onTap: onActionTap,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    const SizedBox(height: 2),
                    isLoading
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(value,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey)),
                  ],
                ),
              ),
              if (actionText != null)
                Row(
                  children: [
                    Text(actionText,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.underline)),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
            ],
          ),
        ),
      );

  Widget _selectableRow(String l, String v, {VoidCallback? onActionTap}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: GestureDetector(
          onTap: onActionTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(v,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      );

  // ──────────────────── acciones ────────────────────
  void _showProductPopup(BuildContext ctx, OrderModel order) => showDialog(
        context: ctx,
        builder: (_) => ProductPopup(orderModel: order),
      );

  void _showShippingPopup(BuildContext ctx) => showDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (_) => ShippingCompanyPopup(
          selectedCompany: selectedShippingCompany,
          onCompanySelected: (c) => setState(() => selectedShippingCompany = c),
        ),
      );

  String _extractLastStatus(OrderModel ord) =>
      ord.orderStatuses.isEmpty ? '' : ord.orderStatuses.last.status;
}
