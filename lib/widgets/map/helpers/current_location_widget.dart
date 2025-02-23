import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/ui_management/location/location_bloc.dart';
import '../../../bloc/ui_management/map/map_bloc.dart';

class BtnCurrentLocation extends StatelessWidget {
  const BtnCurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        child: IconButton(
          icon: const Icon(
            Icons.my_location,
            color: Colors.black87,
          ),
          onPressed: () {
            final userLocation = locationBloc.state.lastKnowLocation;

            if (userLocation == null) {
              final snackBar =
                  CustomSnackBar(message: 'No hay ubicación reciente');
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }
            mapBloc.moveCamera(userLocation);
          },
        ),
      ),
    );
  }
}

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String message,
    super.duration = const Duration(seconds: 2),
    String btnLabel = 'OK',
    VoidCallback? onOk,
  }) : super(
          content: Text(message),
          action: SnackBarAction(
              label: btnLabel,
              onPressed: () {
                if (onOk != null) onOk();
              }),
        );
}
