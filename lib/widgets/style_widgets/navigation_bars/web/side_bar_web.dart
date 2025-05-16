import 'package:flutter/material.dart';
import 'package:spl_front/utils/ui/ui_user_type_helper.dart';
import 'package:spl_front/widgets/style_widgets/menu/menu_header.dart';

import '../../../../models/helpers/intern_logic/user_type.dart';
import '../../menu/user_types_menu_items.dart';

class CustomSidebar extends StatelessWidget {
  final UserType userType;

  const CustomSidebar({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final isAdmin = UIUserTypeHelper.isAdmin;
    final items = menuItemsByUserType[isAdmin ? UserType.admin : userType]!;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuHeader(userType: userType),
            Expanded(
              child: ListView(
                children: items.map((menuItem) {
                  return ListTile(
                    leading: Icon(menuItem.icon, color: Colors.blueAccent),
                    title: Text(menuItem.label),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, menuItem.route);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
