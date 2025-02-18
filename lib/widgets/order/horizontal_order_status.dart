import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';

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
                  _buildStatusIcon(Icons.store, state.currentStatus == 'Orden confirmada' || state.currentStatus == 'Preparando la orden' || state.currentStatus == 'En camino' || state.currentStatus == 'Entregada'),
                  _buildStatusLine(state.currentStatus == 'Preparando la orden' || state.currentStatus == 'En camino' || state.currentStatus == 'Entregada'),
                  _buildStatusIcon(Icons.access_time, state.currentStatus == 'Preparando la orden' || state.currentStatus == 'En camino' || state.currentStatus == 'Entregada'),
                  _buildStatusLine(state.currentStatus == 'En camino' || state.currentStatus == 'Entregada'),
                  _buildStatusIcon(Icons.local_shipping, state.currentStatus == 'En camino' || state.currentStatus == 'Entregada'),
                  _buildStatusLine(state.currentStatus == 'Entregada'),
                  _buildStatusIcon(Icons.check, state.currentStatus == 'Entregada'),
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
                      'Estado: ${state.currentStatus}',
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