import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/gps/gps_bloc.dart';

import '../../../bloc/ui_management/address/address_bloc.dart';

void showDeleteConfirmationDialog(
    BuildContext context, AddressBloc addressBloc, int index) {
  double mediaQueryWidth = (MediaQuery.of(context).size.width / 4) + 5.0;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(
          child: Text(
            '¿Estás seguro de Eliminar Esta Dirección?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              'Direccion',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 5),
            Text(
              addressBloc.state.addresses[index].address,
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ],
        ),
        actions: [
          // Cancel Button with blue border
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(mediaQueryWidth, 50),
              side: BorderSide(color: Colors.blue), // Blue border
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // Dispatch Delete Address event
              addressBloc.add(DeleteAddress(index: index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(mediaQueryWidth, 50),
              backgroundColor: Colors.blue,
            ),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

void showEditDialog(BuildContext context, Address address, int index) {
  final nameController = TextEditingController(text: address.name);
  final detailsController = TextEditingController(text: address.details);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Editar Dirección',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              Text(
                'Dirección: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                address.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(
                  labelText: 'Detalles',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button with blue border
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              side: BorderSide(color: Colors.blue), // Blue border
            ),
            child: Text('Cancelar', style: TextStyle(color: Colors.blue)),
          ),

          ElevatedButton(
            onPressed: () {
              final name = nameController.text; // Fetch name from input
              final details =
                  detailsController.text; // Fetch details from input

              BlocProvider.of<AddressBloc>(context).add(EditAddress(
                index: index,
                name: name,
                details: details,
              ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(
              'Guardar cambios',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

void showGpsLocationDialog(BuildContext context) {
  double mediaQueryWidth = (MediaQuery.of(context).size.width / 1.5);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(
          child: Text(
            'Activar GPS',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por favor, active el GPS para seleccionar la dirección en el mapa.',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          // Cancel Button with blue border
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(mediaQueryWidth, 50),
              backgroundColor: Colors.blue,
              side: BorderSide(color: Colors.grey), // Blue border
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showLocationPermissionDialog(BuildContext context, GpsBloc gpsBloc) {
  double mediaQueryWidth = (MediaQuery.of(context).size.width / 4);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(
          child: Text(
            'Permisos de Ubicación',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por favor, otorgue los permisos para acceder a la funcionalidad del Mapa.',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          // Cancel Button with blue border
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(mediaQueryWidth, 50),
              side: BorderSide(color: Colors.blue), // Blue border
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // Dispatch Delete Address event
              gpsBloc.askGpsAccess();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(mediaQueryWidth, 50),
              backgroundColor: Colors.blue,
            ),
            child: Text(
              'Solicitar Permiso',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
