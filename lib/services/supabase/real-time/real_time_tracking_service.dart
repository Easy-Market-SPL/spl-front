import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio que encapsula la lógica de lectura y escritura sobre la tabla
/// `delivery_tracking`.
class DeliveryTrackingService {
  DeliveryTrackingService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /* ---------------------------------------------------------------------------
   * 1️⃣  STREAM – Escucha en tiempo real todos los registros.
   * -------------------------------------------------------------------------*/

  /// Mantén el stream en una variable de instancia para evitar nuevas
  /// subscripciones cada vez que se reconstruya el widget.
  late final Stream<List<Map<String, dynamic>>> _trackingStream =
      _client.from('delivery_tracking').stream(primaryKey: ['user_id']);

  /// Exponemos el stream para que lo consuma cualquier widget.
  Stream<List<Map<String, dynamic>>> watchAll() => _trackingStream;

  /// Si solo quieres escuchar el registro de un usuario concreto:
  Stream<List<Map<String, dynamic>>> watchUser(String userId) => _client
      .from('delivery_tracking')
      .stream(primaryKey: ['user_id']).eq('user_id', userId);

  /* ---------------------------------------------------------------------------
   * 2️⃣  WRITE – Inserta o actualiza la localización de un usuario.
   * -------------------------------------------------------------------------*/

  /// Escribe (o actualiza) la fila del usuario.
  /// Si ya existe, la instrucción `upsert` la reemplaza con los nuevos datos.
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
