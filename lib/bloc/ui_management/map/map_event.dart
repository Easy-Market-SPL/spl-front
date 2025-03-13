part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class OnMapInitializedEvent extends MapEvent {
  final GoogleMapController controller;

  const OnMapInitializedEvent(this.controller);

  @override
  List<Object> get props => [controller];
}

class OnStartFollowingUser extends MapEvent {}

class OnStopFollowingUser extends MapEvent {}

class OnAddMarkerEvent extends MapEvent {
  final String markerId;
  final Marker marker;

  const OnAddMarkerEvent(this.markerId, this.marker);

  @override
  List<Object> get props => [markerId, marker];
}

// Nuevo evento para actualizar los marcadores
class OnUpdateMarkersEvent extends MapEvent {
  final Map<String, Marker> newMarkers;

  const OnUpdateMarkersEvent(this.newMarkers);

  @override
  List<Object> get props => [newMarkers];
}
