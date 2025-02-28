import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuth {
  final SupabaseClient _supabaseClient;

  SupabaseAuth(this._supabaseClient);

  Future<AuthResponse> signUp({required String email, required String password}) async {
    return await _supabaseClient.auth.signUp(
        email: email,
        password: password);
  }

  getCurrentSession() {
    return _supabaseClient.auth.currentSession;
  }
}