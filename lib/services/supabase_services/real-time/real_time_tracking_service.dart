import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryTrackingService {
  DeliveryTrackingService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  late final Stream<List<Map<String, dynamic>>> _trackingStream =
      _client.from('delivery_tracking').stream(primaryKey: ['user_id']);

  Stream<List<Map<String, dynamic>>> watchAll() => _trackingStream;

  Stream<List<Map<String, dynamic>>> watchUser(String userId) => _client
      .from('delivery_tracking')
      .stream(primaryKey: ['user_id']).eq('user_id', userId);

  Future<void> upsertLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    await _client.from('delivery_tracking').upsert({
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}
