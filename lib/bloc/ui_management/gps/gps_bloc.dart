import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription? gpsServiceSubscription;

  GpsBloc()
      : super(const GpsState(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    on<GpsAndPermissionEvent>((event, emit) {
      // Update the state using the copyWith method
      emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled,
        isGpsPermissionGranted: event.isGpsPermissionGranted,
      ));
    });

    on<InitialLoadEvent>((event, emit) {
      emit(GpsState(
          isGpsEnabled: false, isGpsPermissionGranted: false, isLoading: true));
    });

    _init();
  }

  Future<void> _init() async {
    // Emit a loading state to show while checking GPS and permissions
    add(InitialLoadEvent());

    final gpsInitStatus = await Future.wait([
      _checkGpsStatus(),
      _isPermissionGranted(),
    ]);

    add(GpsAndPermissionEvent(
        isGpsEnabled: gpsInitStatus[0],
        isGpsPermissionGranted: gpsInitStatus[1]));
  }

  Future<bool> _isPermissionGranted() async {
    final isGranted = await Permission.location.isGranted;
    return isGranted;
  }

  Future<bool> _checkGpsStatus() async {
    final isEnable = await Geolocator.isLocationServiceEnabled();
    gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      final isEnabled = (event.index == 1) ? true : false;
      add(GpsAndPermissionEvent(
          isGpsEnabled: isEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted));
    });

    return isEnable;
  }

  Future<void> askGpsAccess() async {
    // This line will display the dialog to ask for the GPS permission
    final status = await Permission.location.request();

    if (status.isGranted) {
      add(GpsAndPermissionEvent(
          isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: true));
    } else {
      add(GpsAndPermissionEvent(
          isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: false));
      openAppSettings();
    }
  }

  @override
  String toString() {
    return 'Bloc of GPS: ${state.isGpsEnabled}, ${state.isGpsPermissionGranted}';
  }

  @override
  Future<void> close() {
    gpsServiceSubscription?.cancel();
    return super.close();
  }
}
