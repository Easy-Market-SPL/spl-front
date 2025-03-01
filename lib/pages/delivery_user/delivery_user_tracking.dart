import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/order/order_tracking.dart';

class DeliveryUserTracking extends StatefulWidget {
  final Order? order;

  const DeliveryUserTracking({super.key, this.order});

  @override
  State<DeliveryUserTracking> createState() => _DeliveryUserTrackingState();
}

class _DeliveryUserTrackingState extends State<DeliveryUserTracking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Orden #${123456}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mapa
          SizedBox(
            height: 250,
            child: MapViewAddress(
              initialLocation: LatLng(widget.order!.location!.latitude,
                  widget.order!.location!.longitude),
              zoom: 15.0,
              markers: _createMarkers(widget.order!),
            ),
          ),

          // Detalles de la orden
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entregar en: ${widget.order!.address}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'A nombre de: ${widget.order!.clientName}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Aún estas a: ${5} km',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Acción para entregar la orden
                        // Navegar o cambiar el estado
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(140, 50),
                      ),
                      child: Text(
                        'Entregar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderTrackingScreen(
                              userType: UserType.delivery,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(140, 50),
                      ),
                      child: Text(
                        'Ver orden',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers(Order order) {
    return {
      Marker(
        markerId: MarkerId('orderLocation'),
        position: LatLng(order.location!.latitude, order.location!.longitude),
        infoWindow: InfoWindow(title: 'Ubicación de la Orden'),
      ),
    };
  }
}

class MapViewAddress extends StatelessWidget {
  final LatLng initialLocation;
  final double zoom;
  final Set<Marker> markers;

  const MapViewAddress({
    super.key,
    required this.initialLocation,
    this.zoom = 15.0,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialLocation,
        zoom: zoom,
      ),
      markers: markers,
    );
  }
}
