import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapBoxPlacesInterceptor extends Interceptor {
  final accessToken = dotenv.env['MAP_BOX_ACCESS_TOKEN']!;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll(
      {
        'autocomplete': true,
        'country': 'CO',
        'proximity': 'ip',
        'language': 'es',
        'access_token': accessToken,
      },
    );

    super.onRequest(options, handler);
  }
}
