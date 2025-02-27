import 'package:flutter/material.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/utils/strings/menu_strings.dart';

class MenuHeader extends StatelessWidget {
  final ChatUserType userType;

  const MenuHeader({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = screenHeight * 0.05;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        color: Colors.blue,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 25,
              child: Text(userType == ChatUserType.customer ? 'UC' : 'UE'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userType == ChatUserType.customer ? MenuStrings.userCustomer : MenuStrings.userBusiness,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(MenuStrings.myProfile, style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}