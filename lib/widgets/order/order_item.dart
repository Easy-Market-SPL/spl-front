import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/pages/order/order_tracking.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class OrderItem extends StatelessWidget {
  final Order order;
  final ChatUserType userType;

  const OrderItem({super.key, required this.order, required this.userType});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
              child: Icon(Icons.shopping_bag, size: 30, color: Colors.black54),
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
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: formatter.format(order.date),
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),

                  // Client
                  if (userType == ChatUserType.business)
                    RichText(
                      text: TextSpan(
                        text: '${OrderStrings.client}: ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: order.clientName,
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),

                  // Status
                  RichText(
                    text: TextSpan(
                      text: '${OrderStrings.status}: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: order.status,
                          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),

                  // Items
                  RichText(
                    text: TextSpan(
                      text: '${OrderStrings.items}: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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

            //Order tracking button
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderTrackingScreen(userType: userType)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
              child: Text(OrderStrings.viewOrder, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}