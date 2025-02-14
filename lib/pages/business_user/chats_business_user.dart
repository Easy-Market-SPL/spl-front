import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_bloc.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_event.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_state.dart';
import 'package:spl_front/utils/strings/chat_strings.dart';
import 'package:spl_front/widgets/chat/chat_item.dart';
import 'package:spl_front/widgets/chat/chats_header.dart';
import 'package:spl_front/widgets/navigation_bars/customer_nav_bar.dart';
import 'package:spl_front/pages/chat/chat.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ChatsBloc>().add(LoadChatsEvent());
    return ChatsPage();
  }
}

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

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
                      itemCount: state.filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = state.filteredChats[index];
                        return GestureDetector(
                          onTap: () {
                            _searchFocusNode.unfocus(); // Avoid the keyboard to stay open
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  userType: ChatUserType.business,
                                  userName: chat.name, //TODO: Add a real parameter like the ID
                                ),
                              ),
                            );
                          },
                          child: chatItem(chat.name, chat.message, chat.date),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const CustomerBottomNavigationBar(), //TODO: Change to BusinessBottomNavigationBar
          ],
        ),
      ),
    );
  }
}