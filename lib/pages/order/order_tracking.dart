// lib/pages/order/tracking/order_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';

import '../../../models/logic/user_type.dart';
import '../../../spl/spl_variables.dart';
import '../../../utils/ui/order_statuses.dart';
import '../../../widgets/navigation_bars/nav_bar.dart';
import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_state.dart';
import '../../widgets/order/tracking/horizontal_order_status.dart';
import '../../widgets/order/tracking/modify_order_status_options.dart';
import '../../widgets/order/tracking/order_action_buttons.dart';
import '../../widgets/order/tracking/order_tracking_header.dart';
import '../../widgets/order/tracking/shipping_guide.dart';
import '../../widgets/order/tracking/vertical_order_status.dart';

class OrderTrackingScreen extends StatelessWidget {
  final UserType userType;
  final OrderModel? order;

  const OrderTrackingScreen({
    Key? key,
    required this.userType,
    this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrderTrackingPage(userType: userType, order: order);
  }
}

class OrderTrackingPage extends StatefulWidget {
  final UserType userType;
  final OrderModel? order;

  const OrderTrackingPage({
    Key? key,
    required this.userType,
    this.order,
  }) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingPage> {
  late String _selectedStatus;
  static const List<String> _flow = [
    'confirmed',
    'preparing',
    'on-the-way',
    'delivered'
  ];
  int _idx(String s) => _flow.indexOf(s);
  UserType get _userType => widget.userType;

  @override
  void initState() {
    super.initState();
    final rawLast =
        (widget.order != null && widget.order!.orderStatuses.isNotEmpty)
            ? normalizeOnTheWay(widget.order!.orderStatuses.last.status)
            : 'confirmed';
    final lastIdx = _idx(rawLast);
    _selectedStatus =
        (lastIdx + 1 < _flow.length) ? _flow[lastIdx + 1] : rawLast;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Order not found')),
      );
    }

    // Envuelve todo en padding horizontal de 16
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SPLVariables.hasRealTimeTracking
            ? _buildRealTimeMap(context)
            : _buildNonRealTime(context),
      ),
      bottomNavigationBar:
          CustomBottomNavigationBar(userType: _userType, context: context),
    );
  }

  Widget _buildRealTimeMap(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const OrderTrackingHeader(),
            HorizontalOrderStatus(order: widget.order!),
            Expanded(
              child: Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text('Mapa aquí'),
              ),
            ),
          ],
        ),
        // Botón de detalles más angosto y centrado
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200, // ancho fijo menor para botón más angosto
              child: OrderActionButtons(
                selectedStatus: _selectedStatus,
                userType: _userType,
                order: widget.order,
                showConfirmButton: false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNonRealTime(BuildContext context) {
    return Column(
      children: [
        const OrderTrackingHeader(),
        Expanded(
          child: BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              if (state is OrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is OrdersLoaded &&
                  state.filteredOrders.isNotEmpty) {
                final order = widget.order!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: _buildBody(order, state),
                );
              } else if (state is OrdersError) {
                return Center(child: Text('Bloc error: ${state.message}'));
              } else {
                return const Center(
                  child: Text('Estado inesperado o sin órdenes para mostrar.'),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody(OrderModel order, OrdersState state) {
    // Business/Admin sin real-time tracking
    if ((_userType == UserType.business || _userType == UserType.admin) &&
        !SPLVariables.hasRealTimeTracking) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HorizontalOrderStatus(order: order),
          const SizedBox(height: 24),
          ModifyOrderStatusOptions(selectedStatus: _selectedStatus),
          const SizedBox(height: 24),
          OrderActionButtons(
            selectedStatus: _selectedStatus,
            userType: _userType,
            order: order,
          ),
        ],
      );
    }

    // Delivery sin real-time tracking
    if (_userType == UserType.delivery && !SPLVariables.hasRealTimeTracking) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HorizontalOrderStatus(order: order),
          const SizedBox(height: 24),
          ModifyOrderStatusOptions(selectedStatus: _selectedStatus),
          const SizedBox(height: 24),
          OrderActionButtons(
            selectedStatus: _selectedStatus,
            userType: _userType,
            order: order,
          ),
        ],
      );
    }

    // Customer sin real-time tracking
    if (_userType == UserType.customer && !SPLVariables.hasRealTimeTracking) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VerticalOrderStatus(),
          const SizedBox(height: 24),
          ShippingGuide(
            orderNumber: '${order.id!}',
            estimatedDeliveryDate: '2025-02-20',
          ),
          const SizedBox(height: 10),
          OrderActionButtons(
            selectedStatus: _selectedStatus,
            showConfirmButton: false,
            userType: _userType,
            order: order,
          ),
        ],
      );
    }

    // Fallback
    return Column(
      children: [
        HorizontalOrderStatus(order: order),
        Container(
          height: 400,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Text('Mapa aquí'),
        ),
      ],
    );
  }
}
