import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Center Marker Icon
          Center(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: BounceInDown(
                from: 100,
                child: Icon(
                  Icons.location_pin,
                  size: 60,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Confirm button at the bottom
          Positioned(
            bottom: 70,
            left: 40,
            child: FadeInUp(
              child: MaterialButton(
                onPressed: () async {
                  // Here you would get the destination info and show a dialog if needed
                  Navigator.pop(context);
                },
                elevation: 0,
                height: 50,
                shape: const StadiumBorder(),
                minWidth: size.width - 120,
                color: Colors.black,
                child: const Text(
                  'Confirmar Destino',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
