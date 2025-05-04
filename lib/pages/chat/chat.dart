import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';

import '../../bloc/chat_bloc/single_chat_bloc/chat_bloc.dart';
import '../../bloc/chat_bloc/single_chat_bloc/chat_event.dart';
import '../../bloc/chat_bloc/single_chat_bloc/chat_state.dart';
import '../../models/helpers/intern_logic/user_type.dart';
import '../../models/users_models/user.dart';
import '../../widgets/logic_widgets/chat_widgets/chat_header.dart';
import '../../widgets/logic_widgets/chat_widgets/chat_input_area.dart';
import '../../widgets/logic_widgets/chat_widgets/chat_messages_list.dart';
import '../../widgets/style_widgets/navigation_bars/nav_bar.dart';

class ChatScreen extends StatelessWidget {
  final UserType userType;
  final String? userName;
  final String? customerId;

  const ChatScreen(
      {super.key, required this.userType, this.userName, this.customerId});

  @override
  Widget build(BuildContext context) {
    return ChatPage(
      userType: userType,
      userName: userName,
      customerId: customerId,
    );
  }
}

class ChatPage extends StatelessWidget {
  final UserType userType;
  final String? userName;
  final String? customerId;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  ChatPage({
    super.key,
    required this.userType,
    required this.userName,
    this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final UserModel user =
        BlocProvider.of<UsersBloc>(context).state.sessionUser!;

    String displayName = userName ?? user.username;

    if (userType == UserType.customer) {
      // For customers, initialize chat with their info
      context.read<ChatBloc>().add(LoadMessagesEvent(
            customerId: user.id,
            customerName: user.username,
          ));
    } else {
      // For business, just load messages from existing chat
      context.read<ChatBloc>().add(LoadMessagesEvent(
            chatId: customerId,
            customerId: customerId,
            customerName: displayName,
          ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Screen Header
          ChatHeader(userType: userType, userName: displayName),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header with user avatar and name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                              radius: 30, backgroundColor: Colors.grey[300]),
                          const SizedBox(width: 10),
                          Text(displayName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    // Chat messages list
                    Expanded(
                      child: BlocListener<ChatBloc, ChatState>(
                        listener: (context, state) {
                          if (state is ChatLoaded) {
                            scrollToBottomPostFrame(_scrollController);
                          }
                        },
                        child: ChatMessagesList(
                          scrollController: _scrollController,
                          userType: userType,
                          focusNode: _focusNode,
                        ),
                      ),
                    ),
                  ],
                ),

                // This is only to avoid the messages showing between the input area and the end of the screen
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10.0,
                    color: Colors.white,
                  ),
                ),

                // Input area
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ChatInputField(
                    scrollController: _scrollController,
                    userType: userType,
                    focusNode: _focusNode,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          CustomBottomNavigationBar(userType: userType, context: context),
    );
  }
}
