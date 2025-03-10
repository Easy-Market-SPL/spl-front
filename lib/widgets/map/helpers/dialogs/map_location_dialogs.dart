import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/map_strings.dart';

import '../../../../bloc/ui_management/gps/gps_bloc.dart';

void showGpsLocationDialog(BuildContext context) {
  double mediaQueryWidth = (MediaQuery.of(context).size.width / 1.5);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(
          child: Text(
            MapStrings.activeGPS,
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
              MapStrings.activeGPSDescription,
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
              MapStrings.cancel,
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
            MapStrings.locationPermission,
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
              MapStrings.locationPermissionDescription,
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
              MapStrings.cancel,
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
              MapStrings.askLocationPermission,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
