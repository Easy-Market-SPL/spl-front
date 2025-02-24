import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/location/location_bloc.dart';
import 'package:spl_front/bloc/ui_management/map/map_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/widgets/map/helpers/buttons/back_widget.dart';
import 'package:spl_front/widgets/map/helpers/buttons/follow_user_widget.dart';
import 'package:spl_front/widgets/map/manual_marker.dart';
import 'package:spl_front/widgets/map/map_view_address.dart';

class MapAddressPage extends StatefulWidget {
  const MapAddressPage({super.key});

  @override
  State<MapAddressPage> createState() => _MapAddressPageState();
}

class _MapAddressPageState extends State<MapAddressPage> {
  late LocationBloc locationBloc;

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          if (locationState.lastKnowLocation == null) {
            return Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) {
              Map<String, Polyline> polylines = mapState.polyLines;
              Map<String, Marker> markers = mapState.markers;

              if (!mapState.showMyRoute) {
                polylines.removeWhere((key, value) => key == 'my_route');
              }

              return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
                builder: (context, searchPlacesState) {
                  return SingleChildScrollView(
                    child: Stack(
                      children: [
                        // Google Map View
                        MapViewAddress(
                          initialLocation: locationState.lastKnowLocation!,
                          polyLines: polylines.values.toSet(),
                          markers: markers.values.toSet(),
                        ),
                        // Marker to indicate the selected location
                        ManualMarker(),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BtnFollowUser(),
          BtnBackLocation(),
        ],
      ),
    );
  }
}
