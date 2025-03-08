import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/menu_strings.dart';
import 'package:spl_front/utils/ui/ui_user_type_helper.dart';

class MenuHeader extends StatelessWidget {
  final UserType userType;

  const MenuHeader({super.key, required this.userType});

  String _getUserType() {
    final Map<UserType, String> userTypeTexts = {
      UserType.customer: MenuStrings.userCustomer,
      UserType.business: MenuStrings.userBusiness,
      UserType.delivery: MenuStrings.userDelivery,
    };
    return userTypeTexts[userType] ?? 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.only(left: 20, top: 60, bottom: 20, right: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 25,
            child: Text(
              UIUserTypeHelper.getAvatarTextFromUserType(userType),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getUserType(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                MenuStrings.myProfile,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}