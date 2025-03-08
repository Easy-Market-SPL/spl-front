import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/widgets/menu/menu_header.dart';
import 'package:spl_front/widgets/menu/user_types_menu_items.dart';

class CustomSidebar extends StatelessWidget {
  final UserType userType;

  const CustomSidebar({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final items = menuItemsByUserType[userType]!;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado compartido (mismo que en el menú móvil)
            MenuHeader(userType: userType),
            Expanded(
              child: ListView(
                children: items.map((menuItem) {
                  return ListTile(
                    leading: Icon(menuItem.icon, color: Colors.blueAccent),
                    title: Text(menuItem.label),
                    onTap: () {
                      Navigator.pop(context); // Cierra el sidebar
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