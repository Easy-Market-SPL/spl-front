import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/bloc/ui_management/location/location_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_event.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/navigation_bars/delivery_user_nav_bar.dart';

import '../../bloc/ui_management/map/map_bloc.dart';
import '../../providers/info_trip_provider.dart';
import '../../widgets/map/map_view_address.dart';
import '../order/delivery/order_details_delivery.dart';

class DeliveryUserTracking extends StatefulWidget {
  final Order? order;

  const DeliveryUserTracking({super.key, this.order});

  @override
  State<DeliveryUserTracking> createState() => _DeliveryUserTrackingState();
}

class _DeliveryUserTrackingState extends State<DeliveryUserTracking> {
  double distanceToDestination = 0.0;
  double timeToDestination = 0.0;
  String? currentOrderStatus;

  @override
  void initState() {
    super.initState();
    final locationBloc = BlocProvider.of<LocationBloc>(context, listen: false);
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    final searchBloc =
        BlocProvider.of<SearchPlacesBloc>(context, listen: false);
    final infoTripProvider =
        Provider.of<InfoTripProvider>(context, listen: false);

    // Inicializar el estado actual de la orden
    currentOrderStatus = widget.order?.status;

    locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      infoTripProvider.reset();
      drawDestinationRoute(
          context, locationBloc, mapBloc, searchBloc, infoTripProvider);
    });
  }

  Future<void> drawDestinationRoute(
    BuildContext context,
    LocationBloc locationBloc,
    MapBloc mapBloc,
    SearchPlacesBloc searchBloc,
    InfoTripProvider infoTripProvider,
  ) async {
    final start = locationBloc.state.lastKnowLocation;
    if (start == null || widget.order?.location == null) return;

    final end = widget.order!.location;
    final destination = await searchBloc.getCoorsStartToEnd(start, end!);
    final travelAnswer = await mapBloc.drawMyRoutePolyLine(destination);

    infoTripProvider.setDistance(travelAnswer.item1);
    infoTripProvider.setDuration(travelAnswer.item2);
  }

  @override
  Widget build(BuildContext context) {
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);
    final infoTripProvider = Provider.of<InfoTripProvider>(context);

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, mapState) {
        Map<String, Polyline> polylines =
            Map<String, Polyline>.from(mapState.polyLines);
        Map<String, Marker> markers = mapState.markers;

        return BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            if (locationState.lastKnowLocation == null) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!mapState.polyLines.isNotEmpty) {
              polylines.removeWhere((key, value) => key == 'delivery_route');
            }

            drawDestinationRoute(
                context, locationBloc, mapBloc, searchBloc, infoTripProvider);

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.popAndPushNamed(
                      context, 'delivery_user_orders'),
                ),
                title: Text(
                  'Orden #${widget.order?.id ?? "Unknown"}',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: Stack(
                children: [
                  Positioned.fill(
                    child: MapViewAddress(
                      initialLocation: locationState.lastKnowLocation!,
                      polyLines: polylines.values.toSet(),
                      markers: markers.values.toSet(),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Entregar en:',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                  Text(
                                    widget.order?.address ?? 'No disponible',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.run_circle,
                                    color: Colors.blue, size: 33),
                                onPressed: () {
                                  _confirmStatusChange(
                                      context, OrderStrings.onTheWay);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            'A nombre de: ${widget.order?.clientName ?? "Desconocido"}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.route, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                  'Aún estás a: ${infoTripProvider.distance} km',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87)),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.timer, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                  'Tiempo estimado: ${infoTripProvider.duration} minutos',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87)),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _confirmStatusChange(
                                        context, OrderStrings.statusDelivered);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    minimumSize: Size(140, 50),
                                  ),
                                  child: Text('Entregar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderDetailsDeliveryScreen(
                                          order: widget.order,
                                          userType: UserType.delivery,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    minimumSize: Size(140, 50),
                                  ),
                                  child: Text('Ver orden',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: DeliveryUserBottomNavigationBar(),
            );
          },
        );
      },
    );
  }

  void _confirmStatusChange(BuildContext context, String selectedStatus) {
    if (currentOrderStatus == selectedStatus) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error',
                style: TextStyle(fontWeight: FontWeight.w500)),
            content: Text(
                'La orden ya está en estado: "$selectedStatus". No puedes cambiarlo nuevamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(OrderStrings.accept,
                    style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(OrderStrings.confirmStatusChangeTitle,
              style: TextStyle(fontWeight: FontWeight.w500)),
          content:
              Text(OrderStrings.confirmStatusChangeContent(selectedStatus)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(OrderStrings.cancel,
                  style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                context.read<OrderListBloc>().add(
                    UpdateOrderStatusEvent(widget.order!.id!, selectedStatus));

                setState(() {
                  currentOrderStatus = selectedStatus;
                });

                if (selectedStatus == OrderStrings.delivered) {
                  Navigator.popAndPushNamed(context, 'delivery_user_orders');
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(OrderStrings.accept,
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
