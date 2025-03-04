import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/business_user/chats_business_user.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/utils/strings/chat_strings.dart';

class ChatWeb extends StatefulWidget {
  final UserType userType;

  const ChatWeb({super.key, required this.userType});

  @override
  State<ChatWeb> createState() => _ChatWebState();
}

class _ChatWebState extends State<ChatWeb> {
  String? selectedChatUserName;
  var backgroundColor = PrimaryColors.blueWeb;

  @override
  void initState() {
    super.initState();
    if (widget.userType == UserType.customer) {
      //TODO: Change the way customer chat with business loads
      selectedChatUserName = 'empresa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lista de chats
            Expanded(
            flex: 1,
            child: widget.userType == UserType.business
              ? ChatsScreen(
                onChatSelected: (userName) {
                  setState(() {
                    selectedChatUserName = userName;
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      ChatStrings.customerDisclaimer,
                      style: TextStyle(fontSize: 18,),
                    ),
                    // Aquí puedes agregar el texto que desees debajo del título
                  ],
                ),
              ),
            ),
          // Conversación seleccionada
          Expanded(
            flex: 2,
            child: selectedChatUserName != null
                ? ChatScreen(
                    userType: widget.userType,
                    userName: selectedChatUserName!,
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