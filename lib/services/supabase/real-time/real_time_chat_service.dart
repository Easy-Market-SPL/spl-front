import 'package:flutter/material.dart';
import 'package:spl_front/models/data/chat_message.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealTimeChatService {
  RealTimeChatService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  late final Stream<List<Map<String, dynamic>>> _chatsStream =
    _client.from('chats').stream(primaryKey: ['chat_id']);

  Stream<List<Map<String, dynamic>>> watchAll() => _chatsStream;

  Stream<List<Map<String, dynamic>>> watchChat(String customerId) => _client
      .from('chats')
      .stream(primaryKey: ['chat_id']).eq('customer_id', customerId);

  Stream<List<Map<String, dynamic>>> watchMessages(String chatId) => _client
      .from('chat_messages')
      .stream(primaryKey: ['message_id'])
      .eq('chat_id', chatId)
      .order('created_at', ascending: true);

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
  try {
    final response = await _client
      .from('chat_messages')
      .select()
      .eq('chat_id', chatId)
      .order('created_at', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
    } catch (e) {
    debugPrint('Error fetching messages: ${e.toString()}');
    throw Exception('Failed to fetch messages: ${e.toString()}');
  }
}

Stream<List<Map<String, dynamic>>> watchChatMessages(String chatId) {
  return watchMessages(chatId);
}

  Future<String> getOrCreateChat({
  required String customerId,
  required String customerName,
}) async {
  // Generate chat ID using customer ID
  final chatId = 'chat_$customerId';
  
  try {
    // Check if chat already exists
    final response = await _client
        .from('chats')
        .select()
        .eq('chat_id', chatId)
        .maybeSingle();
    
    // If chat doesn't exist, create it
    if (response == null) {
      debugPrint('Chat does not exist, creating new chat with ID: $chatId');
      await _client.from('chats').upsert({
        'chat_id': chatId,
        'customer_name': customerName,
        'last_message': '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      debugPrint('Chat already exists with ID: $chatId');
    }
    
    return chatId;
  } catch (e) {
    debugPrint('Error checking/creating chat: ${e.toString()}');
    throw Exception('Failed to initialize chat: ${e.toString()}');
  }
}

  Future<void> upsertChat({
    required String chatId,
    required String customerName,
    required UserType sender,
    required String lastMessage,
    required String lastMessageTime,
    required String lastMessageDate,
  }) async {
    final response = await _client.from('chats').upsert({
      'chat_id': chatId,
      'customer_name': customerName,
      'sender': sender.name,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'last_message_date': lastMessageDate,
    });

    if (response.error != null) {
      throw Exception('Failed to upsert chat: ${response.error!.message}');
    }
  }

  Future<String> createChat({
    required String customerId,
    required String customerName,
  }) async {
    // Generate chat ID using customer ID
    final chatId = 'chat_$customerId';
    
    // Create initial chat record
    await _client.from('chats').upsert({
      'chat_id': chatId,
      'customer_name': customerName,
      'last_message': '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    return chatId;
  }
  
  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required UserType senderType,
    required String message,
    required MessageType messageType,
    String? fileUrl,
  }) async {
    final now = DateTime.now();
    
    // Insert message
    await _client.from('chat_messages').insert({
      'chat_id': chatId,
      'sender_type': senderType.name,
      'message': message,
      'message_type': messageType.name,
      'file_url': fileUrl ?? '',
      'created_at': now.toIso8601String(),
    });
    
    // Update chat metadata
    await _client.from('chats').update({
      'sender': senderType.name,
      'last_message': message,
      'last_message_time': '${now.hour}:${now.minute}',
      'last_message_date': '${now.day}/${now.month}/${now.year}',
      'updated_at': now.toIso8601String(),
    }).eq('chat_id', chatId);
  }
}