import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';

import '../../bloc/ui_management/address/address_bloc.dart';

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

    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Detalles de La Dirección',
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
                  'Dirección',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  state.selectedPlace!.formattedAddress,
                  style: TextStyle(color: Colors.black38, fontSize: 16),
                ),
                SizedBox(height: 15),

                // Mapa (Estático con el icono del marcador)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
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
                            Navigator.pushReplacementNamed(
                                context, 'map_address');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Ajustar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Etiqueta editable
                SizedBox(height: 25),
                Text(
                  'Etiqueta tu dirección',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: 'Etiqueta tu dirección',
                    hintText: 'Etiqueta (p.e. Casa, Oficina)',
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
                  'Detalles de tu dirección',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    labelText: 'Detalles de tu dirección',
                    labelStyle: TextStyle(color: Colors.black38),
                    hintText: 'Número de Apartamento u oficina',
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

                // Empty space before button
                SizedBox(height: 40), // Adds space before button

                // Centering the "Guardar Dirección" button at the bottom
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (labelController.text.isEmpty ||
                          detailsController.text.isEmpty) {
                        // Mostrar un dialogo si alguno de los campos está vacío
                        _showErrorDialog(context);
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

                        searchBloc.add(OnClearSelectedPlaceEvent());
                        Navigator.popAndPushNamed(context, 'customer_profile');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 50), // Button width reduced
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Guardar Dirección',
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

  void _showErrorDialog(BuildContext context) {
    double mediaQueryWidth = (MediaQuery.of(context).size.width / 1.5);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Round the corners
          ),
          title: Align(
            alignment: Alignment.centerLeft, // Align title to the left
            child: Text(
              'Campos Obligatorios',
              style: TextStyle(
                color: Colors.black, // Black color for the title
                fontWeight: FontWeight.bold, // Bold font for the title
                fontSize: 20, // Larger font size for the title
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              'El nombre y los detalles de la ubicación son obligatorios.',
              style: TextStyle(
                color:
                    Colors.black87, // Slightly lighter black color for content
                fontSize: 16, // Larger font size for content
                fontWeight: FontWeight.w400, // Regular weight for the content
              ),
              textAlign: TextAlign.left, // Align content to the left
            ),
          ),
          actions: [
            // Button styled similar to the GPS dialog
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size(mediaQueryWidth, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Slightly larger font for the button text
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
