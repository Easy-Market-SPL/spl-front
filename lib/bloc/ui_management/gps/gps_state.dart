part of 'gps_bloc.dart';

class GpsState extends Equatable {
  final bool isGpsEnabled;
  final bool isGpsPermissionGranted;
  final bool isLoading;

  const GpsState(
      {required this.isGpsEnabled,
      required this.isGpsPermissionGranted,
      this.isLoading = false});

  GpsState copyWith({
    bool? isGpsEnabled,
    bool? isGpsPermissionGranted,
    bool? isLoading,
  }) {
    return GpsState(
      isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
      isGpsPermissionGranted:
          isGpsPermissionGranted ?? this.isGpsPermissionGranted,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [isGpsEnabled, isGpsPermissionGranted, isLoading];
}
