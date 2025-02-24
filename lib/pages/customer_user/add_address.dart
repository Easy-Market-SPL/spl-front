import 'dart:async'; // Para el debounce

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/gps/gps_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/models/ui/google/places_google_response.dart';

import '../../widgets/addresses/helpers/address_dialogs.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  late SearchPlacesBloc searchPlacesBloc;

  @override
  void initState() {
    super.initState();
    searchPlacesBloc = BlocProvider.of<SearchPlacesBloc>(context);
    searchPlacesBloc.emptyGooglePlaces();
    searchPlacesBloc.clearSelectedPlace();
    // print('Is Empty: ${searchPlacesBloc.state.googlePlaces.isEmpty}');
  }

  @override
  Widget build(BuildContext context) {
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Agregar una nueva dirección'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'customer_profile');
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barra de búsqueda
                _SearchBar(),
                // Resultados de búsqueda
                const SizedBox(height: 10),
                Divider(height: 5),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: Colors.black),
                  title: Text('Seleccionar en el Mapa'),
                  onTap: () {
                    _handleAddManualMarker(context, () {
                      _handleGpsAnswer(context, gpsBloc);
                    });
                  },
                ),
                Divider(height: 5),
                const SizedBox(height: 10),
                Expanded(child: _SearchResults()),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAddManualMarker(
      BuildContext context, VoidCallback gpsAction) async {
    final gpsBloc = BlocProvider.of<GpsBloc>(context);
    // print('GPS Enabled: ${gpsBloc.state.isGpsEnabled}');
    // print('GPS Permission Granted: ${gpsBloc.state.isGpsPermissionGranted}');

    if (gpsBloc.state.isLoading) {
      // Esperar a que el GPS se inicialice
      await Future.delayed(Duration(milliseconds: 300));
    }
    gpsAction.call();
  }

  void _handleGpsAnswer(BuildContext context, GpsBloc gpsBloc) {
    if (!gpsBloc.state.isGpsEnabled) {
      showGpsLocationDialog(context);
      return;
    }

    if (!gpsBloc.state.isGpsPermissionGranted) {
      showLocationPermissionDialog(context, gpsBloc);
      return;
    }

    Navigator.popAndPushNamed(context, 'map_address');
  }
}

// Barra de búsqueda con debounce
class _SearchBar extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final _debounce = Debouncer(duration: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Busca tu dirección',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (query) {
        _debounce.run(() {
          if (query.isNotEmpty) {
            searchBloc.getPlacesByGoogleQuery(query);
          }
        });
      },
    );
  }
}

// Resultados de búsqueda
class _SearchResults extends StatefulWidget {
  const _SearchResults();

  @override
  State<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<_SearchResults> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        if (state.googlePlaces.isEmpty) {
          return Center(child: Text('No se encontraron resultados.'));
        } else {
          return ListView.builder(
            itemCount: state.googlePlaces.length,
            itemBuilder: (context, index) {
              final place = state.googlePlaces[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(place.formattedAddress),
                  subtitle: Text(place.formattedAddress),
                  onTap: () {
                    _selectPlace(context, place);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  void _selectPlace(BuildContext context, Result place) {
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);
    searchBloc.getSelectedPlace(place);
    Navigator.popAndPushNamed(context, 'confirm_address');
  }
}

// Clase para manejar el debounce
class Debouncer {
  final Duration duration;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.duration});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(duration, action);
  }
}
