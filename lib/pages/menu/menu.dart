import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/menu_strings.dart';

class MenuScreen extends StatelessWidget {
  final UserType userType;

  const MenuScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return MenuPage(userType: userType);
  }
}

class MenuPage extends StatelessWidget {
  final UserType userType;

  const MenuPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = screenHeight * 0.05;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 25,
                    child: Text(_getAvatarText(userType)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserTypeText(userType),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(MenuStrings.myProfile, style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: _getMenuItems(context, userType),
            ),
          ),
        ],
      ),
    );
  }

  String _getAvatarText(UserType userType) {
    final Map<UserType, String> avatarTexts = {
      UserType.customer: 'UC',
      UserType.business: 'UE',
    };

    return avatarTexts[userType] ?? 'U';
  }

  String _getUserTypeText(UserType userType) {
    final Map<UserType, String> userTypeTexts = {
      UserType.customer: MenuStrings.userCustomer,
      UserType.business: MenuStrings.userBusiness,
    };

    return userTypeTexts[userType] ?? 'User';
  }

  List<Widget> _getMenuItems(BuildContext context, UserType userType) {
    final Map<UserType, List<Map<String, dynamic>>> menuItems = {
      UserType.customer: [
        {'icon': Icons.home, 'text': MenuStrings.home, 'route': 'customer_dashboard'},
        {'icon': Icons.shopping_cart, 'text': MenuStrings.cart, 'route': 'customer_user_cart'},
        {'icon': Icons.shopping_bag, 'text': MenuStrings.myPurchases, 'route': 'customer_user_orders'},
        {'icon': Icons.person, 'text': MenuStrings.myAccount, 'route': 'customer_profile'},
        {'icon': Icons.notifications, 'text': MenuStrings.notifications, 'route': 'customer_notifications'},
        {'icon': Icons.headset_mic, 'text': MenuStrings.customerSupport, 'route': 'customer_user_chat'},
      ],
      UserType.business: [
        {'icon': Icons.home, 'text': MenuStrings.home, 'route': 'business_dashboard'},
        {'icon': Icons.history, 'text': MenuStrings.orderHistory, 'route': 'business_user_orders'},
        {'icon': Icons.admin_panel_settings, 'text': MenuStrings.adminPanel, 'route': 'admin_profile'},
        {'icon': Icons.person, 'text': MenuStrings.myAccount, 'route': 'business_user_profile'},
        {'icon': Icons.notifications, 'text': MenuStrings.notifications, 'route': 'business_notifications'},
        {'icon': Icons.headset_mic, 'text': MenuStrings.customerSupport, 'route': 'business_user_chats'},
      ],
      //TODO: Add delivery user menu items
    };

    return menuItems[userType]?.map((item) {
      return ListTile(
        leading: Icon(item['icon']),
        title: Text(item['text']),
        onTap: () {
          Navigator.pushNamed(context, item['route']);
        },
      );
    }).toList() ?? [];
  }
}