import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class HorizontalOrderStatus extends StatelessWidget {
  const HorizontalOrderStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Tracker
        BlocBuilder<OrderStatusBloc, OrderStatusState>(
          builder: (context, state) {
            if (state is OrderStatusLoaded) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusIcon(Icons.store, state.currentStatus == OrderStrings.orderConfirmed || state.currentStatus == OrderStrings.preparingOrder || state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered),
                  _buildStatusLine(state.currentStatus == OrderStrings.preparingOrder || state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered),
                  _buildStatusIcon(Icons.access_time, state.currentStatus == OrderStrings.preparingOrder || state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered),
                  _buildStatusLine(state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered),
                  _buildStatusIcon(Icons.local_shipping, state.currentStatus == OrderStrings.onTheWay || state.currentStatus == OrderStrings.delivered),
                  _buildStatusLine(state.currentStatus == OrderStrings.delivered),
                  _buildStatusIcon(Icons.check, state.currentStatus == OrderStrings.delivered),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
        const SizedBox(height: 32.0),
        // Current Status
        BlocBuilder<OrderStatusBloc, OrderStatusState>(
          builder: (context, state) {
            if (state is OrderStatusLoaded) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      '${OrderStrings.status}: ${state.currentStatus}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      state.description,
                      style: const TextStyle(fontSize: 16, color: Color.fromARGB(127, 0, 0, 0)),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatusIcon(IconData icon, bool isActive) {
    return Icon(icon, color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey, size: 40,);
  }

  Widget _buildStatusLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.0,
        color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey,
      ),
    );
  }
}