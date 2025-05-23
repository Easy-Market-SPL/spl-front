import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/widgets/logic_widgets/order_widgets/map/manual_marker.dart';
import 'package:spl_front/widgets/logic_widgets/order_widgets/map/map_view_address.dart';

import '../../../bloc/location_management_bloc/location_bloc/location_bloc.dart';
import '../../../bloc/ui_blocs/map_bloc/map_bloc.dart';
import '../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import '../../../widgets/style_widgets/buttons/back_widget.dart';
import '../../../widgets/style_widgets/buttons/follow_user_widget.dart';

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
              Map<String, Marker> markers = mapState.markers;

              return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
                builder: (context, searchPlacesState) {
                  return SingleChildScrollView(
                    child: Stack(
                      children: [
                        // Google Map View
                        MapView(
                          initialLocation: locationState.lastKnowLocation!,
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
