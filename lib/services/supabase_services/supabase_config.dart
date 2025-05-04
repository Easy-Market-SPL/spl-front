import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  late final SupabaseClient _client;

  factory SupabaseConfig() {
    return _instance;
  }

  SupabaseConfig._internal();

  static Future<void> initializeSupabase() async {
    try {
      await dotenv.load(fileName: '.env');
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (url == null || anonKey == null) {
        throw Exception('Missing Supabase URL or Anon Key in .env file');
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );

      _instance._client = Supabase.instance.client;
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  SupabaseClient get client => _client;
}