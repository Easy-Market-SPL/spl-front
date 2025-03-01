import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import '../../utils/strings/chat_strings.dart';

class ChatHeader extends StatelessWidget {
  final UserType userType;
  final String userName;

  const ChatHeader({
    super.key,
    required this.userType,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = screenHeight * 0.05;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 10.0, right: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 10),
          Text(
            userType == UserType.customer
                ? ChatStrings.attentionToCustomers
                : ChatStrings.chatWithCustomer,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}