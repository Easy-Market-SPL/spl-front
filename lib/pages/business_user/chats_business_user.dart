import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_bloc.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_event.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_state.dart';
import 'package:spl_front/models/data/chat.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/utils/strings/chat_strings.dart';

import '../../bloc/chat_bloc/list_chats_bloc/chats_bloc.dart';
import '../../bloc/chat_bloc/list_chats_bloc/chats_event.dart';
import '../../bloc/chat_bloc/list_chats_bloc/chats_state.dart';
import '../../models/helpers/intern_logic/user_type.dart';
import '../../widgets/logic_widgets/chat_widgets/chat_item.dart';
import '../../widgets/logic_widgets/chat_widgets/chats_header.dart';
import '../../widgets/style_widgets/navigation_bars/nav_bar.dart';

class ChatsScreen extends StatelessWidget {
  final Function(Chat)? onChatSelected;
  final Color? backgroundColor;
  final bool isWeb;

  const ChatsScreen({
    super.key,
    this.onChatSelected,
    this.backgroundColor,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    context.read<ChatsBloc>().add(LoadChatsEvent());
    return ChatsPage(
      onChatSelected: onChatSelected,
      backgroundColor: backgroundColor,
      isWeb: isWeb,
    );
  }
}

class ChatsPage extends StatefulWidget {
  final Function(Chat)? onChatSelected;
  final Color? backgroundColor;
  final bool isWeb;

  const ChatsPage({
    super.key,
    this.onChatSelected,
    this.backgroundColor,
    this.isWeb = false,
  });

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ChatsBloc>().add(SearchChatsEvent(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus(); // Avoid the keyboard to stay open
        },
        child: Column(
          children: [
            // Screen Header
            const ChatsBusinessUserHeader(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              // Search bar
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: ChatStrings.searchChatsHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ChatsBloc, ChatsState>(
                builder: (context, state) {
                  if (state is ChatsLoaded) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      itemCount: state.filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = state.filteredChats[index];
                        return GestureDetector(
                          onTap: () {
                            _searchFocusNode
                                .unfocus(); // Avoid the keyboard to stay open
                            if (widget.onChatSelected != null) {
                              widget.onChatSelected!(chat);
                            } else if (!widget.isWeb) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    userType: UserType.business,
                                    userName: chat.name,
                                    customerId: chat.id,
                                  ),
                                ),
                              );
                            }
                          },
                          child: chatItem(chat),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isWeb
          ? null
          : CustomBottomNavigationBar(
              userType: UserType.business,
              context: context,
            ),
    );
  }
}
