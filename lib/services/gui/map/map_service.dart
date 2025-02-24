import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/models/ui/google/places_google_response.dart';
import 'package:spl_front/models/ui/map_box/places_map_box_response.dart';
import 'package:spl_front/models/ui/map_box/traffic_map_box_response.dart';
import 'package:spl_front/services/gui/map/interceptors/google_places_interceptor.dart';
import 'package:spl_front/services/gui/map/interceptors/map_box_places_interceptor.dart';
import 'package:spl_front/services/gui/map/interceptors/map_box_traffic_interceptor.dart';

class MapService {
  final Dio _dioMapBoxTraffic;
  final Dio _dioMapBoxPlaces;
  final Dio _dioReverseMapBoxPlaces;
  final Dio _dioGoogle;

  // Load the environment variables from the .env FILE
  final String _baseTrafficUrl = dotenv.env['BASE_TRAFFIC_URL']!;
  final String _basePlacesUrl = dotenv.env['BASE_PLACES_URL']!;
  final String _baseReversePlacesUrl = dotenv.env['BASE_PLACES_REVERSE_URL']!;
  final String _baseGoogleUrl = dotenv.env['BASE_GOOGLE_PLACES_URL']!;

  // Build the Map Service
  MapService()
      : _dioMapBoxTraffic = Dio()..interceptors.add(MapBoxTrafficInterceptor()),
        _dioMapBoxPlaces = Dio()..interceptors.add(MapBoxPlacesInterceptor()),
        _dioReverseMapBoxPlaces = Dio()
          ..interceptors.add(MapBoxPlacesInterceptor()),
        _dioGoogle = Dio()..interceptors.add(GooglePlacesInterceptor());

  // Get the Traffic Response from the Map Box API of a route between two points
  Future<TrafficResponse> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final coorsString =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

    // Specify the method of the request (driving, walking, cycling)
    final url = '$_baseTrafficUrl/driving/$coorsString';

    final resp = await _dioMapBoxTraffic.get(url);
    return TrafficResponse.fromJson(resp.data);
  }

  // Get the places according to the query
  // MapBox:
  Future<List<Feature>> getResultsByMapBoxQuery(
      LatLng proximity, String query) async {
    if (query.isEmpty) return [];

    final resp = await _dioMapBoxPlaces.get(_basePlacesUrl, queryParameters: {
      'q': query,
      'proximity': '${proximity.longitude},${proximity.latitude}',
      'limit': 7,
    });

    final placesResponse = PlacesResponse.fromJson(resp.data);
    return placesResponse.features;
  }

  // Google:
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

  // REVERSE GEOCODING
  // MapBox
  Future<Feature> getInformationByCoors(LatLng coors) async {
    final resp = await _dioReverseMapBoxPlaces
        .get(_baseReversePlacesUrl, queryParameters: {
      'longitude': coors.longitude,
      'latitude': coors.latitude,
      'limit': 1,
    });

    // print('✅ Answer API: ${resp.data}'); // 🔹 Debugging
    final placesResponse = PlacesResponse.fromJson(resp.data);
    return placesResponse.features[0];
  }

  // Google
  Future<List<Result>> getInformationByCoorsGoogle(LatLng coors) async {
    final resp = await _dioGoogle.get(_baseGoogleUrl, queryParameters: {
      'latlng': '${coors.latitude},${coors.longitude}',
      'results': 3,
    });
    final placesResponse = PlacesGoogleResponse.fromJson(resp.data);
    // print('Answer Length ${placesResponse.results.length}');
    return placesResponse.results;
  }
}
