import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/utils/strings/map_strings.dart';

import '../../bloc/ui_management/map/map_bloc.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final searchPlacesBloc = BlocProvider.of<SearchPlacesBloc>(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Center Marker Icon (pin) placed on top
          Center(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: BounceInDown(
                from: 100,
                child: Icon(
                  Icons.location_pin,
                  size: 60,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Confirm button at the bottom
          Positioned(
            bottom: 70,
            left: 40,
            child: FadeInUp(
              child: MaterialButton(
                onPressed: () async {
                  _handleSearchPlaces(context, () {
                    _navigateToConfirmAddress(context);
                  }, searchPlacesBloc, mapBloc);
                },
                elevation: 0,
                height: 50,
                shape: const StadiumBorder(),
                minWidth: size.width - 120,
                color: Colors.black,
                child: const Text(
                  MapStrings.destinationConfirm,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _handleSearchPlaces(BuildContext context, VoidCallback navigatorAction,
      SearchPlacesBloc searchBloc, MapBloc mapBloc) async {
    await searchBloc.getPlacesByGoogleLatLng(mapBloc.mapCenter!);
    navigatorAction.call();
  }

  void _navigateToConfirmAddress(BuildContext context) {
    Navigator.pushReplacementNamed(context, 'confirm_address');
  }
}
