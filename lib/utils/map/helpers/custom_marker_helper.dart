import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getCustomMarkerIcon(String iconImageName) async {
  final ByteData data = await rootBundle.load('assets/icons/$iconImageName');
  final ui.Codec codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: 55,
    targetHeight: 55,
  );
  final ui.FrameInfo fi = await codec.getNextFrame();
  final ByteData? byteData =
      await fi.image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List resizedData = byteData!.buffer.asUint8List();

  return BitmapDescriptor.bytes(resizedData);
}
