import 'dart:async'; // Para el debounce

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/models/ui/google/places_google_response.dart';

class AddAddressPage extends StatelessWidget {
  const AddAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 20),
            Expanded(child: _SearchResults()),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final _debounce = Debouncer(
      duration: Duration(milliseconds: 500)); // Implementación del debounce

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
            // Only trigger the search event when the user stops typing for a while
            searchBloc.getPlacesByGoogleQuery(query);
          }
        });
      },
    );
  }
}

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
