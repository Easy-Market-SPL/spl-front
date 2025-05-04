part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isMapInitialized;
  final bool isFollowingUser;
  final bool showMyRoute;
  final Map<String, Marker> markers;

  const MapState({
    this.isMapInitialized = false,
    this.isFollowingUser = true,
    this.showMyRoute = true,
    Map<String, Polyline>? polyLines,
    Map<String, Marker>? markers,
  }) : markers = markers ?? const {};

  MapState copyWith({
    bool? isMapInitialized,
    bool? isFollowingUser,
    bool? showMyRoute,
    Map<String, Marker>? markers,
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
        markers: markers ?? this.markers,
        showMyRoute: showMyRoute ?? this.showMyRoute,
      );

  @override
  List<Object> get props => [isMapInitialized, isFollowingUser, markers];
}
