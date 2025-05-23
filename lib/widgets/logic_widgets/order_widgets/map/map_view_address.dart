import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../bloc/ui_blocs/map_bloc/map_bloc.dart';
import '../../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';

class MapView extends StatelessWidget {
  final LatLng initialLocation;
  final Set<Marker> markers;

  const MapView(
      {super.key, required this.initialLocation, required this.markers});

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);

    final CameraPosition initialCameraPosition =
        searchBloc.state.selectedPlace == null
            ? CameraPosition(
                bearing: 0,
                target: initialLocation,
                zoom: 15,
              )
            : CameraPosition(
                bearing: 0,
                target: LatLng(
                    searchBloc.state.selectedPlace!.geometry.location.lat,
                    searchBloc.state.selectedPlace!.geometry.location.lng),
                zoom: 15,
              );

    final size = MediaQuery.of(context).size;

    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
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
              // style: jsonEncode(gtaMapStyle),
              // style: jsonEncode(blueStandardMapStyle),
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
      },
    );
  }
}
