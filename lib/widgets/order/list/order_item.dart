import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/delivery_user/delivery_user_tracking.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

import '../../../bloc/ui_management/gps/gps_bloc.dart';
import '../../../bloc/ui_management/orders_list/orders_list_event.dart';
import '../../../bloc/ui_management/orders_list/orders_list_state.dart';
import '../../../pages/customer_user/profile_addresses/add_address.dart';

class OrderItem extends StatelessWidget {
  final Order order;
  final UserType userType;

  const OrderItem({super.key, required this.order, required this.userType});

  @override
  Widget build(BuildContext context) {
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    return BlocBuilder<OrderListBloc, OrderListState>(
      builder: (context, state) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child:
                      Icon(Icons.shopping_bag, size: 30, color: Colors.black54),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      RichText(
                        text: TextSpan(
                          text: '${OrderStrings.date}: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: DateHelper.formatDate(order.date),
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),

                      // Client
                      if (userType == UserType.business)
                        RichText(
                          text: TextSpan(
                            text: '${OrderStrings.client}: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: order.clientName,
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),

                      if (userType == UserType.delivery)
                        RichText(
                          text: TextSpan(
                            text: '${OrderStrings.deliveryIn}: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: order.address,
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 4),

                      // Status
                      RichText(
                        text: TextSpan(
                          text: '${OrderStrings.status}: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: order.status,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),

                      // Items
                      RichText(
                        text: TextSpan(
                          text: '${OrderStrings.items}: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: order.items.toString(),
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),

                //Order tracking button
                ElevatedButton(
                  onPressed: () {
                    final orderListBloc = BlocProvider.of<OrderListBloc>(context);
                    final updatedOrder = order.copyWith(deliveryName: "Felipe Valero");

                    orderListBloc.add(
                      UpdateDeliveryInformationOrderEvent(order.id!, "Felipe Valero Agudelo"),
                    );

                    void navigateToTracking() {
                      if (userType == UserType.delivery) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryUserTracking(order: updatedOrder),
                          ),
                        );
                      } else if (userType == UserType.business) {
                        Navigator.pushNamed(
                          context,
                          'business_user_order_tracking',
                          arguments: updatedOrder,
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          'customer_user_order_tracking',
                          arguments: updatedOrder,
                        );
                      }
                    }

                    if (SPLVariables.hasRealTimeTracking) {
                      handleWaitGpsStatus(context, () {
                        if (handleGpsAnswer(context, gpsBloc)) {
                          navigateToTracking();
                        }
                      });
                    } else {
                      navigateToTracking();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: userType == UserType.delivery
                      ? Text(OrderStrings.takeOrder, style: TextStyle(color: Colors.white))
                      : Text(OrderStrings.viewOrder, style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
