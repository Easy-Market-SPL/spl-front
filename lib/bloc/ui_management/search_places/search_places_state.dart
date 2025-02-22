part of 'search_places_bloc.dart';

class SearchPlacesState extends Equatable {
  final bool displayManualMarker;
  final List<Feature> mapBoxPlaces;
  final List<Result> googlePlaces;

  const SearchPlacesState({
    this.displayManualMarker = false,
    this.mapBoxPlaces = const [],
    this.googlePlaces = const [],
  });

  SearchPlacesState copyWith({
    bool? displayManualMarker,
    List<Feature>? mapBoxPlaces,
    List<Result>? googlePlaces,
  }) {
    return SearchPlacesState(
      displayManualMarker: displayManualMarker ?? this.displayManualMarker,
      mapBoxPlaces: mapBoxPlaces ?? this.mapBoxPlaces,
      googlePlaces: googlePlaces ?? this.googlePlaces,
    );
  }

  @override
  List<Object> get props => [displayManualMarker, mapBoxPlaces, googlePlaces];
}
