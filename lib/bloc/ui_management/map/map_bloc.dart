import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/location/location_bloc.dart';
import 'package:spl_front/utils/map/helpers/custom_marker_helper.dart';
import 'package:tuple/tuple.dart';

import '../../../models/ui/general/route_destination.dart';

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
    on<UpdateUserPolyLineEvent>(_onPolyLineNewPoint);
    on<OnAddMarkerEvent>((event, emit) {
      final currentMarkers = Map<String, Marker>.from(state.markers);
      currentMarkers[event.markerId] = event.marker;
      emit(state.copyWith(markers: currentMarkers));
    });
    on<DisplayPolylinesEvent>((event, emit) {
      emit(state.copyWith(polyLines: event.polylines, markers: event.markers));
    });

    // FOLLOWING THE USER LOCATION
    locationStateSubscription = locationBloc.stream.listen((locationState) {
      if (!state.isFollowingUser) return;
      if (locationState.lastKnowLocation == null) return;
      moveCamera(locationState.lastKnowLocation!);
    });
  }

  // Other Dispatches:
  // Aux Methods for handle events at BLoC:
  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    emit(state.copyWith(isMapInitialized: true));
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

  // Methods for routes:
  void _onPolyLineNewPoint(
      UpdateUserPolyLineEvent event, Emitter<MapState> emit) {
    final myRoute = Polyline(
      polylineId: const PolylineId('my_route'),
      color: Colors.black,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      points: event.userLocationHistory,
    );

    final currentPolylines = Map<String, Polyline>.from(state.polyLines);
    currentPolylines['delivery_route'] = myRoute;

    emit(state.copyWith(polyLines: currentPolylines));
  }

  Future<Tuple2<double, double>> drawMyRoutePolyLine(
      RouteDestination destination) async {
    final myRoute = Polyline(
      polylineId: const PolylineId('delivery_route'),
      color: Color(0xff111b75),
      points: destination.points,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    double kilometers = (destination.distance / 1000);
    kilometers = (kilometers * 100).floorToDouble();
    kilometers = kilometers / 100;

    double tripDuration = (destination.duration / 60).floorToDouble();

    // Custom Markers
    final startMarkerIcon = await getCustomMarkerIcon('delivery-location.png');
    final endMarkerIcon = await getCustomMarkerIcon('delivery-destination.png');

    // Draw Markers
    final startMarker = Marker(
      icon: startMarkerIcon,
      markerId: MarkerId('start'),
      position: destination.points.first,
    );

    final endMarker = Marker(
      markerId: MarkerId('end'),
      icon: endMarkerIcon,
      position: destination.points.last,
    );

    final currentPolylines = Map<String, Polyline>.from(state.polyLines);
    currentPolylines['delivery_route'] = myRoute;

    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentMarkers['start'] = startMarker;
    currentMarkers['end'] = endMarker;

    add(DisplayPolylinesEvent(currentPolylines, currentMarkers));

    await Future.delayed(const Duration(milliseconds: 200));

    return Tuple2(kilometers, tripDuration);
  }

  @override
  Future<void> close() {
    locationStateSubscription?.cancel();
    return super.close();
  }
}
