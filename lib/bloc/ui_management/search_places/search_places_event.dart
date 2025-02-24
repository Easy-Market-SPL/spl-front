part of 'search_places_bloc.dart';

abstract class SearchPlacesEvent extends Equatable {
  const SearchPlacesEvent();

  @override
  List<Object> get props => [];
}

class OnToggleManualMarkerEvent extends SearchPlacesEvent {}

class OnNewMapBoxPlacesFoundEvent extends SearchPlacesEvent {
  final List<Feature> places;
  const OnNewMapBoxPlacesFoundEvent(this.places);
}

class OnNewGooglePlacesFoundEvent extends SearchPlacesEvent {
  final List<Result> places;
  const OnNewGooglePlacesFoundEvent(this.places);
}

class OnNewGoogleSelectedPlaceEvent extends SearchPlacesEvent {
  final Result? place;
  const OnNewGoogleSelectedPlaceEvent(this.place);
}

class OnClearSelectedPlaceEvent extends SearchPlacesEvent {}
