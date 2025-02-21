import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class VerticalOrderStatus extends StatelessWidget {
  const VerticalOrderStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderStatusBloc, OrderStatusState>(
      builder: (context, state) {
        if (state is OrderStatusLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusItem(
                context,
                icon: Icons.store,
                title: OrderStrings.orderConfirmed,
                description: OrderStrings.orderConfirmedDescription,
                notReachedTitle: OrderStrings.notConfirmed,
                notReachedDescription: OrderStrings.notConfirmedDescription,
                isActive: state.currentStatus == OrderStrings.orderConfirmed || state.currentStatus == OrderStrings.preparingOrder || state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered,
              ),
              _buildStatusLine(state.currentStatus == OrderStrings.preparingOrder || state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered),
              _buildStatusItem(
                context,
                icon: Icons.access_time,
                title: OrderStrings.preparingOrder,
                description: OrderStrings.preparingOrderDescription,
                notReachedTitle: OrderStrings.notPrepared,
                notReachedDescription: OrderStrings.notPreparedDescription,
                isActive: state.currentStatus == OrderStrings.preparingOrder || state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered,
              ),
              _buildStatusLine(state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered),
              _buildStatusItem(
                context,
                icon: Icons.local_shipping,
                title: OrderStrings.onTheWay,
                description: OrderStrings.onTheWayDescription,
                notReachedTitle: OrderStrings.notOnTheWay,
                notReachedDescription: OrderStrings.notOnTheWayDescription,
                isActive: state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered,
              ),
              _buildStatusLine(state.currentStatus == OrderStrings.delivered),
              _buildStatusItem(
                context,
                icon: Icons.check,
                title: OrderStrings.delivered,
                description: OrderStrings.deliveredDescription,
                notReachedTitle: OrderStrings.notDelivered,
                notReachedDescription: OrderStrings.notDeliveredDescription,
                isActive: state.currentStatus == OrderStrings.delivered,
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String notReachedTitle,
    required String notReachedDescription,
    required bool isActive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey, size: 45),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? title : notReachedTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey),
                ),
                Text(
                  isActive ? description : notReachedDescription,
                  style: TextStyle(fontSize: 14, color: isActive ? Colors.black : Colors.grey),
                ),
              ],
            ),
          ],
        ),
        //const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildStatusLine(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0),
      height: 50.0,
      width: 3.0,
      color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey,
    );
  }
}