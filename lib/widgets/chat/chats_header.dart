import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/chat_strings.dart';

class ChatsBusinessUserHeader extends StatelessWidget {
  const ChatsBusinessUserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = screenHeight * 0.05;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 10.0, right: 10.0),
      child: Row(
        children: [

          const SizedBox(width: 10),
          const Text(
            ChatStrings.attentionToCustomers,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}