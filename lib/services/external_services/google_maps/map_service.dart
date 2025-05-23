import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../models/helpers/ui_models/google/places_google_response.dart';
import 'interceptors/google_places_interceptor.dart';

class MapService {
  final Dio _dioGoogle;

  // Load the environment variables from the .env FILE
  final String _baseGoogleUrl = dotenv.env['BASE_GOOGLE_PLACES_URL']!;

  // Build the Map Service
  MapService()
      : _dioGoogle = Dio()..interceptors.add(GooglePlacesInterceptor());

  /// GET THE PLACES ACCORDING TO THE QUERY
  Future<List<Result>> getResultsByGoogleQuery(
      String query, String sessionToken) async {
    if (query.isEmpty) return [];

    final resp = await _dioGoogle.get(_baseGoogleUrl, queryParameters: {
      'address': query,
      'sessiontoken': sessionToken,
    });

    final placesResponse = PlacesGoogleResponse.fromJson(resp.data);
    if (placesResponse.status == 'ZERO_RESULTS') return [];
    return placesResponse.results;
  }

  Future<List<Result>> getInformationByCoorsGoogle(LatLng coors) async {
    final resp = await _dioGoogle.get(_baseGoogleUrl, queryParameters: {
      'latlng': '${coors.latitude},${coors.longitude}',
      'results': 3,
    });
    final placesResponse = PlacesGoogleResponse.fromJson(resp.data);
    return placesResponse.results;
  }
}
