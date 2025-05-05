import 'package:equatable/equatable.dart';
import 'package:spl_front/models/chat_models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Load State
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// State with loaded messages
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatFileUploading extends ChatState {
  final List<ChatMessage> messages;

  const ChatFileUploading(this.messages);
}

/// Error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
