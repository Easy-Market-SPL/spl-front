import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/chat.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatsEvent extends ChatsEvent {
  const LoadChatsEvent();
}

class LoadCustomerChatEvent extends ChatsEvent {
  final String customerId;

  const LoadCustomerChatEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class ChatsLoadedEvent extends ChatsEvent {
  final List<Chat> chats;

  const ChatsLoadedEvent(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatsErrorEvent extends ChatsEvent {
  final String message;

  const ChatsErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchChatsEvent extends ChatsEvent {
  final String query;

  const SearchChatsEvent(this.query);

  @override
  List<Object?> get props => [query];
}