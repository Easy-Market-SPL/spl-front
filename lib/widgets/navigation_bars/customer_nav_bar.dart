import 'package:flutter/material.dart';

import '../../utils/strings/bottom_navigation_strings.dart';

class CustomerBottomNavigationBar extends StatelessWidget {
  const CustomerBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: BottomNavigationStrings.home),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: BottomNavigationStrings.shopping),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: BottomNavigationStrings.notifications),
        BottomNavigationBarItem(
            icon: Icon(Icons.menu), label: BottomNavigationStrings.menu),
      ],
      onTap: (index) {
        // TODO: Handle bottom navigation
      },
    );
  }
}
