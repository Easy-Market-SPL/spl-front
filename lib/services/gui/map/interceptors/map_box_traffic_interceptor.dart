import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapBoxTrafficInterceptor extends Interceptor {
  final accessToken = dotenv.env['MAP_BOX_ACCESS_TOKEN']!;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      'alternatives': 'true',
      'geometries': 'polyline6',
      'overview': 'full',
      'steps': 'false',
      'access_token': accessToken,
    });
    super.onRequest(options, handler);
  }
}
