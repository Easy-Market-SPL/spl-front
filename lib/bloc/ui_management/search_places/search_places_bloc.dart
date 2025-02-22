import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:spl_front/models/ui/general/route_destination.dart';
import 'package:spl_front/models/ui/google/places_google_response.dart';
import 'package:spl_front/models/ui/map_box/places_map_box_response.dart';
import 'package:spl_front/services/gui/map/map_service.dart';

import '../../../models/ui/map_box/traffic_map_box_response.dart';

part 'search_places_event.dart';
part 'search_places_state.dart';

class SearchPlacesBloc extends Bloc<SearchPlacesEvent, SearchPlacesState> {
  MapService mapService;

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
        await mapService.getResultsByGoogleQuery(query);
    add(OnNewGooglePlacesFoundEvent(newPlaces));
  }
}
