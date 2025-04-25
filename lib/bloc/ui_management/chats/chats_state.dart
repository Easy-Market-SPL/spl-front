import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/chat.dart';

abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object?> get props => [];
}

class ChatsInitial extends ChatsState {
  const ChatsInitial();
}

class ChatsLoading extends ChatsState {
  const ChatsLoading();
}

class ChatsLoaded extends ChatsState {
  final List<Chat> allChats;
  final List<Chat> filteredChats;

  const ChatsLoaded({
    required this.allChats,
    required this.filteredChats,
  });

  @override
  List<Object?> get props => [allChats, filteredChats];
}

class ChatsError extends ChatsState {
  final String message;

  const ChatsError(this.message);

  @override
  List<Object?> get props => [message];
}