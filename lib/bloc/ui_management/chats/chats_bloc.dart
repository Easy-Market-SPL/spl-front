import 'package:flutter_bloc/flutter_bloc.dart';

import 'chats_event.dart';
import 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsInitial()) {

    on<LoadChatsEvent>((event, emit) async {
      await Future.delayed(Duration(seconds: 1));
      final chats = [
        Chat("Nombre cliente 1", "¿Pueden hacer domicilios a Medina, Cundinamarca? Me interesan...", "28/01/25 10:30 AM"),
        Chat("Nombre cliente 2", "Texto ejemplo", "--/--/-- --:-- --"),
        Chat("Nombre cliente 3", "Texto ejemplo", "--/--/-- --:-- --"),
      ];
      emit(ChatsLoaded(chats, chats));
    });

    on<SearchChatsEvent>((event, emit) async {
      final currentState = state;
      if (currentState is ChatsLoaded) {
        final filteredChats = currentState.originalChats
            .where((chat) => chat.name.toLowerCase().contains(event.query.toLowerCase()))
            .toList();
        emit(ChatsLoaded(currentState.originalChats, filteredChats));
      }
    });
  }
}

// Chat model
class Chat {
  final String name;
  final String message;
  final String date;

  Chat(this.name, this.message, this.date);
}