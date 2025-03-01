import 'package:flutter/material.dart';

import '../../utils/strings/bottom_navigation_strings.dart';

class DeliveryUserBottomNavigationBar extends StatelessWidget {
  const DeliveryUserBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.backpack_sharp),
            label: BottomNavigationStrings.orders),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: BottomNavigationStrings.notifications),
        BottomNavigationBarItem(
            icon: Icon(Icons.menu), label: BottomNavigationStrings.menu),
      ],
      onTap: (index) {
        // TODO: Handle bottom navigation
        switch (index) {
          case 0:
            Navigator.pushNamed(context, 'delivery_user_orders');
            break;
          case 1:
            Navigator.pushNamed(context, 'delivery_user_notifications');
            break;
          case 2:
            Navigator.pushNamed(context, 'delivery_user_menu');
            break;
        }
      },
    );
  }
}
