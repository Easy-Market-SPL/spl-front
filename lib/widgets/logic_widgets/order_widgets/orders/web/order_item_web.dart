import 'package:flutter/material.dart';
import 'package:spl_front/models/order_models/order_model.dart';
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

    const clientNamePlaceholder = '(clientName_placeholder)';

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
                      // Fecha
                      Text(
                        '${OrderStrings.orderDate}: $creationDate',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),

                      if (userType == UserType.business) ...[
                        Text(
                          '${OrderStrings.client}: $clientNamePlaceholder',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                      ],

                      Text(
                        '${OrderStrings.status}: $placeholderStatus',
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
                  if (userType == UserType.business) {
                    Navigator.of(context).pushNamed(
                      'business_user_order_tracking',
                      arguments: order,
                    );
                  } else {
                    Navigator.of(context).pushNamed(
                      'customer_user_order_tracking',
                      arguments: order,
                    );
                  }
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
