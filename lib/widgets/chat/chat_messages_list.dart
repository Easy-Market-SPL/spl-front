import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/data/chat_message.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'chat_message_bubble.dart';
import '../../bloc/ui_management/chat/chat_state.dart';
import '../../bloc/ui_management/chat/chat_bloc.dart';

class ChatMessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final UserType userType;
  final FocusNode focusNode;

  const ChatMessagesList({
    super.key,
    required this.scrollController,
    required this.userType,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        print('BlocBuilder rebuilding with state: ${state.runtimeType}');
        if (state is ChatLoading) {
        print('ChatMessagesList: Showing loading indicator');
        return const Center(child: CircularProgressIndicator());
      } else if (state is ChatError) {
        print('ChatMessagesList: Showing error: ${state.message}');
        return Center(child: Text("Error: ${state.message}"));
      } else if (state is ChatLoaded) {
        print('ChatMessagesList: ChatLoaded state with ${state.messages.length} messages');
        
        if (state.messages.isEmpty) {
          print('ChatMessagesList: Showing empty state message');
          return const Center(
            child: Text(
              "No hay mensajes aún. ¡Envía el primer mensaje!",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
          
          // Group messages by date
          final groupedMessages = <String, List<ChatMessage>>{};
          for (var message in state.messages) {
            if (!groupedMessages.containsKey(message.date)) {
              groupedMessages[message.date] = [];
            }
            groupedMessages[message.date]!.add(message);
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 90.0),
            itemCount: groupedMessages.length,
            itemBuilder: (context, index) {
              final date = groupedMessages.keys.elementAt(index);
              final messages = groupedMessages[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      date, 
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.grey
                      )
                    ),
                  ),
                  // Messages for this date
                  ...messages.map((message) => ChatMessageBubble(
                    message: message,
                    isCurrentUser: message.sender == (userType == UserType.customer ? 'customer' : 'business'),
                    focusNode: focusNode,
                  )),
                ],
              );
            },
          );
        } else {
          // Initial state (ChatInitial)
          return const SizedBox.shrink();
        }
      },
    );
  }
}