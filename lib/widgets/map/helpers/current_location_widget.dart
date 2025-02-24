import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';

class BtnCurrentLocationWithResult extends StatelessWidget {
  const BtnCurrentLocationWithResult({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        // Mostrar SnackBar si hay un mensaje
        if (state.snackBarMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.snackBarMessage)),
          );
        }

        // Si no hay resultados, puedes hacer alguna acción o devolver un widget vacío
        if (state.googlePlaces.isEmpty) {
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
                onPressed: () {},
              ),
            ),
          ); // Aquí puedes poner un widget de carga o de error si lo prefieres.
        }

        // Si hay resultados, mostramos la dirección encontrada
        final place = state.googlePlaces.first;

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
                // Muestra el diálogo con la ubicación obtenida
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Ubicación actual'),
                      content: Text(place.formattedAddress),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
