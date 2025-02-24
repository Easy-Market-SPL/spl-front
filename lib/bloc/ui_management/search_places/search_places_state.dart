part of 'search_places_bloc.dart';

class SearchPlacesState extends Equatable {
  final bool displayManualMarker;
  final List<Feature> mapBoxPlaces;
  final List<Result> googlePlaces;
  final Result? selectedPlace;

  const SearchPlacesState({
    this.displayManualMarker = false,
    this.mapBoxPlaces = const [],
    this.googlePlaces = const [],
    this.selectedPlace,
  });

  SearchPlacesState copyWith({
    bool? displayManualMarker,
    List<Feature>? mapBoxPlaces,
    List<Result>? googlePlaces,
    Result? selectedPlace,
  }) {
    return SearchPlacesState(
      displayManualMarker: displayManualMarker ?? this.displayManualMarker,
      mapBoxPlaces: mapBoxPlaces ?? this.mapBoxPlaces,
      googlePlaces: googlePlaces ?? this.googlePlaces,
      selectedPlace: selectedPlace ?? this.selectedPlace,
    );
  }

  @override
  List<Object?> get props =>
      [displayManualMarker, mapBoxPlaces, googlePlaces, selectedPlace];
}
