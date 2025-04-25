import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spl_front/models/data/chat_message.dart';
import 'package:spl_front/services/supabase/real-time/real_time_chat_service.dart';
import 'package:spl_front/services/supabase/storage/storage_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final RealTimeChatService _chatService;
  StreamSubscription? _messagesSubscription;
  String? _chatId;
  
  ChatBloc({required RealTimeChatService chatService})
      : _chatService = chatService,
        super(ChatInitial()) {
    
    // Register event handlers
    on<LoadMessagesEvent>(_onLoadMessages);
    on<UpdateMessagesEvent>(_onUpdateMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<SendFileEvent>(_onSendFile);
  }

  // Event Handlers
  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    
    try {
      // If chatId is provided directly, use it
      if (event.chatId != null) {
        _chatId = event.chatId;
      }
      // Otherwise check if we need to create a new chat for a customer
      else if (event.customerId != null && event.customerName != null) {
        final chatId = await _chatService.getOrCreateChat(
          customerId: event.customerId!,
          customerName: event.customerName!,
        );
        _chatId = chatId;
      } else {
        emit(ChatError('Missing required parameters for chat initialization'));
        return;
      }
      
      await _fetchAndEmitMessages(emit);
    } catch (e) {
      if (!emit.isDone) {
        emit(ChatError('Failed to load chat: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (_chatId == null) {
      debugPrint('Cannot send message: Chat ID is null');
      return;
    }
    
    try {
      debugPrint('Sending message to chat: $_chatId');
      await _chatService.sendMessage(
        chatId: _chatId!,
        senderType: event.senderType,
        message: event.text,
        messageType: MessageType.text
      );
      debugPrint('Message sent successfully');
      // No need to update state here as the stream will handle it
    } catch (e) {
      debugPrint('Error sending message: ${e.toString()}');
      // Consider emitting an error state or showing a notification
    }
  }

  Future<void> _onSendFile(SendFileEvent event, Emitter<ChatState> emit) async {
    if (_chatId == null) {
      debugPrint('Cannot send file: Chat ID is null');
      return;
    }

    try {
      debugPrint('Uploading file for chat: $_chatId');
      final currentState = state;
      final List<ChatMessage> currentMessages = currentState is ChatLoaded ? currentState.messages : [];

      emit(ChatFileUploading(currentMessages));

      // Generate a unique identifier for the file
      final String messageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload the file to storage
      String? fileUrl;
      if (event.messageType == MessageType.image) {
        fileUrl = await StorageService().uploadChatImage(event.filePath, messageId);
      } else {
        // Handle other file types in the future
        debugPrint('Unsupported file type: ${event.messageType}');
        return;
      }

      if (fileUrl == null) {
        debugPrint('Failed to upload file');
        emit(ChatLoaded(currentMessages));
        return;
      }

      // Send a message with the file URL
      await _chatService.sendMessage(
        chatId: _chatId!,
        message: '',
        senderType: event.senderType,
        messageType: event.messageType,
        fileUrl: fileUrl
      );

      debugPrint('File sent successfully');
      // The stream will handle updating the chat
    } catch (e) {
      debugPrint('Error sending file: ${e.toString()}');
      // Consider emitting an error state
      if (state is ChatFileUploading) {
        final currentMessages = (state as ChatFileUploading).messages;
        emit(ChatLoaded(currentMessages));
      }
    }
  }

  // Helper methods
  Future<void> _fetchAndEmitMessages(Emitter<ChatState> emit) async {
    // Cancel any existing subscriptions
    await _messagesSubscription?.cancel();

    if (_chatId == null) {
      debugPrint('Error: Chat ID is null');
      if (!emit.isDone) {
        emit(ChatError('Chat ID is not set'));
      }
      return;
    }

    try {
      debugPrint('Fetching messages for chat: $_chatId');
      final initialMessages = await _chatService.getMessages(_chatId!);
      debugPrint('Fetched ${initialMessages.length} messages from database');
      
      final messages = _convertToMessages(initialMessages);
      debugPrint('Emitting ChatLoaded state with ${messages.length} messages');
      
      if (!emit.isDone) {
        emit(ChatLoaded(messages));
        debugPrint('ChatLoaded state emitted successfully');
      }

      // Set up subscription for real-time updates
      _setupMessageSubscription();
    } catch (e) {
      debugPrint('Error fetching messages: ${e.toString()}');
      if (!emit.isDone) {
        emit(ChatError('Failed to load messages: ${e.toString()}'));
      }
    }
  }
  
  void _setupMessageSubscription() {
    if (_chatId == null) return;
    
    // Cancel any existing subscription
    _messagesSubscription?.cancel();
    
    // Subscribe to real-time updates
    _messagesSubscription = _chatService.watchChatMessages(_chatId!).listen(
      (updatedData) {
        debugPrint('Received real-time message update with ${updatedData.length} messages');
        final updatedMessages = _convertToMessages(updatedData);
        add(UpdateMessagesEvent(updatedMessages));
      },
      onError: (error) {
        debugPrint('Error in message subscription: $error');
        // Consider adding an event to handle subscription errors
      }
    );
  }

  void _onUpdateMessages(UpdateMessagesEvent event, Emitter<ChatState> emit) {
    debugPrint('Updating chat with ${event.messages.length} messages from subscription');
    emit(ChatLoaded(event.messages));
  }

  List<ChatMessage> _convertToMessages(List<Map<String, dynamic>> data) {
    return data.map((messageData) {
      final createdAt = DateTime.parse(messageData['created_at']);
      final formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);
      final formattedTime = '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';

      MessageType messageType = MessageType.text;
      if (messageData['message_type'] != null) {
        switch (messageData['message_type']) {
          case 'image': messageType = MessageType.image; break;
          case 'video': messageType = MessageType.video; break;
          default: messageType = MessageType.text;
        }
      }

      return ChatMessage(
        sender: messageData['sender_type'] ?? 'unknown',
        text: messageData['message'] ?? '',
        time: formattedTime,
        date: formattedDate,
        fileUrl: messageData['file_url'],
        type: messageType,
      );
    }).toList();
  }
  
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}