import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';

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
                title: 'Orden confirmada',
                description: 'Tu orden ha sido procesada correctamente',
                notReachedTitle: 'Sin confirmar',
                notReachedDescription: 'Tu orden aún no ha sido aceptada',
                isActive: state.currentStatus == 'Orden confirmada' || state.currentStatus == 'Preparando la orden' || state.currentStatus == 'En camino' || state.currentStatus == 'Entregada',
              ),
              _buildStatusLine(state.currentStatus == 'Preparando la orden' || state.currentStatus == 'En camino' || state.currentStatus == 'Entregada'),
              _buildStatusItem(
                context,
                icon: Icons.access_time,
                title: 'Preparando la orden',
                description: 'Tu orden está siendo preparada para su entrega',
                notReachedTitle: 'Sin preparar',
                notReachedDescription: 'Tu orden aún no se ha procesado',
                isActive: state.currentStatus == 'Preparando la orden' || state.currentStatus == 'En camino' || state.currentStatus == 'Entregada',
              ),
              _buildStatusLine(state.currentStatus == 'En camino' || state.currentStatus == 'Entregada'),
              _buildStatusItem(
                context,
                icon: Icons.local_shipping,
                title: 'En camino',
                description: 'La orden ha salido en camino',
                notReachedTitle: 'Sin salir',
                notReachedDescription: 'Tu orden no está lista para partir',
                isActive: state.currentStatus == 'En camino' || state.currentStatus == 'Entregada',
              ),
              _buildStatusLine(state.currentStatus == 'Entregada'),
              _buildStatusItem(
                context,
                icon: Icons.check,
                title: 'Entregada',
                description: 'La orden ha sido entregada',
                notReachedTitle: 'Sin entregar',
                notReachedDescription: 'Tu orden aún no ha sido entregada',
                isActive: state.currentStatus == 'Entregada',
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