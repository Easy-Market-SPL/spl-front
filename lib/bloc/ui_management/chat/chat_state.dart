import 'package:equatable/equatable.dart';

class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final String date;
  final String? fileUrl;
  final MessageType type;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.date,
    this.fileUrl,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image, video }

abstract class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

// Initial state when there are no messages
class ChatInitial extends ChatState {
  final List<ChatMessage> messages;

  ChatInitial({this.messages = const []});

  @override
  List<Object> get props => [messages];
}

// State when messages are being loaded
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}
