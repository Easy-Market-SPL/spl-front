import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/gps/gps_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/pages/delivery_user/delivery_user_tracking.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

import '../../../pages/customer_user/profile_addresses/add_address.dart';

class OrderItem extends StatelessWidget {
  final OrderModel order;
  final UserType userType;

  const OrderItem({
    super.key,
    required this.order,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    // Access the unified OrdersBloc
    final ordersBloc = BlocProvider.of<OrdersBloc>(context);
    // If you need GPS logic
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    final itemsCount = (order.orderProducts ?? [])
        .fold<int>(0, (sum, op) => sum + op.quantity);

    // Determine the current (placeholder) status from the last OrderStatus
    // If there are none, we default to something like '(no status)'
    // Determine the current (placeholder) status from the last OrderStatus
    final placeholderStatus = (order.orderStatuses.isNotEmpty)
        ? order.orderStatuses.last.status
        : 'Sin Estado';

    final statusMap = {
      'confirmed': 'Confirmada',
      'preparing': 'Preparando',
      'on_the_way': 'En Camino',
      'delivered': 'Entregada',
    };

    // Get the translated status or default to 'Sin Estado'
    final placeHolderStatusShow = statusMap[placeholderStatus] ?? 'Sin Estado';

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Icon on the left
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 30,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 10),

                // Main info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Creation Date
                      RichText(
                        text: TextSpan(
                          text: '${OrderStrings.date}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (order.creationDate == null)
                                  ? '--'
                                  : DateHelper.formatDate(order.creationDate!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Address if user is delivery, as an example
                      if (userType == UserType.delivery &&
                          order.address != null)
                        RichText(
                          text: TextSpan(
                            text: '${OrderStrings.deliveryIn}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: order.address,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),

                      // The placeholderStatus determined from last OrderStatus
                      RichText(
                        text: TextSpan(
                          text: '${OrderStrings.status}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: placeHolderStatusShow,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Items from orderProducts
                      RichText(
                        text: TextSpan(
                          text: '${OrderStrings.items}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '$itemsCount',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Button for viewing/tracking
                ElevatedButton(
                  onPressed: () {
                    // Then navigate:
                    void navigateToTracking() {
                      if (userType == UserType.delivery) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeliveryUserTracking(order: order),
                          ),
                        );
                      } else if (userType == UserType.business) {
                        Navigator.pushNamed(
                          context,
                          'business_user_order_tracking',
                          arguments: order,
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          'customer_user_order_tracking',
                          arguments: order,
                        );
                      }
                    }

                    // If the app requires real-time tracking with GPS
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
                      ? Text(
                          OrderStrings.takeOrder,
                          style: const TextStyle(color: Colors.white),
                        )
                      : Text(
                          OrderStrings.viewOrder,
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
