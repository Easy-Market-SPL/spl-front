// lib/pages/order/tracking/order_map_following.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/bloc/ui_management/map/map_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/bloc/ui_management/order/order_state.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/models/order_models/order_status.dart';
import 'package:spl_front/models/user.dart';
import 'package:spl_front/providers/info_trip_provider.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/services/supabase/real-time/real_time_tracking_service.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/map/map_view_address.dart';

class OrderMapFollowing extends StatefulWidget {
  final OrderModel order;
  final UserType userType;

  const OrderMapFollowing({
    super.key,
    required this.order,
    required this.userType,
  });

  @override
  State<OrderMapFollowing> createState() => _OrderMapFollowingState();
}

class _OrderMapFollowingState extends State<OrderMapFollowing> {
  /* -------------------- DATA & SERVICIOS -------------------- */
  late final Future<UserModel?> _userFuture;
  final _trackingSvc = DeliveryTrackingService();
  StreamSubscription<List<Map<String, dynamic>>>? _trackingSub;

  LatLng? _startLocation; // Courier location
  LatLng? _endLocation; // Destination location decoded from Google API

  bool _isExpanded = false;
  static const Color darkBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();

    context.read<MapBloc>().clearMarkers();

    _userFuture = UserService.getUser(widget.order.idUser!);

    final ordersBloc = context.read<OrdersBloc>();
    if (ordersBloc.state is! OrdersLoaded) {
      ordersBloc.add(LoadSingleOrderEvent(widget.order.id!));
    }

    context
        .read<SearchPlacesBloc>()
        .getPlacesByGoogleQuery(widget.order.address!);

