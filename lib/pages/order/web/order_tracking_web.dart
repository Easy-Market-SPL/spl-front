import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/pages/order/order_map_following.dart';

import '../../../bloc/orders_bloc/order_bloc.dart';
import '../../../bloc/orders_bloc/order_state.dart';
import '../../../models/helpers/intern_logic/user_type.dart';
import '../../../pages/order/order_details.dart';
import '../../../spl/spl_variables.dart';
import '../../../theme/colors/primary_colors.dart';
import '../../../widgets/logic_widgets/order_widgets/orders/tracking/horizontal_order_status.dart';
import '../../../widgets/logic_widgets/order_widgets/orders/tracking/modify_order_status_options.dart';
import '../../../widgets/logic_widgets/order_widgets/orders/tracking/order_action_buttons.dart';
import '../../../widgets/logic_widgets/order_widgets/orders/tracking/order_tracking_header.dart';
import '../../../widgets/logic_widgets/order_widgets/orders/web/horizontal_order_status_web.dart';
import '../../../widgets/web/scaffold_web.dart';

class OrderTrackingWebScreen extends StatelessWidget {
  final UserType userType;
  final OrderModel? order;
  const OrderTrackingWebScreen({super.key, required this.userType, this.order});

  @override
  Widget build(BuildContext context) {
    return OrderTrackingWebPage(userType: userType, order: order);
  }
}

class OrderTrackingWebPage extends StatefulWidget {
  final UserType userType;
  final OrderModel? order;
  const OrderTrackingWebPage({super.key, required this.userType, this.order});

  @override
  State<OrderTrackingWebPage> createState() => _OrderTrackingWebPageState();
}

class _OrderTrackingWebPageState extends State<OrderTrackingWebPage> {
  UserType get userType => widget.userType;
  OrderModel? get order => widget.order;

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      userType: userType,
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                OrderTrackingHeader(userType: userType),
                Expanded(
                  child: BlocBuilder<OrdersBloc, OrdersState>(
                    builder: (context, state) {
                      if (state is OrdersLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is OrdersLoaded &&
                          state.filteredOrders.isNotEmpty &&
                          order != null) {
                        final order = widget.order;
                        var lastStatus = _extractLastStatus(order);
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (userType == UserType.business) ...[
                                  CustomHorizontalOrderStatus(order: order!,),
                                  const SizedBox(height: 24.0),
                                  if (SPLVariables.hasRealTimeTracking) ...[
                                    buildWebMap(order, userType)
                                  ],
                                ] else if (userType == UserType.customer) ...[
                                  CustomHorizontalOrderStatus(order: order!,),
                                  const SizedBox(height: 24.0),
                                  if (SPLVariables.hasRealTimeTracking) ...[
                                    buildWebMap(order, userType)
                                  ],
                                ] else if (userType == UserType.delivery) ...[
                                  HorizontalOrderStatus(order: order!),
                                  if (SPLVariables.hasRealTimeTracking) ...[
                                    buildWebMap(order, userType)
                                  ] else ...[
                                    const SizedBox(height: 24.0),
                                    ModifyOrderStatusOptions(
                                      selectedStatus: lastStatus,
                                      order: order,
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
                            child:
                                Text('Error al cargar el estado de la orden'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: PrimaryColors.blueWeb,
              padding: const EdgeInsets.all(25),
              constraints: const BoxConstraints(maxWidth: 10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: OrderDetailsPage(
                  userType: userType,
                  backgroundColor: PrimaryColors.blueWeb,
                  order: order!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractLastStatus(order) {
    final statuses = order.orderStatuses;
    if (statuses == null || statuses.isEmpty) return '';
    return statuses.last.status;
  }

  Widget buildWebMap(OrderModel order, UserType userType) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final mapWidth = constraints.maxWidth;
        final mapHeight = screenSize.height * 0.6;

        return Container(
          height: mapHeight,
          width: mapWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: OrderMapFollowing(
            order: widget.order!,
            userType: widget.userType
          ),
        );
      },
    );
  }
}
