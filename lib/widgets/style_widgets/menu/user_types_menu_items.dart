import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/menu_strings.dart';

import '../../../models/helpers/intern_logic/user_type.dart';

class MenuItem {
  final String label;
  final String route;
  final IconData icon;

  const MenuItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}

const Map<UserType, List<MenuItem>> menuItemsByUserType = {
  // Customer menu items
  UserType.customer: [
    MenuItem(
      label: MenuStrings.home,
      route: 'customer_dashboard',
      icon: Icons.home,
    ),
    MenuItem(
      label: MenuStrings.cart,
      route: 'customer_user_cart',
      icon: Icons.shopping_cart,
    ),
    MenuItem(
      label: MenuStrings.myPurchases,
      route: 'customer_user_orders',
      icon: Icons.shopping_bag,
    ),
    MenuItem(
      label: MenuStrings.myAccount,
      route: 'customer_profile',
      icon: Icons.person,
    ),
    MenuItem(
      label: MenuStrings.customerSupport,
      route: 'customer_user_chat',
      icon: Icons.headset_mic,
    ),
  ],
  // Business menu items
  UserType.business: [
    MenuItem(
      label: MenuStrings.home,
      route: 'business_dashboard',
      icon: Icons.home,
    ),
    MenuItem(
      label: MenuStrings.orderHistory,
      route: 'business_user_orders',
      icon: Icons.history,
    ),
    MenuItem(
      label: MenuStrings.adminPanel,
      route: 'admin_profile',
      icon: Icons.admin_panel_settings,
    ),
    MenuItem(
      label: MenuStrings.myAccount,
      route: 'business_user_profile',
      icon: Icons.person,
    ),
    MenuItem(
      label: MenuStrings.customerSupport,
      route: 'business_user_chats',
      icon: Icons.headset_mic,
    ),
  ],
  // Delivery menu items
  UserType.delivery: [
    MenuItem(
      label: MenuStrings.orders,
      route: 'delivery_user_orders',
      icon: Icons.backpack,
    ),
    MenuItem(
      label: MenuStrings.myAccount,
      route: 'delivery_profile',
      icon: Icons.person,
    ),
  ],
};
