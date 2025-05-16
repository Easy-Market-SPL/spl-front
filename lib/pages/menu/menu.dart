import 'package:flutter/material.dart';
import 'package:spl_front/utils/ui/ui_user_type_helper.dart';
import 'package:spl_front/widgets/style_widgets/menu/menu_header.dart';

import '../../models/helpers/intern_logic/user_type.dart';
import '../../widgets/style_widgets/menu/user_types_menu_items.dart';

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
    final isAdmin = UIUserTypeHelper.isAdmin;
    final items = menuItemsByUserType[isAdmin ? UserType.admin : userType]!;

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
