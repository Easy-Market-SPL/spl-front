import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_event.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/widgets/order/order_tracking_header.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderTrackingPage();
  }
}

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingPage> {
  String _selectedStatus = 'En camino';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OrderTrackingHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Tracker
                    BlocBuilder<OrderStatusBloc, OrderStatusState>(
                      builder: (context, state) {
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
                      },
                    ),
                    SizedBox(height: 32.0),
                    // Current Status
                    BlocBuilder<OrderStatusBloc, OrderStatusState>(
                      builder: (context, state) {
                        return Center(
                          child: Column(
                            children: [
                              Text(
                                'Estado: ${state.currentStatus}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                state.description,
                                style: TextStyle(fontSize: 16, color: const Color.fromARGB(127, 0, 0, 0)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.0),
                    // Modify order status options
                    Text(
                      'Modificar estado de la orden',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Column(
                        children: [
                          _buildStatusOption('Orden confirmada'),
                          _buildStatusOption('Preparando la orden'),
                          _buildStatusOption('En camino'),
                          _buildStatusOption('Entregada'),
                        ],
                      ),
                    SizedBox(height: 24.0),
                    // Buttons
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 37, 139, 217), //rgb(37, 139, 217)
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('Ver detalles de la orden', style: TextStyle(color: Colors.white),),
                    ),
                    SizedBox(height: 8.0),
                    BlocBuilder<OrderStatusBloc, OrderStatusState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: _selectedStatus != state.currentStatus ? () {
                            _confirmStatusChange(context);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedStatus != state.currentStatus ? Colors.green : Colors.grey[350],
                            minimumSize: Size(double.infinity, 48),
                          ),
                          child: Text('Confirmar', style: TextStyle(color: Colors.black),),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, bool isActive) {
    return Icon(icon, color: isActive ? const Color.fromARGB(255, 0, 73, 143) : Colors.grey, size: 40,);
  }

  Widget _buildStatusLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.0,
        color: isActive ? Color.fromARGB(255, 0, 73, 143): Colors.grey,
      ),
    );
  }

  Widget _buildStatusOption(String status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.blue,
        ),
        child: RadioListTile<String>(
          title: Text(status),
          value: status,
          groupValue: _selectedStatus,
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;  // Solo actualiza la variable local, no emite evento aquí
            });
          },
          activeColor: Colors.blue,
          controlAffinity: ListTileControlAffinity.trailing, // Mueve el botón de radio a la derecha
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  void _confirmStatusChange(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar cambio de estado'),
          content: Text('¿Estás seguro de que deseas cambiar el estado de la orden a "$_selectedStatus"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el diálogo sin hacer nada
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.blue),),
            ),
            TextButton(
              onPressed: () {
                // Emite el evento para cambiar el estado sin necesidad de un Builder
                context.read<OrderStatusBloc>().add(ChangeOrderStatusEvent(_selectedStatus));
                Navigator.of(context).pop();  // Cierra el diálogo después de confirmar
              },
              child: Text('Aceptar', style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }
}