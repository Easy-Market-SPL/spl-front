import 'package:flutter/material.dart';
import 'package:spl_front/pages/chat/chat.dart';
import 'package:spl_front/utils/strings/menu_strings.dart';
import 'package:spl_front/widgets/app_bars/menu_app_bar.dart';

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
    return Scaffold(
      body: Column(
        children: [
          MenuHeader(userType: userType),
          Expanded(
            child: ListView(
              children: userType == ChatUserType.customer ? costumerMenuItems(context) : businessMenuItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> costumerMenuItems(BuildContext context) {
    return [
      menuItem(context, Icons.home, MenuStrings.home, 'customer_dashboard'),
      menuItem(context, Icons.shopping_cart, MenuStrings.cart, ''),
      menuItem(context, Icons.shopping_bag, MenuStrings.myPurchases, 'customer_user_orders'),
      menuItem(context, Icons.person, MenuStrings.myAccount, 'customer_profile'),
      menuItem(context, Icons.notifications, MenuStrings.notifications, 'customer_notifications'),
      menuItem(context, Icons.headset_mic, MenuStrings.customerSupport, 'custumer_user_chat'),
    ];
  }

  List<Widget> businessMenuItems(BuildContext context) {
    return [
      menuItem(context, Icons.home, MenuStrings.home, 'business_dashboard'),
      menuItem(context, Icons.history, MenuStrings.orderHistory, 'business_user_orders'),
      menuItem(context, Icons.admin_panel_settings, MenuStrings.adminPanel, 'admin_profile'),
      menuItem(context, Icons.person, MenuStrings.myAccount, 'business_user_profile'),
      menuItem(context, Icons.notifications, MenuStrings.notifications, 'business_notifications'),
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