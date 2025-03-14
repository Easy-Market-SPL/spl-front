import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_config.dart';

class SupabaseAuth {
  static final SupabaseAuth _instance = SupabaseAuth._internal();
  final SupabaseClient _supabaseClient = SupabaseConfig().client;

  factory SupabaseAuth() {
    return _instance;
  }

  SupabaseAuth._internal();

  static Future<AuthResponse> signUp(
      {required String email, required String password}) async {
    return await _instance._supabaseClient.auth
        .signUp(email: email, password: password);
  }

  static Session? getCurrentSession() {
    return _instance._supabaseClient.auth.currentSession;
  }

  static Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    return await _instance._supabaseClient.auth
        .signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _instance._supabaseClient.auth.signOut();
  }

  static Future<UserResponse> createUser({
    required String email,
    required String password,
  }) async {
    final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
    if (serviceRoleKey == null || serviceRoleKey.isEmpty) {
      throw Exception("Service role key not found in .env");
    }
    // Se obtiene la URL de Supabase desde las .env
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception("Supabase URL not found in .env");
    }
    // Se crea un cliente admin usando la service role key
    final supabaseAdminClient = SupabaseClient(supabaseUrl, serviceRoleKey);
    return await supabaseAdminClient.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: password,
      ),
    );
  }

  // Sign in with Google
  static Future<AuthResponse> nativeGoogleSignIn() async {
    final webClientId = dotenv.env['WEB_CLIENT_ID'];
    final iosClientId = dotenv.env['IOS_CLIENT_ID'];

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return _instance._supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
