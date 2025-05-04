import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/address_strings.dart';

import 'helpers/debouncer.dart';

class PlacesSearchBar extends StatelessWidget {
  final _debounce = Debouncer(duration: Duration(seconds: 2));
  final Function(String) onSearch;

  PlacesSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: AddressStrings.searchAddress,
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
