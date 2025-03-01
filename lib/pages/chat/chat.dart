import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/chat/chat_state.dart';
import 'package:spl_front/widgets/navigation_bars/business_nav_bar.dart';
import 'package:spl_front/widgets/navigation_bars/customer_nav_bar.dart';

import '../../bloc/ui_management/chat/chat_bloc.dart';
import '../../bloc/ui_management/chat/chat_event.dart';
import '../../widgets/chat/chat_header.dart';
import '../../widgets/chat/chat_input_area.dart';
import '../../widgets/chat/chat_messages_list.dart';

enum ChatUserType { customer, business }

class ChatScreen extends StatelessWidget {
  final ChatUserType userType;
  final String userName;

  const ChatScreen({super.key, required this.userType, required this.userName});

  @override
  Widget build(BuildContext context) {
    context.read<ChatBloc>().add(LoadMessagesEvent());
    return ChatPage(userType: userType, userName: userName);
  }
}

class ChatPage extends StatelessWidget {
  final ChatUserType userType;
  final String userName;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  ChatPage({super.key, required this.userType, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Screen Header
          ChatHeader(userType: userType, userName: userName),
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
                          Text(userName,
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
          if (userType == ChatUserType.customer)
            const CustomerBottomNavigationBar()
          else
            const BusinessBottomNavigationBar(),
        ],
      ),
    );
  }
}
