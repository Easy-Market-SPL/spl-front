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
import '../../services/supabase/real-time/real_time_tracking_service.dart';
import '../../utils/strings/order_strings.dart';
import '../../utils/ui/format_currency.dart';
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
  final _trackingService = DeliveryTrackingService(); // instancia única

  late final bool isDelivery;
  late final Future<UserModel?> _userFuture;
  bool _isExpanded = false;
  bool _didSendOnTheWay = false;

  @override
  void initState() {
    super.initState();

    final mapBloc = context.read<MapBloc>();
    mapBloc.clearMarkers();

    isDelivery = widget.isTriggerDelivery ?? false;
    _userFuture = UserService.getUser(widget.order!.idUser!);

    final ordersBloc = context.read<OrdersBloc>();
    if (ordersBloc.state is! OrdersLoaded) {
      ordersBloc.add(LoadSingleOrderEvent(widget.order!.id!));
    }

    final locationBloc = context.read<LocationBloc>();
    final searchBloc = context.read<SearchPlacesBloc>();
    locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();
    searchBloc.getPlacesByGoogleQuery(widget.order!.address!);
  }

  @override
  Widget build(BuildContext context) {
    final mapBloc = context.read<MapBloc>();
    final infoTrip = Provider.of<InfoTripProvider>(context, listen: false);

    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listener: (context, locState) async {
            final loc = locState.lastKnowLocation;
            if (loc == null) return;

            final userId = context.read<UsersBloc>().state.sessionUser!.id;
            await _trackingService.upsertLocation(
              userId: userId,
              latitude: loc.latitude,
              longitude: loc.longitude,
            );

            final places = context.read<SearchPlacesBloc>().state.googlePlaces;
            if (places != null && places.isNotEmpty) {
              _drawDestinationRoute(loc, places.first, mapBloc, infoTrip);
            }

            if (isDelivery && !_didSendOnTheWay) {
              _didSendOnTheWay = true;
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
        /* ─────────────────  LISTENER DECODIFICACIÓN DIRECCIÓN  ────────────── */
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
            return const Scaffold(body: Center(child: CustomLoading()));
          }

          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.popAndPushNamed(
                      context, 'delivery_user_orders'),
                ),
                title: Text(
                  OrderStrings.orderNumberString(widget.order!.id.toString()),
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
                  Positioned.fill(
                    child: MapView(
                      initialLocation: locationState.lastKnowLocation!,
                      markers: mapState.markers.values.toSet(),
                    ),
                  ),
                  // FABs y tarjeta de información
                  _buildFloatingButtons(context, mapBloc, locationState),
                  if (_isExpanded) _buildInfoCard(context, infoTrip),
                ],
              ),
              bottomNavigationBar: CustomBottomNavigationBar(
                userType: UserType.delivery,
                context: context,
              ),
            ),
          );
        },
      ),
    );
  }

  /* ─────────────────────────────  UI helpers  ───────────────────────────── */
  Widget _buildFloatingButtons(
    BuildContext context,
    MapBloc mapBloc,
    LocationState locationState,
  ) =>
      Stack(
        children: [
          Positioned(
            bottom: _isExpanded
                ? MediaQuery.of(context).size.height * 0.35
                : MediaQuery.of(context).size.height * 0.13,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'moveCameraFAB',
              backgroundColor: Colors.blue,
              onPressed: () =>
                  mapBloc.moveCamera(locationState.lastKnowLocation!),
              child: const Icon(Icons.directions_walk, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'toggleExpandFAB',
              backgroundColor: Colors.blue,
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              child: Icon(
                _isExpanded ? Icons.expand_more_outlined : Icons.expand_less,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );

  Widget _buildInfoCard(BuildContext context, InfoTripProvider tripInfo) =>
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
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    icon: const Icon(Icons.expand_more_outlined,
                        color: Colors.blue),
                    onPressed: () => setState(() => _isExpanded = false),
                  ),
                ],
              ),
              Text(
                widget.order?.address ?? OrderStrings.notAvailable,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              FutureBuilder<UserModel?>(
                future: _userFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  final name = snap.data?.fullname ?? '';
                  return Text(
                    name.isNotEmpty ? OrderStrings.nameOrder(name) : 'Cliente:',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.route, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    tripInfo.metersDistance
                        ? OrderStrings.estimatedDistanceMeters(
                            tripInfo.distance)
                        : OrderStrings.estimatedDistanceKms(tripInfo.distance),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    OrderStrings.estimatedDeliveryMinutes(tripInfo.duration),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Builder(builder: (_) {
                final lastStatus = widget.order!.orderStatuses.last.status;
                if (lastStatus != 'delivered') {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        /// Make the distance check
                        final infoTripProvider = Provider.of<InfoTripProvider>(
                            context,
                            listen: false);

                        final metersDistance = !infoTripProvider.metersDistance
                            ? infoTripProvider.distance * 1000
                            : infoTripProvider.distance;

                        if (metersDistance >= 100) {
                          _distanceDeliveryErrorDialog();
                        } else {
                          /// Check if the order has debt that according with the business logic means a payment cash
                          if (widget.order!.debt != 0) {
                            _askPaymentCashDebtDialog();
                          } else {
                            setState(() {
                              widget.order!.orderStatuses.add(
                                OrderStatus(
                                    status: 'delivered',
                                    startDate: DateTime.now()),
                              );
                            });
                            context.read<OrdersBloc>().add(
                                  DeliveredOrderEvent(widget.order!.id!),
                                );
                          }
                        }
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                } else {
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
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      );

  /* - ───────────────────────  LOGIC  ────────────────────────── */
  Future<void> _drawDestinationRoute(
    LatLng start,
    dynamic destinationPlace,
    MapBloc mapBloc,
    InfoTripProvider infoTripProvider,
  ) async {
    final end = LatLng(
      destinationPlace.geometry.location.lat,
      destinationPlace.geometry.location.lng,
    );

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

  void _askPaymentCashDebtDialog() {
    // Show a dialog to confirm the payment with cash
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          content: Text(
              '¿Deseas confirmar el pago de la orden en efectivo por ${formatCurrency(widget.order!.debt!)}?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(120, 45),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(120, 45),
              ),
              onPressed: () {
                /// The delivery is confirmed
                Navigator.pop(dialogContext);
                // Call the function to confirm the payment
                context.read<OrdersBloc>().add(UpdateDebtEvent(
                    orderId: widget.order!.id!,
                    paymentAmount: widget.order!.debt!));
                setState(() {
                  widget.order!.orderStatuses.add(
                    OrderStatus(status: 'delivered', startDate: DateTime.now()),
                  );
                });
                context.read<OrdersBloc>().add(
                      DeliveredOrderEvent(widget.order!.id!),
                    );
              },
              child: const Text('Confirmar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _distanceDeliveryErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                'Debes encontrarte a menos de 100 metros para marcar la orden como entregada.',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
