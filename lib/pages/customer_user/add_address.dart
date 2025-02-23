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
  @override
  Widget build(BuildContext context) {
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar una nueva dirección'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            _SearchBar(),
            // Display the search results in a ListView
            const SizedBox(height: 10),
            Divider(height: 5),
            ListTile(
              leading:
                  const Icon(Icons.location_on_outlined, color: Colors.black),
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
  }

  // Handle adding manual marker on map
  Future<void> _handleAddManualMarker(
      BuildContext context, VoidCallback gpsAction) async {
    final gpsBloc = BlocProvider.of<GpsBloc>(context);
    print('GPS Enabled: ${gpsBloc.state.isGpsEnabled}');
    print('GPS Permission Granted: ${gpsBloc.state.isGpsPermissionGranted}');

    // Ensure GPS status is checked before proceeding
    if (gpsBloc.state.isLoading) {
      // Wait until GPS is initialized
      await Future.delayed(Duration(milliseconds: 300));
    }
    gpsAction.call();
  }

  void _handleGpsAnswer(BuildContext context, GpsBloc gpsBloc) {
    // Step 1: Check if GPS is enabled
    if (!gpsBloc.state.isGpsEnabled) {
      showGpsLocationDialog(context);
      return;
    }

    // Step 2: Check if GPS permission is granted
    if (!gpsBloc.state.isGpsPermissionGranted) {
      showLocationPermissionDialog(context, gpsBloc);
      return;
    }

    // Step 3: Proceed to map screen
    Navigator.pushNamed(context, 'map_address');
  }
}

// The search bar with debounce
class _SearchBar extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final _debounce = Debouncer(
    duration: Duration(milliseconds: 500),
  ); // Debounce to optimize search

  @override
  Widget build(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Busca tu dirección',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (query) {
        _debounce.run(() {
          if (query.isNotEmpty) {
            // Trigger search only after the user stops typing
            searchBloc.getPlacesByGoogleQuery(query);
          }
        });
      },
    );
  }
}

// The list of search results
class _SearchResults extends StatelessWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        if (state.googlePlaces.isEmpty) {
          return Center(child: Text('No results found.'));
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
    // Handle the selection of a place
    print('Selected: ${place.formattedAddress}');
  }
}

// Debouncer class to control the frequency of the requests
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
