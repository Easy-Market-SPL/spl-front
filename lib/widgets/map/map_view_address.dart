import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/map/map_bloc.dart';

import '../../utils/map_themes/retro_map_style.dart';

class MapViewAddress extends StatelessWidget {
  final LatLng initialLocation;
  final Set<Polyline> polyLines;
  final Set<Marker> markers;

  const MapViewAddress(
      {super.key,
      required this.initialLocation,
      required this.polyLines,
      required this.markers});

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    final CameraPosition initialCameraPosition = CameraPosition(
      bearing: 192.8334901395799,
      target: initialLocation,
      zoom: 15,
    );

    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Listener(
        onPointerMove: (event) {
          mapBloc.add(OnStopFollowingUser());
        },
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          compassEnabled: true,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: false,
          style: jsonEncode(retroMapStyle),
          polylines: polyLines,
          markers: markers,
          onMapCreated: (controller) {
            mapBloc.add(OnMapInitializedEvent(controller));
          },
          onCameraMove: (position) {
            mapBloc.mapCenter = position.target;
          },
        ),
      ),
    );
  }
}
