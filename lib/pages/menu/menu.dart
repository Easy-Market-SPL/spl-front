import 'package:flutter/material.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/utils/strings/menu_strings.dart';

class MenuScreen extends StatelessWidget {
  final ChatUserType userType;

  const MenuScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return MenuPage(userType: userType);
  }
}

class MenuPage extends StatelessWidget {
  final ChatUserType userType;

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
                    child: Text(userType == ChatUserType.costumer ? 'UC' : 'UE'),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userType == ChatUserType.costumer ? MenuStrings.userCustomer : MenuStrings.userBusiness,
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
              children: userType == ChatUserType.costumer ? clienteMenuItems(context) : empresaMenuItems(context),
            ),
          ),
        ],
      ),
    );
  }

  //TODO: Implement the routes for each menu item

  List<Widget> clienteMenuItems(BuildContext context) {
    return [
      menuItem(context, Icons.home, MenuStrings.home, 'customer_dashboard'),
      menuItem(context, Icons.shopping_cart, MenuStrings.cart, ''),
      menuItem(context, Icons.shopping_bag, MenuStrings.myPurchases, ''),
      menuItem(context, Icons.person, MenuStrings.myAccount, 'customer_profile'),
      menuItem(context, Icons.notifications, MenuStrings.notifications, ''),
      menuItem(context, Icons.headset_mic, MenuStrings.customerSupport, 'costumer_user_chat'),
    ];
  }

  List<Widget> empresaMenuItems(BuildContext context) {
    return [
      menuItem(context, Icons.home, MenuStrings.home, 'business_dashboard'),
      menuItem(context, Icons.history, MenuStrings.orderHistory, ''),
      menuItem(context, Icons.admin_panel_settings, MenuStrings.adminPanel, 'admin_profile'),
      menuItem(context, Icons.person, MenuStrings.myAccount, 'business_user_profile'),
      menuItem(context, Icons.notifications, MenuStrings.notifications, ''),
      menuItem(context, Icons.headset_mic, MenuStrings.customerSupport, 'business_user_chats'),
    ];
  }

  Widget menuItem(BuildContext context, IconData icon, String text, String routeName) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}