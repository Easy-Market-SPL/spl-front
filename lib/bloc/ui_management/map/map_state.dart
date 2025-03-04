part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isMapInitialized;
  final bool isFollowingUser;
  final bool showMyRoute;

  // Poly-lines
  final Map<String, Polyline> polyLines;

  // Markers
  final Map<String, Marker> markers;

  /*
   'mi_ruta : {
      id: polylineId Google,
      points : [[lat, lng], [lat, lng], [lat, lng]],
      width : 3,
      color : Colors.black,
    }
   */

  const MapState({
    this.isMapInitialized = false,
    this.isFollowingUser = true,
    this.showMyRoute = true,
    Map<String, Polyline>? polyLines,
    Map<String, Marker>? markers,
  })  : polyLines = polyLines ?? const {},
        markers = markers ?? const {};

  MapState copyWith(
          {bool? isMapInitialized,
          bool? isFollowingUser,
          bool? showMyRoute,
          Map<String, Marker>? markers,
          Map<String, Polyline>? polyLines}) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
        polyLines: polyLines ?? this.polyLines,
        markers: markers ?? this.markers,
        showMyRoute: showMyRoute ?? this.showMyRoute,
      );

  @override
  List<Object> get props =>
      [isMapInitialized, isFollowingUser, polyLines, markers];
}
