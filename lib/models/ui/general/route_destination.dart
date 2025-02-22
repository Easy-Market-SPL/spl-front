import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/models/ui/map_box/places_map_box_response.dart';

class RouteDestination {
  final List<LatLng> points;
  final double duration;
  final double distance;
  final Feature endPlace;
  final Feature startPlace;

  RouteDestination({
    required this.points,
    required this.duration,
    required this.distance,
    required this.endPlace,
    required this.startPlace,
  });
}
