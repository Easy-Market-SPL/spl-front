part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class OnMapInitializedEvent extends MapEvent {
  final GoogleMapController controller;
  const OnMapInitializedEvent(this.controller);
}

class OnStartFollowingUser extends MapEvent {}

class OnStopFollowingUser extends MapEvent {}

class UpdateUserPolylineEvent extends MapEvent {
  final List<LatLng> polylineCoordinates;
  const UpdateUserPolylineEvent(this.polylineCoordinates);
}

class OnToggleUserRouteEvent extends MapEvent {}

class OnAddMarkerEvent extends MapEvent {
  final Marker marker;
  final String markerId;
  const OnAddMarkerEvent(this.marker, this.markerId);
}

class DisplayPolylinesEvent extends MapEvent {
  final Map<String, Polyline> polylines;
  final Map<String, Marker> markers;
  const DisplayPolylinesEvent(this.polylines, this.markers);
}
