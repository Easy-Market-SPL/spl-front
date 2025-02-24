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
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);
    final apiKey = dotenv.env['MAPS_API_KEY'];

    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalles de la dirección'),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () =>
                  Navigator.popAndPushNamed(context, 'add_address'),
            ),
          ),
          body: SingleChildScrollView(
            // Wrapping the body to avoid overflow
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dirección (Estática)
                Text(
                  state.selectedPlace!.formattedAddress,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

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
                        left: 10,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, 'map_address');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Ajustar'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Etiqueta editable
                SizedBox(height: 20),
                TextFormField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: 'Etiqueta tu dirección',
                    hintText: 'Etiqueta (p.e. Casa, Oficina)',
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
                TextFormField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    labelText: 'Detalles de tu dirección',
                    hintText: 'Número de Apartamento u oficina',
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

                // Botón Guardar (al final para evitar overflow)
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final addressBloc = BlocProvider.of<AddressBloc>(context);
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
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Guardar Dirección'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
