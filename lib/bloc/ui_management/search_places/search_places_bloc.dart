import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:spl_front/models/ui/general/route_destination.dart';
import 'package:spl_front/models/ui/google/places_google_response.dart';
import 'package:spl_front/models/ui/map_box/places_map_box_response.dart';
import 'package:spl_front/services/gui/map/map_service.dart';
import 'package:uuid/uuid.dart';

import '../../../models/ui/map_box/traffic_map_box_response.dart';

part 'search_places_event.dart';
part 'search_places_state.dart';

class SearchPlacesBloc extends Bloc<SearchPlacesEvent, SearchPlacesState> {
  MapService mapService;
  // Unique session token to avoid conflicts with other requests and duplicates
  final String sessionToken = Uuid().v4();

  SearchPlacesBloc({required this.mapService})
      : super(const SearchPlacesState()) {
    on<OnNewMapBoxPlacesFoundEvent>((event, emit) {
      emit(state.copyWith(mapBoxPlaces: event.places));
    });

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

  // Extra methods
  Future<RouteDestination> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final TrafficResponse resp =
        await mapService.getCoorsStartToEnd(start, end);

    // Destiny Information
    final endPlace = await mapService.getInformationByCoors(end);
    final startPlace = await mapService.getInformationByCoors(start);

    final geometry = resp.routes[0].geometry;
    final distance = resp.routes[0].distance;
    final duration = resp.routes[0].duration;

    // Decode geometry points
    final points = decodePolyline(geometry, accuracyExponent: 6);
    final latLngList = points
        .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
        .toList();

    return RouteDestination(
      points: latLngList,
      duration: duration,
      distance: distance,
      endPlace: endPlace,
      startPlace: startPlace,
    );
  }

  Future getPlacesByQuery(LatLng proximity, String query) async {
    final List<Feature> newPlaces =
        await mapService.getResultsByMapBoxQuery(proximity, query);
    add(OnNewMapBoxPlacesFoundEvent(newPlaces));
  }

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
    print('newPlace : ${newPlaces[0].formattedAddress}');
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