    if (widget.order.idDomiciliary != null) {
      _trackingSub = _trackingSvc
          .watchUser(widget.order.idDomiciliary!)
          .listen(_handleTrackingRows);
    }
  }

  @override
  void dispose() {
    _trackingSub?.cancel();
    super.dispose();
  }

  void _handleTrackingRows(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;

    final last = rows.last;
    final lat = (last['latitude'] as num?)?.toDouble();
    final lng = (last['longitude'] as num?)?.toDouble();

    if (lat == null || lng == null) return;

    final newPos = LatLng(lat, lng);
    if (_startLocation == null ||
        _startLocation!.latitude != newPos.latitude ||
        _startLocation!.longitude != newPos.longitude) {
      setState(() => _startLocation = newPos);

      // Si ya tenemos destino decodificado → dibujamos ruta y marcadores
      final places = context.read<SearchPlacesBloc>().state.googlePlaces;
      if (places != null && places.isNotEmpty) {
        _drawDestinationRoute(
          newPos,
          places.first,
          context.read<MapBloc>(),
          Provider.of<InfoTripProvider>(context, listen: false),
        );
      }
    }
  }

  /* ========================== UI ========================= */
  @override
  Widget build(BuildContext context) {
    final mapBloc = context.read<MapBloc>();
    final infoTrip = Provider.of<InfoTripProvider>(context, listen: false);

    final LatLng? startLocation = _startLocation ??
        (widget.order.lat != null && widget.order.lng != null
            ? LatLng(widget.order.lat!, widget.order.lng!)
            : null);

    return MultiBlocListener(
      listeners: [
        BlocListener<SearchPlacesBloc, SearchPlacesState>(
          listener: (context, state) {
            if (state.googlePlaces != null && state.googlePlaces!.isNotEmpty) {
              final destLatLng = LatLng(
                state.googlePlaces!.first.geometry.location.lat,
                state.googlePlaces!.first.geometry.location.lng,
              );
              _endLocation = destLatLng;
              mapBloc.drawDestinationMarker(destLatLng);

              if (startLocation != null) {
                _drawDestinationRoute(
                  startLocation,
                  state.googlePlaces!.first,
                  mapBloc,
                  infoTrip,
                );
              }
            }
          },
        ),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          // Pantalla de carga si no hay ni origen ni destino
          if (startLocation == null && _endLocation == null) {
            return const Scaffold(body: Center(child: CustomLoading()));
          }

          final LatLng initial = startLocation ?? _endLocation!;

          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: MapView(
                    initialLocation: initial,
                    markers: mapState.markers.values.toSet(),
                  ),
                ),
                Positioned(
                  bottom: _isExpanded && startLocation != null
                      ? MediaQuery.of(context).size.height * 0.38
                      : _isExpanded && startLocation == null
                          ? MediaQuery.of(context).size.height * 0.28
                          : MediaQuery.of(context).size.height * 0.15,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: 'followFAB',
                    backgroundColor: darkBlue,
                    onPressed: () {
                      final target = startLocation ?? _endLocation!;
                      mapBloc.moveCamera(target);
                    },
                    child:
                        const Icon(Icons.directions_walk, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.08,
                  right: 20,
                  child: _isExpanded
                      ? const SizedBox.shrink()
                      : FloatingActionButton(
                          heroTag: 'expandFAB',
                          backgroundColor: darkBlue,
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
                if (_isExpanded)
                  startLocation != null
                      ? _buildFullInfoCard(context, infoTrip)
                      : _buildSimplifiedInfoCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the full info card with distance, duration, and deliver button.
  Widget _buildFullInfoCard(BuildContext context, InfoTripProvider tripInfo) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.10,
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
                    color: darkBlue, // use corporate color
                  ),
                  onPressed: () => setState(() => _isExpanded = false),
                ),
              ],
            ),

            // Delivery address line
            Text(
              widget.order.address ?? OrderStrings.notAvailable,
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
                      ? OrderStrings.estimatedDistanceMeters(tripInfo.distance)
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
                  OrderStrings.estimatedDeliveryMinutes(tripInfo.duration),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deliver button or delivered date
            Builder(builder: (_) {
              final lastStatus = widget.order.orderStatuses.last.status;
              // Show button only if not delivered and user can deliver
              if (lastStatus != 'delivered' &&
                  (widget.userType == UserType.admin ||
                      widget.userType == UserType.business)) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Update local model immediately
                      setState(() {
                        widget.order.orderStatuses.add(
                          OrderStatus(
                            status: 'delivered',
                            startDate: DateTime.now(),
                          ),
                        );
                      });
                      // Fire BLoC event to persist delivery
                      context
                          .read<OrdersBloc>()
                          .add(DeliveredOrderEvent(widget.order.id!));
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
                // Show delivered date
                final deliveredStatus = widget.order.orderStatuses
                    .lastWhere((s) => s.status == 'delivered');
                final dateText =
                    DateFormat('dd/MM/yyyy').format(deliveredStatus.startDate);
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
            }),
          ],
        ),
      ),
    );
  }

  /// Builds a simplified info card (only address + customer) when no start location.
  Widget _buildSimplifiedInfoCard(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.10,
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
                    color: darkBlue,
                  ),
                  onPressed: () => setState(() => _isExpanded = false),
                ),
              ],
            ),

            // Address only
            Text(
              widget.order.address ?? OrderStrings.notAvailable,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),

            // Customer name only
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
          ],
        ),
      ),
    );
  }

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

    // Draw markers and polyline, retrieve distance info
    final travelAnswer =
        await mapBloc.drawMarkersAndGetDistanceBetweenPoints(start, end);

    // Update provider with calculated metrics
    infoTripProvider.setDistance(travelAnswer.item1);
    infoTripProvider.setMeters(travelAnswer.item2);
    infoTripProvider.setDuration(
      _calculateMinutes(travelAnswer.item1, travelAnswer.item2),
    );
  }

  /// Converts distance (meters or kms) into estimated minutes.
  int _calculateMinutes(double distance, bool isMeters) =>
      (isMeters ? (distance / 1000) * 3.5 : distance * 3.5).round();
}
