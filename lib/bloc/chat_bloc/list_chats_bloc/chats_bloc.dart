import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/chat_models/chat.dart';

import '../../../services/supabase_services/real-time/real_time_chat_service.dart';
import 'chats_event.dart';
import 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final RealTimeChatService _chatService;
  StreamSubscription? _chatsSubscription;

  ChatsBloc({required RealTimeChatService chatService})
      : _chatService = chatService,
        super(ChatsInitial()) {
    on<LoadChatsEvent>((event, emit) async {
      emit(ChatsLoading());

      // Cancel any existing subscription
      await _chatsSubscription?.cancel();

      // Subscribe to real-time chat updates
      _chatsSubscription = _chatService.watchAll().listen((chatsData) {
        final chats = chatsData
            .map((chatData) => Chat(
                  id: chatData['chat_id'],
                  name: chatData['customer_name'] ?? 'Unknown',
                  message: chatData['last_message'] ?? '',
                  date: chatData['last_message_date'] ?? '',
                  time: chatData['last_message_time'] ?? '',
                ))
            .whereNot((chat) => chat.message.isEmpty)
            .toList();

        add(ChatsLoadedEvent(chats));
      }, onError: (error) {
        add(ChatsErrorEvent(error.toString()));
      });
    });

    on<LoadCustomerChatEvent>((event, emit) async {
      emit(ChatsLoading());

      // Cancel any existing subscription
      await _chatsSubscription?.cancel();

      // Subscribe to customer's specific chat
      _chatsSubscription =
          _chatService.watchChat(event.customerId).listen((chatsData) {
        final chats = chatsData
            .map((chatData) => Chat(
                  name:
                      'Soporte', // For customer, chat is always with business support
                  message: chatData['last_message'] ?? '',
                  date: chatData['last_message_date'] ?? '',
                  time: chatData['last_message_time'] ?? '',
                  id: chatData['chat_id'],
                ))
            .toList();

        add(ChatsLoadedEvent(chats));
      }, onError: (error) {
        add(ChatsErrorEvent(error.toString()));
      });
    });

    on<ChatsLoadedEvent>((event, emit) {
      emit(ChatsLoaded(
        allChats: event.chats,
        filteredChats: event.chats,
      ));
    });

    on<ChatsErrorEvent>((event, emit) {
      emit(ChatsError(event.message));
    });

    on<SearchChatsEvent>((event, emit) {
      if (state is ChatsLoaded) {
        final currentState = state as ChatsLoaded;
        final searchQuery = event.query.toLowerCase();

        if (searchQuery.isEmpty) {
          emit(ChatsLoaded(
            allChats: currentState.allChats,
            filteredChats: currentState.allChats,
          ));
        } else {
          final filteredChats = currentState.allChats
              .where((chat) => chat.name.toLowerCase().contains(searchQuery))
              .toList();

          emit(ChatsLoaded(
            allChats: currentState.allChats,
            filteredChats: filteredChats,
          ));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
