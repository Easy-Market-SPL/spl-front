import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../bloc/ui_management/location/location_bloc.dart';
import '../../bloc/ui_management/map/map_bloc.dart';
import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_event.dart';
import '../../bloc/ui_management/order/order_state.dart';
import '../../bloc/ui_management/search_places/search_places_bloc.dart';
import '../../models/logic/user_type.dart';
import '../../models/order_models/order_model.dart';
import '../../providers/info_trip_provider.dart';
import '../../utils/strings/order_strings.dart';
import '../../widgets/map/map_view_address.dart';
import '../../widgets/navigation_bars/nav_bar.dart';

class DeliveryUserTracking extends StatefulWidget {
  final OrderModel? order;

  const DeliveryUserTracking({super.key, this.order});

  @override
  State<DeliveryUserTracking> createState() => _DeliveryUserTrackingState();
}

class _DeliveryUserTrackingState extends State<DeliveryUserTracking> {
  double distanceToDestination = 0.0;
  double timeToDestination = 0.0;
  String? currentOrderStatus;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final ordersBloc = context.read<OrdersBloc>();
    final locationBloc = context.read<LocationBloc>();
    final mapBloc = context.read<MapBloc>();
    final searchBloc = context.read<SearchPlacesBloc>();
    final infoTripProvider =
        Provider.of<InfoTripProvider>(context, listen: false);

    final ordersState = ordersBloc.state;
    if (ordersState is! OrdersLoaded) {
      ordersBloc.add(
        LoadOrdersEvent(
          userId: 'DELIVERY_USER_123',
          userRole: 'delivery',
        ),
      );
    }

    currentOrderStatus = _extractLastStatus(widget.order);

    locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      infoTripProvider.reset();
      _drawDestinationRoute(
        context,
        locationBloc,
        mapBloc,
        searchBloc,
        infoTripProvider,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationBloc = context.read<LocationBloc>();
    final mapBloc = context.read<MapBloc>();
    final searchBloc = context.read<SearchPlacesBloc>();
    final infoTripProvider = Provider.of<InfoTripProvider>(context);

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, mapState) {
        final markers = mapState.markers;

        return BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            if (locationState.lastKnowLocation == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            _drawDestinationRoute(
              context,
              locationBloc,
              mapBloc,
              searchBloc,
              infoTripProvider,
            );

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.popAndPushNamed(
                    context,
                    'delivery_user_orders',
                  ),
                ),
                title: Text(
                  OrderStrings.orderNumberString(widget.order?.id as String?),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 20),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: Stack(
                children: [
                  Positioned.fill(
                    child: MapViewAddress(
                      initialLocation: locationState.lastKnowLocation!,
                      markers: markers.values.toSet(),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.05,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.expand_less_rounded,
                          color: Colors.white),
                    ),
                  ),
                  if (_isExpanded)
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.05,
                      left: 20,
                      right: 20,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
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
                                const Text(
                                  OrderStrings.deliverAt,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.expand_more_outlined,
                                      color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Text(
                              widget.order?.address ??
                                  OrderStrings.notAvailable,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              OrderStrings.nameOrder(widget.order?.idUser),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.route, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  infoTripProvider.metersDistance == true
                                      ? OrderStrings.estimatedDistanceMeters(
                                          infoTripProvider.distance)
                                      : OrderStrings.estimatedDistanceKms(
                                          infoTripProvider.distance),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.timer, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  OrderStrings.estimatedDeliveryMinutes(
                                      infoTripProvider.duration),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              bottomNavigationBar: CustomBottomNavigationBar(
                userType: UserType.delivery,
                context: context,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _drawDestinationRoute(
    BuildContext context,
    LocationBloc locationBloc,
    MapBloc mapBloc,
    SearchPlacesBloc searchBloc,
    InfoTripProvider infoTripProvider,
  ) async {
    final start = locationBloc.state.lastKnowLocation;
    if (start == null) return;
    if (widget.order?.lat == null || widget.order?.lng == null) return;

    final end = LatLng(widget.order!.lat!, widget.order!.lng!);
    final travelAnswer =
        await mapBloc.drawMarkersAndGetDistanceBetweenPoints(start, end);

    infoTripProvider.setDistance(travelAnswer.item1);
    infoTripProvider.setMeters(travelAnswer.item2);
    infoTripProvider.setDuration(
      _calculateMinutes(travelAnswer.item1, travelAnswer.item2),
    );
  }

  int _calculateMinutes(double distance, bool isMeters) {
    final timeInMinutes = isMeters ? (distance / 1000) * 3.5 : distance * 3.5;
    return timeInMinutes.round();
  }

  String? _extractLastStatus(OrderModel? order) {
    if (order?.orderStatuses == null || order!.orderStatuses!.isEmpty)
      return null;
    return order.orderStatuses!.last.status;
  }
}
