import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  /// Initialize Supabase Client
  static Future<void> initializeSupabase() async {
    await dotenv.load(fileName: '.env');
    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? ''
    );
  }

  /// Get the Supabase Client
  static SupabaseClient get client => Supabase.instance.client;
}