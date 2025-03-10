import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/utils/strings/address_strings.dart';
import 'package:spl_front/widgets/addresses/helpers/address_dialogs.dart';

import '../../../bloc/ui_management/address/address_bloc.dart';
import '../../../bloc/ui_management/gps/gps_bloc.dart';
import 'add_address.dart';

class ConfirmAddressPage extends StatefulWidget {
  const ConfirmAddressPage({super.key});

  @override
  State<ConfirmAddressPage> createState() => _ConfirmAddressPageState();
}

class _ConfirmAddressPageState extends State<ConfirmAddressPage> {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['MAPS_API_KEY'];
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AddressStrings.addressDetails,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () =>
                  Navigator.popAndPushNamed(context, 'add_address'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AddressStrings.address,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  state.selectedPlace!.formattedAddress,
                  style: TextStyle(color: Colors.black38, fontSize: 16),
                ),
                SizedBox(height: 15),

                // Static Map with the selected location
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/staticmap?center=${state.selectedPlace!.geometry.location.lat},${state.selectedPlace!.geometry.location.lng}&zoom=16&size=600x400&markers=color:red%7C${state.selectedPlace!.geometry.location.lat},${state.selectedPlace!.geometry.location.lng}&key=$apiKey',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 100,
                        right: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            handleWaitGpsStatus(context, () {
                              if (handleGpsAnswer(context, gpsBloc)) {
                                Navigator.pushReplacementNamed(
                                    context, 'map_address');
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AddressStrings.adjustLocation,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Editable label
                SizedBox(height: 25),
                Text(
                  AddressStrings.labelAddressInstruction,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: AddressStrings.labelAddress,
                    hintText: AddressStrings.hintAddress,
                    labelStyle: TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Detalles de la dirección
                SizedBox(height: 20),
                Text(
                  AddressStrings.detailsAddressInstruction,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    labelText: AddressStrings.labelDetails,
                    labelStyle: TextStyle(color: Colors.black38),
                    hintText: AddressStrings.hintDetails,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (labelController.text.isEmpty ||
                          detailsController.text.isEmpty) {
                        // Show a dialog if any of the fields is empty
                        showErrorDialog(context);
                      } else {
                        final addressBloc =
                            BlocProvider.of<AddressBloc>(context);
                        final searchBloc =
                            BlocProvider.of<SearchPlacesBloc>(context);
                        addressBloc.add(
                          AddAddress(
                            name: labelController.text,
                            address: state.selectedPlace!.formattedAddress,
                            details: detailsController.text,
                            location: LatLng(
                              state.selectedPlace!.geometry.location.lat,
                              state.selectedPlace!.geometry.location.lng,
                            ),
                          ),
                        );

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Center(
                                child: Text(
                                  AddressStrings.addressCreated,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.blue, size: 50),
                                  SizedBox(height: 10),
                                  Text(
                                    AddressStrings.successAddressCreation,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        await Future.delayed(
                            const Duration(seconds: 1, milliseconds: 500));
                        searchBloc.add(OnClearSelectedPlaceEvent());
                        Navigator.of(context).pop(); // Close the dialog

                        Navigator.of(context).pop(); // Close the page
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 50), // Button width reduced
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(AddressStrings.saveAddress,
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
