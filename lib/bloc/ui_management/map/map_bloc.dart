import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/location/location_bloc.dart';
import 'package:spl_front/utils/map/helpers/custom_marker_helper.dart';
import 'package:tuple/tuple.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationBloc locationBloc;
  GoogleMapController? _mapController;
  LatLng? mapCenter;

  StreamSubscription<LocationState>? locationStateSubscription;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitializedEvent>(_onInitMap);
    on<OnStartFollowingUser>(_onStartFollowingUser);
    on<OnStopFollowingUser>((event, emit) {
      emit(state.copyWith(isFollowingUser: false));
    });
    on<OnAddMarkerEvent>((event, emit) {
      final currentMarkers = Map<String, Marker>.from(state.markers);
      currentMarkers[event.markerId] = event.marker;
      emit(state.copyWith(markers: currentMarkers));
    });
    on<OnUpdateMarkersEvent>(_onUpdateMarkers);

    // FOLLOWING THE USER LOCATION
    locationStateSubscription = locationBloc.stream.listen((locationState) {
      if (!state.isFollowingUser) return;
      if (locationState.lastKnowLocation == null) return;
      moveCamera(locationState.lastKnowLocation!);
    });

    on<UpdateUserMarkerEvent>((event, emit) {
      final newMarkers = Map<String, Marker>.from(state.markers);
      newMarkers['start'] = Marker(
        markerId: const MarkerId('start'),
        position: event.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      );
      emit(state.copyWith(markers: newMarkers));
    });
  }

  // Other Dispatches:
  // Aux Methods for handle events at BLoC:
  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    emit(state.copyWith(isMapInitialized: true));
  }

  void _onUpdateMarkers(OnUpdateMarkersEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(markers: event.newMarkers));
  }

  void _onStartFollowingUser(
      OnStartFollowingUser event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: true));
    if (locationBloc.state.lastKnowLocation == null) return;
    moveCamera(locationBloc.state.lastKnowLocation!);
  }

  void moveCamera(LatLng newLocation) {
    final cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController?.animateCamera(cameraUpdate);
  }

  Future<Tuple2<double, bool>> drawMarkersAndGetDistanceBetweenPoints(
      LatLng begin, LatLng end) async {
    // Custom Markers
    final startMarkerIcon = await getCustomMarkerIcon('delivery-location.png');
    final endMarkerIcon = await getCustomMarkerIcon('delivery-destination.png');

    // Draw Markers
    final startMarker = Marker(
      icon: startMarkerIcon,
      markerId: const MarkerId('start'),
      position: begin,
    );

    final endMarker = Marker(
      markerId: const MarkerId('end'),
      icon: endMarkerIcon,
      position: end,
    );

    final updatedMarkers = Map<String, Marker>.from(state.markers);
    updatedMarkers['start'] = startMarker;
    updatedMarkers['end'] = endMarker;

    // En vez de emitir aquí, disparamos un evento
    add(OnUpdateMarkersEvent(updatedMarkers));

    await Future.delayed(const Duration(milliseconds: 200));

    final distanceBetweenPoints = calculationByDistance(
      begin.latitude,
      begin.longitude,
      end.latitude,
      end.longitude,
    );

    if (distanceBetweenPoints < 1000) {
      // Return distance in meters
      return Tuple2(distanceBetweenPoints, true);
    }

    // Return distance in kilometers
    return Tuple2(distanceBetweenPoints / 1000, false);
  }

  /// Extra Methods for handle events at BLoC:
  // Calculate distance between two points on Earth
  double calculationByDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int radius = 6371000; // Radio de la Tierra en metros

    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c; // Distancia en metros

    return distance;
  }

  @override
  Future<void> close() {
    locationStateSubscription?.cancel();
    return super.close();
  }
}
