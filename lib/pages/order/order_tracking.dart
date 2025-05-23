import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/pages/order/order_map_following.dart';

import '../../../spl/spl_variables.dart';
import '../../../utils/ui/order_statuses.dart';
import '../../bloc/orders_bloc/order_bloc.dart';
import '../../bloc/orders_bloc/order_state.dart';
import '../../models/helpers/intern_logic/user_type.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/horizontal_order_status.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/modify_order_status_options.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/order_action_buttons.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/order_tracking_header.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/shipping_guide.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/vertical_order_status.dart';
import '../../widgets/style_widgets/navigation_bars/nav_bar.dart';

class OrderTrackingScreen extends StatelessWidget {
  final UserType userType;
  final OrderModel? order;

  const OrderTrackingScreen({
    super.key,
    required this.userType,
    this.order,
  });

  @override
  Widget build(BuildContext context) =>
      OrderTrackingPage(userType: userType, order: order);
}

class OrderTrackingPage extends StatefulWidget {
  final UserType userType;
  final OrderModel? order;

  const OrderTrackingPage({
    super.key,
    required this.userType,
    this.order,
  });

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

    return Scaffold(
      body: SPLVariables.hasRealTimeTracking
          ? _buildRealTimeMap()
          : Column(
              children: [
                Expanded(child: _buildNonRealTime()),
              ],
            ),
      bottomNavigationBar:
          CustomBottomNavigationBar(userType: _userType, context: context),
    );
  }

  Widget _buildRealTimeMap() {
    return Stack(
      children: [
        Column(
          children: [
            OrderTrackingHeader(userType: _userType),
            HorizontalOrderStatus(order: widget.order!),
            Expanded(
                child: OrderMapFollowing(
                    order: widget.order!, userType: widget.userType)),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200,
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

  Widget _buildNonRealTime() {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OrdersError) {
          return Center(child: Text('Bloc error: ${state.message}'));
        }

        final order = widget.order!;

        final isBusinessLike =
            (_userType == UserType.business || _userType == UserType.admin) &&
                !SPLVariables.hasRealTimeTracking;

        if (isBusinessLike) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderTrackingHeader(userType: _userType),
                const SizedBox(height: 24),
                HorizontalOrderStatus(order: order),
                const SizedBox(height: 24),
                ModifyOrderStatusOptions(
                    selectedStatus: _selectedStatus, order: order),
                const Spacer(), // empuja los botones al fondo

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: OrderActionButtons(
                    selectedStatus: _selectedStatus,
                    userType: _userType,
                    order: order,
                    showConfirmButton: !(_selectedStatus != 'delivered' &&
                        order.orderStatuses.last.status != 'delivered'),
                  ),
                ),
              ],
            ),
          );
        }

        if (_userType == UserType.customer &&
            !SPLVariables.hasRealTimeTracking) {
          DateTime eta = order.creationDate!.add(const Duration(days: 5));
          final deliveredStatus = order.orderStatuses.lastWhere(
            (s) => normalizeOnTheWay(s.status) == 'delivered',
            orElse: () => order.orderStatuses.first,
          );
          final bool hasDelivered =
              normalizeOnTheWay(deliveredStatus.status) == 'delivered';
          if (hasDelivered) eta = deliveredStatus.startDate;
          final String etaText = DateFormat('dd/MM/yyyy').format(eta);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderTrackingHeader(userType: _userType),
              const SizedBox(height: 24),
              VerticalOrderStatus(order: order),
              const SizedBox(height: 48),
              ShippingGuide(
                orderNumber: '${order.id!}',
                estimatedDeliveryDate: etaText,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: OrderActionButtons(
                  selectedStatus: _selectedStatus,
                  showConfirmButton: false,
                  userType: _userType,
                  order: order,
                ),
              ),
            ],
          );
        }

        // ---- Fallback
        return Column(
          children: [
            OrderTrackingHeader(userType: _userType),
            HorizontalOrderStatus(order: order),
            Expanded(
              child: Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: SizedBox.shrink()),
            ),
          ],
        );
      },
    );
  }
}
