import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:spl_front/models/chat_models/chat_message.dart';

import '../../../models/helpers/intern_logic/user_type.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatEvent {
  final String? chatId;
  final String? customerId;
  final String? customerName;

  const LoadMessagesEvent({
    this.chatId,
    this.customerId,
    this.customerName,
  });

  @override
  List<Object?> get props => [chatId, customerId, customerName];
}

class UpdateMessagesEvent extends ChatEvent {
  final List<ChatMessage> messages;

  const UpdateMessagesEvent(this.messages);
}

class SendMessageEvent extends ChatEvent {
  final UserType senderType;
  final String text;

  const SendMessageEvent({
    required this.senderType,
    required this.text,
  });

  @override
  List<Object?> get props => [senderType, text];
}

class SendFileEvent extends ChatEvent {
  final UserType senderType;
  final MessageType messageType;
  final String filePath; // Path to the file to be sent
  final Uint8List? webBytes;

  const SendFileEvent({
    required this.senderType,
    required this.messageType,
    required this.filePath,
    this.webBytes,
  });

  @override
  List<Object?> get props => [senderType];
}
