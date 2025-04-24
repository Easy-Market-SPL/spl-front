import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/widgets/menu/menu_header.dart';
import 'package:spl_front/widgets/menu/user_types_menu_items.dart';

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
    final items = menuItemsByUserType[userType]!;

    return Scaffold(
      body: Column(
        children: [
          MenuHeader(userType: userType),
          Expanded(
            child: ListView(
              children: items.map((menuItem) {
                return ListTile(
                  leading: Icon(menuItem.icon),
                  title: Text(menuItem.label),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, menuItem.route);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
