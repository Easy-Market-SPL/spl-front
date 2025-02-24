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
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchPlacesBloc = BlocProvider.of<SearchPlacesBloc>(context);
    searchPlacesBloc.emptyGooglePlaces();
    searchPlacesBloc.clearSelectedPlace();
  }

  @override
  Widget build(BuildContext context) {
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agrega una Nueva Dirección',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 17),
                // Barra de búsqueda
                _SearchBar(
                  onSearch: (query) {
                    setState(() {
                      isSearching = query.isNotEmpty;
                    });
                    if (query.isNotEmpty) {
                      searchPlacesBloc.getPlacesByGoogleQuery(query);
                    }
                  },
                ),
                const SizedBox(height: 17),
                Divider(height: 5),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: Colors.blue),
                  title: Text('Seleccionar en el Mapa'),
                  onTap: () {
                    _handleAddManualMarker(context, () {
                      _handleGpsAnswer(context, gpsBloc);
                    });
                  },
                ),
                Divider(height: 5),
                const SizedBox(height: 10),
                // Resultados de la búsqueda
                _SearchResults(isSearching: isSearching),
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

    if (gpsBloc.state.isLoading) {
      await Future.delayed(Duration(milliseconds: 100));
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
  final _debounce = Debouncer(duration: Duration(seconds: 2));
  final Function(String) onSearch;

  _SearchBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Busca tu dirección',
        prefixIcon: Icon(
          Icons.search,
          color: Colors.blue,
        ),
        filled: true,
        fillColor: Colors.grey.shade200, // Color de fondo gris
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          // Color de borde cuando se enfoca
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (query) {
        _debounce.run(() {
          onSearch(query);
        });
      },
    );
  }
}

// Resultados de búsqueda
class _SearchResults extends StatelessWidget {
  final bool isSearching;

  const _SearchResults({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        // Mostrar el CircularProgressIndicator solo cuando estamos buscando y no hay resultados
        if (isSearching && state.googlePlaces.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (state.googlePlaces.isEmpty && !isSearching) {
            return SizedBox(); // No mostrar nada si no se está buscando
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.googlePlaces.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Resultados de la Búsqueda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.googlePlaces.length,
                  itemBuilder: (context, index) {
                    final place = state.googlePlaces[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text(
                          place.formattedAddress
                              .split(',')
                              .sublist(0)
                              .join(','),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          place.formattedAddress
                              .split(',')
                              .sublist(1)
                              .join(','),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        onTap: () {
                          _selectPlace(context, place);
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          }
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

// Manage debounce request
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
