import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/chat_models/chat.dart';
import 'package:spl_front/pages/business_user/chats_business_user.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/utils/strings/chat_strings.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

import '../../models/helpers/intern_logic/user_type.dart';

class ChatWeb extends StatefulWidget {
  final UserType userType;

  const ChatWeb({super.key, required this.userType});

  @override
  State<ChatWeb> createState() => _ChatWebState();
}

class _ChatWebState extends State<ChatWeb> {
  Chat? selectedChat;
  var backgroundColor = PrimaryColors.blueWeb;

  @override
  void initState() {
    super.initState();
    if (widget.userType == UserType.customer) {
      final user =
        BlocProvider.of<UsersBloc>(context).state.sessionUser!;

      selectedChat = Chat(
        date: '', 
        id: user.id, 
        name: "Soporte",
        message: '',
        time: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      userType: widget.userType,
      body: Row(
        children: [
          // Chats list
          Expanded(
            flex: 1,
            child: widget.userType == UserType.business
              ? ChatsScreen(
                onChatSelected: (userName) {
                  setState(() {
                    selectedChat = userName;
                  });
                },
                backgroundColor: backgroundColor,
                isWeb: true,
              )

                // Left side for customer user
                : Container(
                    color: backgroundColor,
                    padding: EdgeInsets.only(top: 20, left: 10.0, right: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          ChatStrings.attentionToCustomers,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Text(
                          ChatStrings.customerDisclaimer,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Selected chat
          Expanded(
            flex: 2,
            child: selectedChat != null
                ? ChatScreen(
                    userType: widget.userType,
                    userName: selectedChat?.name,
                    customerId: selectedChat?.id,
                  )
                : Center(
                    child: Text(
                      'Seleccione un chat para ver la conversación',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
