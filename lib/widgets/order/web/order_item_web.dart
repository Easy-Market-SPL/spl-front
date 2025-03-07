import 'package:flutter/material.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';

class OrderItemWeb extends StatelessWidget {
  final Order order;
  final UserType userType;

  const OrderItemWeb({super.key, required this.order, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        // Usamos mainAxisSize.min para que el Column se ajuste a su contenido
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono y datos de la orden
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
                      child: Icon(Icons.shopping_bag, size: 30, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${OrderStrings.items}: ${order.items.toString()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${OrderStrings.orderDate}: ${DateHelper.formatDate(order.date)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      if (userType == UserType.business) ...[
                        Text(
                          '${OrderStrings.client}: ${order.clientName}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                      ],
                      Text(
                        '${OrderStrings.status}: ${order.status}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Separamos con un SizedBox en lugar de usar Spacer
            const SizedBox(height: 10),
            // Botón centrado
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  if (userType == UserType.business) {
                    Navigator.of(context).pushNamed('business_user_order_tracking', arguments: order);
                  } else {
                    Navigator.of(context).pushNamed('customer_user_order_tracking', arguments: order);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text('Ver orden', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
