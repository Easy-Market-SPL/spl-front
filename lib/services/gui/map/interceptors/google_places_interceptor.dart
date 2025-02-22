import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GooglePlacesInterceptor extends Interceptor {
  final String apiKey = dotenv.env['MAPS_API_KEY']!;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      'key': apiKey,
      'language': 'es',
      'country': 'co',
    });
    super.onRequest(options, handler);
  }
}
