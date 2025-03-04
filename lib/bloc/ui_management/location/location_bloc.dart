import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? positionStream;

  LocationBloc() : super(LocationState()) {
    on<OnStartFollowingUser>((event, emit) {
      emit(state.copyWith(followingUser: true));
    });

    on<OnStopFollowingUser>((event, emit) {
      emit(state.copyWith(followingUser: false));
    });

    on<OnNewUserLocationEvent>((event, emit) {
      emit(state.copyWith(
        lastKnowLocation: event.newLocation,
      ));
    });
  }

  Future<void> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    // TODO return a LatLng object
    add(OnNewUserLocationEvent(LatLng(position.latitude, position.longitude)));
  }

  void startFollowingUser() {
    add(OnStartFollowingUser());
    positionStream = Geolocator.getPositionStream().listen((position) {
      // print('📍 New position: ${position.latitude}, ${position.longitude}');
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
    });
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    add(OnStopFollowingUser());
  }
}
