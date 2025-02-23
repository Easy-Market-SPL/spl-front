import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/location/location_bloc.dart';
import 'package:spl_front/bloc/ui_management/map/map_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Center(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: BounceInDown(
                from: 100,
                child: Icon(
                  Icons.directions_run_rounded,
                  size: 60,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Button for confirm
          Positioned(
            bottom: 70,
            left: 40,
            child: FadeInUp(
              child: MaterialButton(
                onPressed: () async {
                  // TODO: OBTAIN THE DESTINATION AND SHOW A DIALOG WITH THE INFORMATION OF THIS POINT

                  Navigator.pop(context);
                },
                elevation: 0,
                height: 50,
                shape: const StadiumBorder(),
                minWidth: size.width - 120,
                color: Colors.black,
                child: const Text(
                  'Confirmar Destino',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
