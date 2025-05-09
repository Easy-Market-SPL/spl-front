import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/logic_widgets/order_widgets/map/map_view_address.dart';

import '../../../bloc/location_management_bloc/location_bloc/location_bloc.dart';
import '../../../bloc/orders_bloc/order_bloc.dart';
import '../../../bloc/orders_bloc/order_event.dart';
import '../../../bloc/orders_bloc/order_state.dart';
import '../../../bloc/ui_blocs/map_bloc/map_bloc.dart';
import '../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import '../../../bloc/users_blocs/users/users_bloc.dart';
import '../../../models/helpers/intern_logic/user_type.dart';
import '../../../models/order_models/order_model.dart';
import '../../../models/order_models/order_status.dart';
import '../../../models/users_models/user.dart';
import '../../../providers/info_trip_provider.dart';
import '../../../services/api_services/user_service/user_service.dart';
import '../../../services/supabase_services/real-time/real_time_tracking_service.dart';
import '../../../utils/strings/order_strings.dart';
import '../../../utils/ui/format_currency.dart';
import '../../../widgets/style_widgets/navigation_bars/nav_bar.dart';

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
  final _trackingService = DeliveryTrackingService();

  late final bool isDelivery;
  late final Future<UserModel?> _userFuture;
  bool _isExpanded = false;
  bool _didSendOnTheWay = false;
  late final bool _isOrderDelivered;
  LatLng? _endLocation; // decoded destination

  @override
  void initState() {
    super.initState();

    isDelivery = widget.isTriggerDelivery ?? false;
    _userFuture = UserService.getUser(widget.order!.idUser!);
    _isOrderDelivered =
        widget.order!.orderStatuses.last.status.toLowerCase() == 'delivered';

    context.read<MapBloc>().clearMarkers();

    final ordersBloc = context.read<OrdersBloc>();
    if (ordersBloc.state is! OrdersLoaded) {
      ordersBloc.add(LoadSingleOrderEvent(widget.order!.id!));
    }

    context
        .read<SearchPlacesBloc>()
        .getPlacesByGoogleQuery(widget.order!.address!);

    if (!_isOrderDelivered) {
      context.read<LocationBloc>()
        ..getCurrentPosition()
        ..startFollowingUser();
    }
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
            if (loc == null || _isOrderDelivered) return;

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
        BlocListener<SearchPlacesBloc, SearchPlacesState>(
          listener: (context, state) {
            if (state.googlePlaces == null || state.googlePlaces!.isEmpty) {
              return;
            }
            final place = state.googlePlaces!.first;
            _endLocation = LatLng(
              place.geometry.location.lat,
              place.geometry.location.lng,
            );

            mapBloc.drawDestinationMarker(_endLocation!);
            mapBloc.moveCamera(_endLocation!); // initial zoom on destination

            final current = context.read<LocationBloc>().state.lastKnowLocation;
            if (!_isOrderDelivered && current != null) {
              _drawDestinationRoute(current, place, mapBloc, infoTrip);
            }
          },
        ),
      ],
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          final initialPosition =
              _endLocation ?? locationState.lastKnowLocation;

          if (initialPosition == null) {
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
                      fontWeight: FontWeight.w600, fontSize: 20),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: Stack(
                children: [
                  Positioned.fill(
                    child: MapView(
                      initialLocation: initialPosition,
                      markers: mapState.markers.values.toSet(),
                    ),
                  ),
                  if (!_isOrderDelivered)
                    _buildFloatingButtons(context, mapBloc, locationState),
                  if (_isExpanded)
                    _isOrderDelivered
                        ? _buildDeliveredCard(context)
                        : _buildInfoCard(context, infoTrip),
                  if (_isOrderDelivered) _buildDeliveredCard(context)
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
        child: _cardContainer(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(),
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
                  final name = snap.data?.fullname ?? 'Usuario No Disponible';
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
                      onPressed: _handleDeliverPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Entregar Orden',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  );
                } else {
                  final deliveredStatus = widget.order!.orderStatuses
                      .lastWhere((s) => s.status == 'delivered');
                  final dateText = DateFormat('dd/MM/yyyy')
                      .format(deliveredStatus.startDate);
                  return Row(
                    children: [
                      const Text('Orden Entregada:',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(dateText,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16)),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      );

  Widget _buildDeliveredCard(BuildContext context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.05,
        left: 20,
        right: 20,
        child: _cardContainer(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orden Entregada',
                style: TextStyle(
                    fontSize: 18,
                    color: PrimaryColors.darkBlue,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              FutureBuilder<UserModel?>(
                future: _userFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  final name = snap.data?.fullname ?? 'Usuario No Disponible';
                  return Text('A nombre de: $name',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87));
                },
              ),
              const SizedBox(height: 6),
              const Text(
                'Pedido entregado el día:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 6),
              Builder(builder: (_) {
                final deliveredStatus = widget.order!.orderStatuses
                    .lastWhere((s) => s.status == 'delivered');
                final dateText =
                    DateFormat('dd/MM/yyyy').format(deliveredStatus.startDate);
                return Text(dateText,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87));
              }),
            ],
          ),
        ),
      );

  Widget _cardContainer(BuildContext context, {required Widget child}) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
          ],
        ),
        child: child,
      );

  Row _cardHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            OrderStrings.deliverAt,
            style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.expand_more_outlined, color: Colors.blue),
            onPressed: () => setState(() => _isExpanded = false),
          ),
        ],
      );

  Future<void> _drawDestinationRoute(
    LatLng start,
    dynamic destinationPlace,
    MapBloc mapBloc,
    InfoTripProvider infoTripProvider,
  ) async {
    if (_isOrderDelivered) return;

    final end = LatLng(
      destinationPlace.geometry.location.lat,
      destinationPlace.geometry.location.lng,
    );

    final travelAnswer =
        await mapBloc.drawMarkersAndGetDistanceBetweenPoints(start, end);

    infoTripProvider
      ..setDistance(travelAnswer.item1)
      ..setMeters(travelAnswer.item2)
      ..setDuration(_calculateMinutes(travelAnswer.item1, travelAnswer.item2));
  }

  int _calculateMinutes(double distance, bool isMeters) =>
      (isMeters ? (distance / 1000) * 3.5 : distance * 3.5).round();

  void _handleDeliverPressed() {
    final trip = Provider.of<InfoTripProvider>(context, listen: false);
    final meters = trip.metersDistance ? trip.distance : trip.distance * 1000;
    if (meters >= 100) {
      _distanceDeliveryErrorDialog();
      return;
    }
    if (widget.order!.debt != 0) {
      _askPaymentCashDebtDialog();
      return;
    }
    setState(() {
      widget.order!.orderStatuses
          .add(OrderStatus(status: 'delivered', startDate: DateTime.now()));
    });
    context.read<OrdersBloc>().add(DeliveredOrderEvent(widget.order!.id!));
  }

  void _askPaymentCashDebtDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Pago',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(
            '¿Deseas confirmar el pago de la orden en efectivo por parte del cliente con un valor de: ${formatCurrency(widget.order!.debt!)}?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Cancelar', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrdersBloc>().add(UpdateDebtEvent(
                  orderId: widget.order!.id!,
                  paymentAmount: widget.order!.debt!));
              _handleDeliverPressed();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _distanceDeliveryErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Center(
            child: Text('Error',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error, color: Colors.red, size: 50),
            SizedBox(height: 10),
            Text(
              'Debes encontrarte a menos de 100 metros para marcar la orden como entregada.',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child:
                  const Text('Aceptar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
