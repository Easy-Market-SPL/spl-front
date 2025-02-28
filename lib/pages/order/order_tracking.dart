import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_event.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/widgets/navigation_bars/business_nav_bar.dart';
import 'package:spl_front/widgets/navigation_bars/customer_nav_bar.dart';
import 'package:spl_front/widgets/order/horizontal_order_status.dart';
import 'package:spl_front/widgets/order/order_tracking_header.dart';
import 'package:spl_front/widgets/order/modify_order_status_options.dart';
import 'package:spl_front/widgets/order/order_action_buttons.dart';
import 'package:spl_front/widgets/order/shipping_guide.dart';
import 'package:spl_front/widgets/order/vertical_order_status.dart';

enum OrderUserType { costumer, business }

class OrderTrackingScreen extends StatelessWidget {
  final ChatUserType userType;
  const OrderTrackingScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    context.read<OrderStatusBloc>().add(LoadOrderStatusEvent());
    return OrderTrackingPage(userType: userType);
  }
}

class OrderTrackingPage extends StatefulWidget {
  final ChatUserType userType;
  const OrderTrackingPage({super.key, required this.userType});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingPage> {
  ChatUserType get userType => widget.userType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                              if (userType == ChatUserType.business) ...[
                                HorizontalOrderStatus(),
                                if (SPLVariables.hasRealTimeTracking) ...[
                                  Container(
                                    height: 400,
                                    color: Colors.grey[300],
                                    child: Center(child: Text('Mapa aquí')),
                                  ),
                                ] 
                                else ...[
                                  const SizedBox(height: 24.0),
                                  ModifyOrderStatusOptions(
                                    selectedStatus: state.selectedStatus,
                                    onStatusChanged: (status) {
                                      context.read<OrderStatusBloc>().add(ChangeSelectedStatusEvent(status));
                                    },
                                  ),
                                  const SizedBox(height: 24.0),
                                  OrderActionButtons(selectedStatus: state.selectedStatus, userType: userType,),
                                ],
                              ] 
                              
                              // Costumer Screen
                              else if (userType == ChatUserType.customer)...[
                                if (SPLVariables.hasRealTimeTracking) ...[
                                  HorizontalOrderStatus(),
                                  Container(
                                    height: 500,
                                    color: Colors.grey[300],
                                    child: Center(child: Text('Mapa aquí')),
                                  ),
                                ] 
                                else ...[
                                  const VerticalOrderStatus(),
                                  const SizedBox(height: 24.0),
                                  ShippingGuide(orderNumber: "123456", estimatedDeliveryDate: "2025-02-20"),
                                  const SizedBox(height: 10.0),
                                  OrderActionButtons(selectedStatus: state.selectedStatus, showConfirmButton: false, userType: userType,),
                                ],
                              ]

                              // TODO: Delivery screen
                              else ...[
                                const Text('Error al cargar el estado de la orden')
                              ]
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(child: Text('Error al cargar el estado de la orden'));
                    }
                  },
                ),
              ),
              if (userType == ChatUserType.customer) const CustomerBottomNavigationBar() 
              else const BusinessBottomNavigationBar(),
            ],
          ),

          // Buttons that have to be at the bottom of the screen
          if (userType == ChatUserType.business && SPLVariables.hasRealTimeTracking) ...[
            Positioned(
              bottom: 80.0,
              left: 16.0,
              right: 16.0,
              child: OrderActionButtons(
                selectedStatus: "",
                showConfirmButton: false,
                userType: userType,
              ),
            ),
          ],
          
          // Shipping guide for costumers
          if (userType == ChatUserType.customer && SPLVariables.hasRealTimeTracking) ...[
            Positioned(
              bottom: 80.0,
              left: 16.0,
              right: 16.0,
              child: Column(
              children: [
                ShippingGuide(orderNumber: "123456", estimatedDeliveryDate: "2025-02-20"),
                const SizedBox(height: 10.0),
                OrderActionButtons(selectedStatus: "", showConfirmButton: false, userType: userType),
              ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}