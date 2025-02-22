part of 'gps_bloc.dart';

class GpsState extends Equatable {
  final bool isGpsEnabled;
  final bool isGpsPermissionGranted;

  // Create a getter to know if the GPS is enabled and the permission is granted
  bool get isAllGranted => isGpsEnabled && isGpsPermissionGranted;

  const GpsState(
      {this.isGpsEnabled = false, this.isGpsPermissionGranted = false});

  // Create CopyWith Method with the needed properties
  GpsState copyWith({bool? isGpsEnabled, bool? isGpsPermissionGranted}) {
    return GpsState(
        isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
        isGpsPermissionGranted:
            isGpsPermissionGranted ?? this.isGpsPermissionGranted);
  }

  @override
  List<Object> get props => [isGpsEnabled, isGpsPermissionGranted];
}
