import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class SupabaseAuth {
  static final SupabaseAuth _instance = SupabaseAuth._internal();
  final SupabaseClient _supabaseClient = SupabaseConfig().client;

  factory SupabaseAuth() {
    return _instance;
  }

  SupabaseAuth._internal();

  static Future<AuthResponse> signUp({required String email, required String password}) async {
    return await _instance._supabaseClient.auth.signUp(
        email: email,
        password: password);
  }

  static Session? getCurrentSession() {
    return _instance._supabaseClient.auth.currentSession;
  }

  static Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _instance._supabaseClient.auth.signInWithPassword(
        email: email,
        password: password);
  }

  static Future<void> signOut() async {
    await _instance._supabaseClient.auth.signOut();
  }
}