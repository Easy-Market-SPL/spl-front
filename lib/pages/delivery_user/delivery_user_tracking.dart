// lib/pages/order/tracking/delivery_user_tracking.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/models/user.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

import '../../bloc/ui_management/location/location_bloc.dart';
import '../../bloc/ui_management/map/map_bloc.dart';
import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_event.dart';
import '../../bloc/ui_management/order/order_state.dart';
import '../../bloc/ui_management/search_places/search_places_bloc.dart';
import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/logic/user_type.dart';
import '../../models/order_models/order_model.dart';
import '../../models/order_models/order_status.dart';
import '../../providers/info_trip_provider.dart';
import '../../utils/strings/order_strings.dart';
import '../../widgets/map/map_view_address.dart';
import '../../widgets/navigation_bars/nav_bar.dart';

class DeliveryUserTracking extends StatefulWidget {
  final OrderModel? order;
  final bool? isTriggerDelivery;

  const DeliveryUserTracking({
    super.key,
    this.order,
    this.isTriggerDelivery,
  });

  @override
  DeliveryUserTrackingState createState() => DeliveryUserTrackingState();
}

class DeliveryUserTrackingState extends State<DeliveryUserTracking> {
  late final bool isDelivery;
  late final Future<UserModel?> _userFuture;
  bool _isExpanded = false;
  bool _didSendOnTheWay = false;

  @override
  void initState() {
    super.initState();

    // Clear any existing markers when the screen loads
    final mapBloc = context.read<MapBloc>();
    mapBloc.clearMarkers();

    // Determine if we should trigger the "on the way" event
    isDelivery = widget.isTriggerDelivery ?? false;
    // Fetch customer info by user ID
    _userFuture = UserService.getUser(widget.order!.idUser!);

    // Ensure the order is loaded into OrdersBloc
    final ordersBloc = context.read<OrdersBloc>();
    if (ordersBloc.state is! OrdersLoaded) {
      ordersBloc.add(LoadSingleOrderEvent(widget.order!.id!));
    }

    // Start listening to device location and follow user
    final locationBloc = context.read<LocationBloc>();
    final searchBloc = context.read<SearchPlacesBloc>();
    locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();
    // Decode address to LatLng
    searchBloc.getPlacesByGoogleQuery(widget.order!.address!);
  }

