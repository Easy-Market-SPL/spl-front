import 'package:flutter/material.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/pages/order/web/order_tracking_web.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

import '../../../../../models/helpers/intern_logic/user_type.dart';

class OrderItemWeb extends StatelessWidget {
  final OrderModel order;
  final UserType userType;

  const OrderItemWeb({
    super.key,
    required this.order,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final itemsCount =
        (order.orderProducts).fold<int>(0, (sum, op) => sum + op.quantity);

    final placeholderStatus = (order.orderStatuses.isNotEmpty)
        ? order.orderStatuses.last.status
        : '(no status)';

    final creationDate = (order.creationDate == null)
        ? '--'
        : DateHelper.formatDate(order.creationDate!);

    final statusMap = {
      'confirmed': 'Confirmada',
      'preparing': 'Preparando',
      'on the way': 'En Camino',
      'delivered': 'Entregada',
    };

    // Get the translated status or default to 'Sin Estado'
    final placeHolderStatusShow = statusMap[placeholderStatus] ?? 'Sin Estado';

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 30,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${OrderStrings.items}: $itemsCount',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '${OrderStrings.idOrder}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: order.id.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      // Fecha
                      Text(
                        '${OrderStrings.orderDate}: $creationDate',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        '${OrderStrings.status}: $placeHolderStatusShow',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => OrderTrackingWebScreen(
                       userType: userType,
                       order: order,
                     ),
                   ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Ver orden',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
