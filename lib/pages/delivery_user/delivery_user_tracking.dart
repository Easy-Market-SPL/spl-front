import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/bloc/ui_management/location/location_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/order/order_tracking.dart';
import 'package:spl_front/widgets/navigation_bars/delivery_user_nav_bar.dart';

import '../../bloc/ui_management/map/map_bloc.dart';
import '../../providers/info_trip_provider.dart';
import '../../widgets/map/map_view_address.dart';

class DeliveryUserTracking extends StatefulWidget {
  final Order? order;

  const DeliveryUserTracking({super.key, this.order});

  @override
  State<DeliveryUserTracking> createState() => _DeliveryUserTrackingState();
}

class _DeliveryUserTrackingState extends State<DeliveryUserTracking> {
  double distanceToDestination = 0.0;
  double timeToDestination = 0.0;

  @override
  void initState() {
    super.initState();
    final locationBloc = BlocProvider.of<LocationBloc>(context, listen: false);
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    final searchBloc =
        BlocProvider.of<SearchPlacesBloc>(context, listen: false);
    final infoTripProvider =
        Provider.of<InfoTripProvider>(context, listen: false);

    // Set as blank the distance and duration of the trip
    infoTripProvider.setDistance(0);
    infoTripProvider.setDuration(0);

    locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();

    drawDestinationRoute(
        context, locationBloc, mapBloc, searchBloc, infoTripProvider);
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

    // Update the distance and duration of the trip
    infoTripProvider.setDistance(travelAnswer.item1);
    infoTripProvider.setDuration(travelAnswer.item2);
  }

  @override
  Widget build(BuildContext context) {
    // Bloc Providers:
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);

    // Notifier Providers:
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

            // Check if a route is already drawn
            if (!mapState.polyLines.isNotEmpty) {
              polylines.removeWhere((key, value) => key == 'delivery_route');
            }

            // Draw the route when the location is available and change the state
            drawDestinationRoute(
                context, locationBloc, mapBloc, searchBloc, infoTripProvider);

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.run_circle,
                                  color: Colors.blue,
                                  size: 33,
                                ),
                                onPressed: () {
                                  // TODO: Change order status
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                              'A nombre de: ${widget.order?.clientName ?? "Desconocido"}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87)),
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
                                  onPressed: () {},
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
                                            OrderTrackingScreen(
                                                userType: UserType.delivery),
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
}
