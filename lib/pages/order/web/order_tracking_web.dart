import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_event.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/widgets/order/tracking/horizontal_order_status.dart';
import 'package:spl_front/widgets/order/tracking/modify_order_status_options.dart';
import 'package:spl_front/widgets/order/tracking/order_action_buttons.dart';
import 'package:spl_front/widgets/order/tracking/order_tracking_header.dart';
import 'package:spl_front/pages/order/order_details.dart';
import 'package:spl_front/widgets/order/web/horizontal_order_status_web.dart';

class OrderTrackingWebScreen extends StatelessWidget {
  final UserType userType;
  const OrderTrackingWebScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    context.read<OrderStatusBloc>().add(LoadOrderStatusEvent());
    return OrderTrackingWebPage(userType: userType);
  }
}

class OrderTrackingWebPage extends StatefulWidget {
  final UserType userType;
  const OrderTrackingWebPage({super.key, required this.userType});

  @override
  State<OrderTrackingWebPage> createState() => _OrderTrackingWebPageState();
}

class _OrderTrackingWebPageState extends State<OrderTrackingWebPage> {
  UserType get userType => widget.userType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Tracking Section
          Expanded(
            flex: 3,
            child: Column(
              children: [
                const OrderTrackingHeader(),
                Expanded(
                  child: BlocBuilder<OrderStatusBloc, OrderStatusState>(
                    builder: (context, state) {
                      if (state is OrderStatusLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is OrderStatusLoaded) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Business Screen
                                if (userType == UserType.business) ...[
                                  CustomHorizontalOrderStatus(),
                                  const SizedBox(height: 24.0),
                                  if (SPLVariables.hasRealTimeTracking) ...[
                                    Container(
                                      height: 400,
                                      color: Colors.grey[300],
                                      child: Center(child: Text('Mapa aquí')),
                                    ),
                                  ],
                                ] 
                                
                                // Customer Screen
                                else if (userType == UserType.customer) ...[
                                  CustomHorizontalOrderStatus(),
                                  const SizedBox(height: 24.0),
                                  if (SPLVariables.hasRealTimeTracking) ...[
                                    Container(
                                      height: 500,
                                      color: Colors.grey[300],
                                      child: Center(child: Text('Mapa aquí')),
                                    ),
                                  ]
                                ] 
                                
                                // Delivery Screen
                                else if (userType == UserType.delivery) ...[
                                  HorizontalOrderStatus(),
                                  if (SPLVariables.hasRealTimeTracking) ...[
                                    Container(
                                      height: 400,
                                      color: Colors.grey[300],
                                      child: Center(child: Text('Mapa aquí')),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 24.0),
                                    ModifyOrderStatusOptions(
                                      selectedStatus: state.selectedStatus,
                                      onStatusChanged: (status) {
                                        context.read<OrderStatusBloc>().add(
                                            ChangeSelectedStatusEvent(status));
                                      },
                                    ),
                                    const SizedBox(height: 24.0),
                                    OrderActionButtons(
                                      selectedStatus: state.selectedStatus,
                                      userType: userType,
                                    ),
                                  ],
                                ] 
                                
                                else ...[
                                  const Text(
                                      'Error al cargar el estado de la orden')
                                ]
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(
                            child: Text(
                                'Error al cargar el estado de la orden'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Expanded(
            flex: 1,
            child: Container(
              color: PrimaryColors.blueWeb, // Background color for the details panel
              padding: EdgeInsets.all(25),
              constraints: BoxConstraints(maxWidth: 10), // Max width for the details panel
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 100), // Establecer el maxWidth aquí
                child: OrderDetailsPage(
                  userType: userType,
                  backgroundColor: PrimaryColors.blueWeb,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}