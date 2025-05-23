import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/address_strings.dart';
import 'package:spl_front/utils/strings/map_strings.dart';

import '../../../bloc/location_management_bloc/gps_bloc/gps_bloc.dart';
import '../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import '../../../widgets/logic_widgets/order_widgets/map/helpers/dialogs/map_location_dialogs.dart';
import '../../../widgets/logic_widgets/user_widgets/addresses/places_search_bar.dart';
import '../../../widgets/logic_widgets/user_widgets/addresses/places_search_result.dart';

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
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AddressStrings.addNewAddress,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 17),

                PlacesSearchBar(
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
                  title: Text(MapStrings.selectOnMap),
                  onTap: () {
                    handleWaitGpsStatus(context, () {
                      if (handleGpsAnswer(context, gpsBloc)) {
                        Navigator.popAndPushNamed(context, 'map_address');
                      }
                    });
                  },
                ),

                Divider(height: 5),

                const SizedBox(height: 10),

                // Search Results
                PlacesSearchResults(isSearching: isSearching),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> handleWaitGpsStatus(
    BuildContext context, VoidCallback gpsAction) async {
  final gpsBloc = BlocProvider.of<GpsBloc>(context);

  if (gpsBloc.state.isLoading) {
    await Future.delayed(Duration(milliseconds: 500));
  }
  gpsAction.call();
}

bool handleGpsAnswer(BuildContext context, GpsBloc gpsBloc) {
  if (!gpsBloc.state.isGpsEnabled) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor activa la ubicación en tu navegador')),
      );
    } else {
      showGpsLocationDialog(context);
    }
    return false;
  }

  if (!gpsBloc.state.isGpsPermissionGranted) {
    if (kIsWeb) {
      gpsBloc.askGpsAccess();
    } else {
      showLocationPermissionDialog(context, gpsBloc);
    }
    return false;
  }

  return true;
}
