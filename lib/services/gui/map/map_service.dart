import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/models/ui/google/places_google_response.dart';
import 'package:spl_front/services/gui/map/interceptors/google_places_interceptor.dart';

class MapService {
  final Dio _dioGoogle;

  // Load the environment variables from the .env FILE
  final String _baseTrafficUrl = dotenv.env['BASE_TRAFFIC_URL']!;
  final String _basePlacesUrl = dotenv.env['BASE_PLACES_URL']!;
  final String _baseReversePlacesUrl = dotenv.env['BASE_PLACES_REVERSE_URL']!;
  final String _baseGoogleUrl = dotenv.env['BASE_GOOGLE_PLACES_URL']!;

  // Build the Map Service
  MapService()
      : _dioGoogle = Dio()..interceptors.add(GooglePlacesInterceptor());

  // Get the Traffic Response from the Map Box API of a route between two points
  /*
  Future<TrafficResponse> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final coorsString =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

    // Specify the method of the request (driving, walking, cycling)
    final url = '$_baseTrafficUrl/driving/$coorsString';

  }

   */

  // Get the places according to the query

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
