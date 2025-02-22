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

    _init();
  }

  Future<void> _init() async {
    final gpsInitialStatus =
        await Future.wait([_checkGpsStatus(), _isPermissionGranted()]);

    add(GpsAndPermissionEvent(
        isGpsEnabled: gpsInitialStatus[0],
        isGpsPermissionGranted: gpsInitialStatus[1]));
  }

  Future<bool> _checkGpsStatus() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      final isEnabled = (event.index == 1) ? true : false;
      add(GpsAndPermissionEvent(
          isGpsEnabled: isEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted));
    });

    return isEnabled;
  }

  Future<bool> _isPermissionGranted() async {
    return await Permission.location.isGranted;
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
  Future<void> close() {
    gpsServiceSubscription?.cancel();
    return super.close();
  }
}
