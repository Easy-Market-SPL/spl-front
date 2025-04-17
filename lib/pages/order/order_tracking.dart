import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';

import '../../../models/logic/user_type.dart';
import '../../../spl/spl_variables.dart';
import '../../../widgets/navigation_bars/nav_bar.dart';
import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_event.dart';
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
  const OrderTrackingScreen({super.key, required this.userType, this.order});

  @override
  Widget build(BuildContext context) {
    return OrderTrackingPage(userType: userType, order: order);
  }
}

class OrderTrackingPage extends StatefulWidget {
  final UserType userType;
  final OrderModel? order;
  const OrderTrackingPage({super.key, required this.userType, this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingPage> {
  UserType get userType => widget.userType;

  @override
  Widget build(BuildContext context) {
    if (widget.order == null) {
      return const Center(child: Text('Error: Order not found'));
    }
    context.read<OrdersBloc>().add(
          LoadSingleOrderEvent(widget.order!.id!),
        );
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const OrderTrackingHeader(),
              Expanded(
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) {
                    if (state is OrdersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is OrdersLoaded &&
                        state.filteredOrders.isNotEmpty) {
                      final order = state.filteredOrders.first;
                      final lastStatus = _extractLastStatus(order);
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userType == UserType.business) ...[
                                const HorizontalOrderStatus(),
                                if (SPLVariables.hasRealTimeTracking) ...[
                                  Container(
                                    height: 400,
                                    color: Colors.grey[300],
                                    child:
                                        const Center(child: Text('Mapa aquí')),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 24.0),
                                  ModifyOrderStatusOptions(
                                    selectedStatus: lastStatus,
                                    onStatusChanged: (status) {
                                      // e.g. context.read<OrdersBloc>().add(ChangeSelectedStatusEvent(status));
                                    },
                                  ),
                                  const SizedBox(height: 24.0),
                                  OrderActionButtons(
                                    selectedStatus: lastStatus,
                                    userType: userType,
                                  ),
                                ],
                              ] else if (userType == UserType.customer) ...[
                                if (SPLVariables.hasRealTimeTracking) ...[
                                  const HorizontalOrderStatus(),
                                  Container(
                                    height: 500,
                                    color: Colors.grey[300],
                                    child:
                                        const Center(child: Text('Mapa aquí')),
                                  ),
                                ] else ...[
                                  const VerticalOrderStatus(),
                                  const SizedBox(height: 24.0),
                                  ShippingGuide(
                                    orderNumber: '${order.id!}',
                                    estimatedDeliveryDate: "2025-02-20",
                                  ),
                                  const SizedBox(height: 10.0),
                                  OrderActionButtons(
                                    selectedStatus: lastStatus,
                                    showConfirmButton: false,
                                    userType: userType,
                                  ),
                                ],
                              ] else if (userType == UserType.delivery) ...[
                                const HorizontalOrderStatus(),
                                if (SPLVariables.hasRealTimeTracking) ...[
                                  Container(
                                    height: 400,
                                    color: Colors.grey[300],
                                    child:
                                        const Center(child: Text('Mapa aquí')),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 24.0),
                                  ModifyOrderStatusOptions(
                                    selectedStatus: lastStatus,
                                    onStatusChanged: (status) {
                                      // e.g. context.read<OrdersBloc>().add(ChangeSelectedStatusEvent(status));
                                    },
                                  ),
                                  const SizedBox(height: 24.0),
                                  OrderActionButtons(
                                    selectedStatus: lastStatus,
                                    userType: userType,
                                  ),
                                ],
                              ] else ...[
                                const Text(
                                    'Error al cargar el estado de la orden')
                              ]
                            ],
                          ),
                        ),
                      );
                    } else if (state is OrdersError) {
                      return Center(child: Text(state.message));
                    } else {
                      return const Center(
                        child: Text('Error al cargar el estado de la orden'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          if (userType == UserType.business &&
              SPLVariables.hasRealTimeTracking) ...[
            Positioned(
              bottom: 0.0,
              left: 16.0,
              right: 16.0,
              child: OrderActionButtons(
                selectedStatus: "",
                showConfirmButton: false,
                userType: userType,
              ),
            ),
          ],
          if (userType == UserType.customer &&
              SPLVariables.hasRealTimeTracking) ...[
            Positioned(
              bottom: 0.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                children: [
                  ShippingGuide(
                    orderNumber: "???",
                    estimatedDeliveryDate: "???",
                  ),
                  const SizedBox(height: 10.0),
                  OrderActionButtons(
                    selectedStatus: "",
                    showConfirmButton: false,
                    userType: userType,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar:
          CustomBottomNavigationBar(userType: userType, context: context),
    );
  }

  String _extractLastStatus(order) {
    final statuses = order.orderStatuses;
    if (statuses.isEmpty) return '';

    final lastStatus = statuses.last.status;

    switch (lastStatus) {
      case 'confirmed':
        return 'Confirmada';
      case 'preparing':
        return 'En preparación';
      case 'on-the-way':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      default:
        return '';
    }
  }
}
