part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isMapInitialized;
  final bool isFollowingUser;
  final bool showRoute;
  final Map<String, Polyline> polylines;
  final Map<String, Marker> markers;

  const MapState({
    this.isMapInitialized = false,
    this.isFollowingUser = false,
    this.showRoute = false,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
  })  : polylines = polylines ?? const {},
        markers = markers ?? const {};

  MapState copyWith({
    bool? isMapInitialized,
    bool? showRoute,
    bool? isFollowingUser,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
  }) {
    return MapState(
      isFollowingUser: isFollowingUser ?? this.isFollowingUser,
      isMapInitialized: isMapInitialized ?? this.isMapInitialized,
      showRoute: showRoute ?? this.showRoute,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
    );
  }

  @override
  List<Object> get props => [isMapInitialized, showRoute, polylines, markers];
}
