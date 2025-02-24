part of 'search_places_bloc.dart';

class SearchPlacesState extends Equatable {
  final bool displayManualMarker;
  final List<Feature> mapBoxPlaces;
  final List<Result> googlePlaces;
  final String snackBarMessage; // Nueva propiedad para mostrar el mensaje

  const SearchPlacesState({
    this.displayManualMarker = false,
    this.mapBoxPlaces = const [],
    this.googlePlaces = const [],
    this.snackBarMessage = '', // Valor inicial vacío
  });

  SearchPlacesState copyWith({
    bool? displayManualMarker,
    List<Feature>? mapBoxPlaces,
    List<Result>? googlePlaces,
    String? snackBarMessage, // Parámetro para modificar el mensaje
  }) {
    return SearchPlacesState(
      displayManualMarker: displayManualMarker ?? this.displayManualMarker,
      mapBoxPlaces: mapBoxPlaces ?? this.mapBoxPlaces,
      googlePlaces: googlePlaces ?? this.googlePlaces,
      snackBarMessage:
          snackBarMessage ?? this.snackBarMessage, // Modificar el mensaje
    );
  }

  @override
  List<Object> get props =>
      [displayManualMarker, mapBoxPlaces, googlePlaces, snackBarMessage];
}
