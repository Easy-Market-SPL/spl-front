import 'dart:io';
import 'package:http/http.dart' as http;

Future<http.Response> fetchWithRetry(
  String url, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  Exception? lastError;

  while (attempt < maxRetries) {
    try {
      final response = await http.get(Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode >= 500) {
        lastError = HttpException('Server error: ${response.statusCode}');
      } else {
        throw HttpException('Client error: ${response.statusCode}');
      }
    } catch (e) {
      lastError = e is Exception ? e : Exception(e.toString());
    }

    attempt++;
    if (attempt < maxRetries) {
      await Future.delayed(delay * attempt);
    }
  }

  throw lastError ?? Exception('Failed fetching from $url');
}