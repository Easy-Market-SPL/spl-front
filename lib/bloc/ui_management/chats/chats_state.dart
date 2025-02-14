import 'package:equatable/equatable.dart';

import 'chats_bloc.dart';

abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object> get props => [];
}

class ChatsInitial extends ChatsState {
  final List<Chat> chats;

  const ChatsInitial({this.chats = const []});

  @override
  List<Object> get props => [chats];
}

class ChatsLoaded extends ChatsState {
  final List<Chat> originalChats;
  final List<Chat> filteredChats;

  const ChatsLoaded(this.originalChats, this.filteredChats);

  @override
  List<Object> get props => [originalChats, filteredChats];
}