import 'dart:async';
import 'package:universal_html/js.dart' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsApiWebLoader {
  static Future<void> loadGoogleMapsApi() async {
    if (kIsWeb) {
      js.context['googleMapsApiKey'] = dotenv.env['MAPS_API_KEY'];
      js.context.callMethod('loadGoogleMapsApi', [dotenv.env['MAPS_API_KEY']]);
    }
  }
}