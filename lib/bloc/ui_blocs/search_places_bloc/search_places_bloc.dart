import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/helpers/ui_models/google/places_google_response.dart';
import '../../../services/external_services/google_maps/map_service.dart';

part 'search_places_event.dart';
part 'search_places_state.dart';

class SearchPlacesBloc extends Bloc<SearchPlacesEvent, SearchPlacesState> {
  MapService mapService;
  final String sessionToken = Uuid().v4();

  SearchPlacesBloc({required this.mapService})
      : super(const SearchPlacesState()) {
    on<OnNewGooglePlacesFoundEvent>((event, emit) {
      emit(state.copyWith(googlePlaces: event.places));
    });

    on<OnToggleManualMarkerEvent>((event, emit) {
      emit(state.copyWith(displayManualMarker: !state.displayManualMarker));
    });

    on<OnNewGoogleSelectedPlaceEvent>((event, emit) {
      emit(state.copyWith(selectedPlace: event.place));
    });

    on<OnClearSelectedPlaceEvent>((event, emit) {
      emit(state.copyWith(selectedPlace: null));
    });
  }

  /// Extra methods
  Future getPlacesByGoogleQuery(String query) async {
    final List<Result> newPlaces =
        await mapService.getResultsByGoogleQuery(query, sessionToken);
    add(OnNewGooglePlacesFoundEvent(newPlaces));
  }

  Future getSelectedPlace(Result? place) async {
    add(OnNewGoogleSelectedPlaceEvent(place));
  }

  Future getPlacesByGoogleLatLng(LatLng latLng) async {
    final newPlaces = await mapService.getInformationByCoorsGoogle(
      latLng,
    );
    // print('newPlace : ${newPlaces[0].formattedAddress}');
    add(OnNewGooglePlacesFoundEvent(newPlaces));
    add(OnNewGoogleSelectedPlaceEvent(newPlaces[0]));
  }

  Future emptyGooglePlaces() async {
    add(OnNewGooglePlacesFoundEvent(const []));
  }

  Future clearSelectedPlace() async {
    add(OnClearSelectedPlaceEvent());
  }
}
