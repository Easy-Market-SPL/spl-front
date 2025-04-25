import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial, antes de cargar nada
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Estado de carga en progreso
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Estado con la lista de mensajes recibidos
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Estado de error con mensaje descriptivo
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}