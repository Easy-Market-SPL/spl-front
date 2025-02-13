import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:spl_front/bloc/ui_management/chat/chat_state.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String sender;
  final String text;
  final BuildContext context;

  SendMessageEvent({
    required this.sender, 
    required this.text, 
    required this.context});

  @override
  List<Object> get props => [sender, text, context];
}

class SendFileEvent extends ChatEvent {
  final String sender;
  final String fileUrl;
  final MessageType fileType;
  final BuildContext context;

  SendFileEvent({
    required this.sender, 
    required this.fileUrl, 
    required this.fileType, 
    required this.context});

  @override
  List<Object> get props => [sender, fileUrl, fileType, context];
}

class UploadFileEvent extends ChatEvent {
  // TODO: Implement event to upload file to the server
}

// Load initial messages
class LoadMessagesEvent extends ChatEvent {}
