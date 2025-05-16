import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/utils/ui/ui_user_type_helper.dart';
import 'package:spl_front/widgets/style_widgets/navigation_bars/user_types_navbar_items.dart';

import '../../../models/helpers/intern_logic/user_type.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final UserType userType;
  final BuildContext context;

  const CustomBottomNavigationBar({
    super.key,
    required this.userType,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      final isAdmin = UIUserTypeHelper.isAdmin;
      final List<NavbarItem> items = navbarItemsByUserTypeMobile[
          isAdmin ? UserType.admin : userType]!; // Gets the items for the current user type
      final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
      final int currentIndex =
          items.indexWhere((item) => item.route == currentRoute);
      return BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
        onTap: (index) {
          Navigator.pushNamed(context, items[index].route);
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
