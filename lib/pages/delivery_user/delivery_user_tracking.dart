import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    isDelivery = widget.isTriggerDelivery ?? false;
    _userFuture = UserService.getUser(widget.order!.idUser!);

    // Si no está cargado, pedimos el pedido completo
    final ordersBloc = context.read<OrdersBloc>();
    if (ordersBloc.state is! OrdersLoaded) {
      ordersBloc.add(LoadSingleOrderEvent(widget.order!.id!));
    }

    // Arranca GPS y Google Places
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
        // Cada vez que cambia la ubicación:
        BlocListener<LocationBloc, LocationState>(
          listener: (context, locState) {
            final loc = locState.lastKnowLocation;
            if (loc == null) return;

            // 2️⃣ Dibuja ruta de nuevo (destino ya cargado por SearchPlaces)
            final places = context.read<SearchPlacesBloc>().state.googlePlaces;
            if (places != null && places.isNotEmpty) {
              _drawDestinationRoute(
                loc,
                places.first,
                mapBloc,
                infoTrip,
              );
            }

            // 3️⃣ Dispara OnTheWay Domiciliary solo la primera vez
            if (isDelivery && !_didSendOnTheWay) {
              _didSendOnTheWay = true;
              final userId = context.read<UsersBloc>().state.sessionUser!.id;
              context.read<OrdersBloc>().add(OnTheWayDomiciliaryOrderEvent(
                    orderId: widget.order!.id!,
                    idDomiciliary: userId,
                    initialLatitude: loc.latitude,
                    initialLongitude: loc.longitude,
                  ));
            }
          },
        ),
        // También esperamos a que carguen los lugares para inicializar la ruta
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
            return const Scaffold(
              body: Center(child: CustomLoading()),
            );
          }

          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) {
              return Scaffold(
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
                    // Mapa con todos los marcadores
                    Positioned.fill(
                      child: MapViewAddress(
                        initialLocation: locationState.lastKnowLocation!,
                        markers: mapState.markers.values.toSet(),
                      ),
                    ),
                    // Botón para centrar en usuario
                    Positioned(
                      bottom: _isExpanded
                          ? MediaQuery.of(context).size.height * 0.30
                          : MediaQuery.of(context).size.height * 0.15,
                      right: 20,
                      child: FloatingActionButton(
                        backgroundColor: Colors.blue,
                        onPressed: () =>
                            mapBloc.moveCamera(locationState.lastKnowLocation!),
                        child: const Icon(Icons.directions_walk,
                            color: Colors.white),
                      ),
                    ),
                    // Expandir/contraer InfoCard
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.05,
                      right: 20,
                      child: FloatingActionButton(
                        backgroundColor: Colors.blue,
                        onPressed: () =>
                            setState(() => _isExpanded = !_isExpanded),
                        child:
                            const Icon(Icons.expand_less, color: Colors.white),
                      ),
                    ),
                    if (_isExpanded) _buildInfoCard(context, infoTrip),
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
      ),
    );
  }

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
                        fontWeight: FontWeight.w600),
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
            ],
          ),
        ),
      );

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
}