  @override
  Widget build(BuildContext context) {
    final mapBloc = context.read<MapBloc>();
    final infoTrip = Provider.of<InfoTripProvider>(context, listen: false);

    return MultiBlocListener(
      listeners: [
        // Listen for location updates to redraw the route and send "on the way"
        BlocListener<LocationBloc, LocationState>(
          listener: (context, locState) {
            final loc = locState.lastKnowLocation;
            if (loc == null) return;

            // redraw the route whenever location changes
            final places = context.read<SearchPlacesBloc>().state.googlePlaces;
            if (places != null && places.isNotEmpty) {
              _drawDestinationRoute(
                loc,
                places.first,
                mapBloc,
                infoTrip,
              );
            }

            // send the "on the way" event only once per session
            if (isDelivery && !_didSendOnTheWay) {
              _didSendOnTheWay = true;
              final userId = context.read<UsersBloc>().state.sessionUser!.id;
              context.read<OrdersBloc>().add(
                    OnTheWayDomiciliaryOrderEvent(
                      orderId: widget.order!.id!,
                      idDomiciliary: userId,
                      initialLatitude: loc.latitude,
                      initialLongitude: loc.longitude,
                    ),
                  );
            }
          },
        ),
        // Listen for address decoding to redraw route if location is ready
        BlocListener<SearchPlacesBloc, SearchPlacesState>(
          listener: (context, state) {
            final loc = context.read<LocationBloc>().state.lastKnowLocation;
            if (loc != null &&
                state.googlePlaces != null &&
                state.googlePlaces!.isNotEmpty) {
              _drawDestinationRoute(
                loc,
                state.googlePlaces!.first,
                mapBloc,
                infoTrip,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          if (locationState.lastKnowLocation == null) {
            // show loading while waiting for initial location
            return const Scaffold(
              body: Center(child: CustomLoading()),
            );
          }

          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) {
              return Scaffold(
                appBar: AppBar(
                  // Back button to return to the orders list
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.popAndPushNamed(
                      context,
                      'delivery_user_orders',
                    ),
                  ),
                  title: Text(
                    OrderStrings.orderNumberString(
                      widget.order!.id.toString(),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                body: Stack(
                  children: [
                    // Display the Google Map with markers
                    Positioned.fill(
                      child: MapView(
                        initialLocation: locationState.lastKnowLocation!,
                        markers: mapState.markers.values.toSet(),
                      ),
                    ),

                    // FAB to center camera on current location
                    Positioned(
                      bottom: _isExpanded
                          ? MediaQuery.of(context).size.height * 0.35
                          : MediaQuery.of(context).size.height * 0.13,
                      right: 20,
                      child: FloatingActionButton(
                        heroTag: 'moveCameraFAB', // Unique hero tag
                        backgroundColor: Colors.blue,
                        onPressed: () => mapBloc.moveCamera(
                          locationState.lastKnowLocation!,
                        ),
                        child: const Icon(
                          Icons.directions_walk,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // FAB to toggle expand/collapse of info card
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.05,
                      right: 20,
                      child: FloatingActionButton(
                        heroTag: 'toggleExpandFAB', // Unique hero tag
                        backgroundColor: Colors.blue,
                        onPressed: () =>
                            setState(() => _isExpanded = !_isExpanded),
                        child: Icon(
                          _isExpanded
                              ? Icons.expand_more_outlined
                              : Icons.expand_less,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Show info card when expanded
                    if (_isExpanded) _buildInfoCard(context, infoTrip),
                  ],
                ),
                // Custom bottom navigation bar for delivery role
                bottomNavigationBar: CustomBottomNavigationBar(
                  userType: UserType.delivery,
                  context: context,
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Builds the info card with address, customer, distance, duration, and action
  Widget _buildInfoCard(
    BuildContext context,
    InfoTripProvider tripInfo,
  ) =>
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
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with collapse button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    OrderStrings.deliverAt,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.expand_more_outlined,
                      color: Colors.blue,
                    ),
                    onPressed: () => setState(() => _isExpanded = false),
                  ),
                ],
              ),

              // Delivery address line
              Text(
                widget.order?.address ?? OrderStrings.notAvailable,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),

              // Customer name fetched via FutureBuilder
              FutureBuilder<UserModel?>(
                future: _userFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  final name = snap.data?.fullname ?? '';
                  return Text(
                    name.isNotEmpty ? OrderStrings.nameOrder(name) : 'Cliente:',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Distance row
              Row(
                children: [
                  const Icon(Icons.route, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    tripInfo.metersDistance
                        ? OrderStrings.estimatedDistanceMeters(
                            tripInfo.distance)
                        : OrderStrings.estimatedDistanceKms(tripInfo.distance),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Duration row
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    OrderStrings.estimatedDeliveryMinutes(
                      tripInfo.duration,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Show button or delivered date depending on last status
              Builder(
                builder: (_) {
                  final lastStatus = widget.order!.orderStatuses.last.status;
                  if (lastStatus != 'delivered') {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add delivered status locally and fire event
                          setState(() {
                            final now = DateTime.now();
                            widget.order!.orderStatuses.add(
                              OrderStatus(
                                status: 'delivered',
                                startDate: now,
                              ),
                            );
                          });
                          context.read<OrdersBloc>().add(
                                DeliveredOrderEvent(widget.order!.id!),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Entregar Orden',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Display the delivered date
                    final deliveredStatus = widget.order!.orderStatuses
                        .lastWhere((s) => s.status == 'delivered');
                    final dateText = DateFormat('dd/MM/yyyy')
                        .format(deliveredStatus.startDate);
                    return Row(
                      children: [
                        const Text(
                          'Orden Entregada:',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );

  /// Draws route polyline and markers, then updates distance and duration.
  Future<void> _drawDestinationRoute(
    LatLng start,
    dynamic destinationPlace,
    MapBloc mapBloc,
    InfoTripProvider infoTripProvider,
  ) async {
    // Compute destination LatLng
    final end = LatLng(
      destinationPlace.geometry.location.lat,
      destinationPlace.geometry.location.lng,
    );
    // Draw markers & polyline and retrieve distance info
    final travelAnswer =
        await mapBloc.drawMarkersAndGetDistanceBetweenPoints(start, end);

    // Update provider with calculated metrics
    infoTripProvider.setDistance(travelAnswer.item1);
    infoTripProvider.setMeters(travelAnswer.item2);
    infoTripProvider.setDuration(
      _calculateMinutes(travelAnswer.item1, travelAnswer.item2),
    );
  }

  /// Converts distance (meters or kms) into estimated time in minutes.
  int _calculateMinutes(double distance, bool isMeters) {
    final timeInMinutes = isMeters ? (distance / 1000) * 3.5 : distance * 3.5;
    return timeInMinutes.round();
  }
}
