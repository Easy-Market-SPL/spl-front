import 'package:equatable/equatable.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object> get props => [];
}

class LoadChatsEvent extends ChatsEvent {}

class SearchChatsEvent extends ChatsEvent {
  final String query;

  const SearchChatsEvent(this.query);

  @override
  List<Object> get props => [query];
}