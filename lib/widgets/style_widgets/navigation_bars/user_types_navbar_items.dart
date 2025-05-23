import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/bottom_navigation_strings.dart';

import '../../../models/helpers/intern_logic/user_type.dart';

class NavbarItem {
  final String label;
  final String route;
  final IconData icon;

  const NavbarItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}

// Mobile NavBar Items
const Map<UserType, List<NavbarItem>> navbarItemsByUserTypeMobile = {
  // Customer NavBar Items
  UserType.customer: [
    NavbarItem(
      label: BottomNavigationStrings.home,
      route: 'customer_dashboard',
      icon: Icons.home,
    ),
    NavbarItem(
      label: BottomNavigationStrings.shopping,
      route: 'customer_user_orders',
      icon: Icons.shopping_cart,
    ),
    NavbarItem(
      label: BottomNavigationStrings.menu,
      route: 'customer_user_menu',
      icon: Icons.menu,
    ),
  ],
  // Business NavBar Items
  UserType.business: [
    NavbarItem(
      label: BottomNavigationStrings.home,
      route: 'business_dashboard',
      icon: Icons.home,
    ),
    NavbarItem(
      label: BottomNavigationStrings.orders,
      route: 'business_user_orders',
      icon: Icons.backpack_sharp,
    ),
    NavbarItem(
      label: BottomNavigationStrings.menu,
      route: 'business_user_menu',
      icon: Icons.menu,
    ),
  ],
  // Admin NavBar Items
  UserType.admin: [
    NavbarItem(
      label: BottomNavigationStrings.home,
      route: 'business_dashboard',
      icon: Icons.home_filled,
    ),
    NavbarItem(
      label: BottomNavigationStrings.orders,
      route: 'business_user_orders',
      icon: Icons.inventory_2,
    ),
    NavbarItem(
      label: BottomNavigationStrings.menu,
      route: 'admin_user_menu',
      icon: Icons.menu,
    ),
  ],
  // Delivery NavBar Items
  UserType.delivery: [
    NavbarItem(
      label: BottomNavigationStrings.orders,
      route: 'delivery_user_orders',
      icon: Icons.backpack_sharp,
    ),
    NavbarItem(
      label: BottomNavigationStrings.menu,
      route: 'delivery_user_menu',
      icon: Icons.menu,
    ),
  ],
};

// Web NavBar Items
const Map<UserType, List<NavbarItem>> navbarItemsByUserTypeWeb = {
  // Customer NavBar Items
  UserType.customer: [
    NavbarItem(
      label: BottomNavigationStrings.home,
      route: 'customer_dashboard',
      icon: Icons.home_filled,
    ),
    NavbarItem(
      label: BottomNavigationStrings.shopping,
      route: 'customer_user_orders',
      icon: Icons.shopping_cart_outlined,
    ),
    NavbarItem(
      label: BottomNavigationStrings.cart,
      route: 'customer_user_cart',
      icon: Icons.shopping_cart,
    ),
    NavbarItem(
      label: BottomNavigationStrings.profile,
      route: 'customer_profile',
      icon: Icons.person_outline,
    ),
  ],
  // Business NavBar Items
  UserType.business: [
    NavbarItem(
      label: BottomNavigationStrings.home,
      route: 'business_dashboard',
      icon: Icons.home_filled,
    ),
    NavbarItem(
      label: BottomNavigationStrings.orders,
      route: 'business_user_orders',
      icon: Icons.inventory_2,
    ),
    NavbarItem(
      label: BottomNavigationStrings.profile,
      route: 'business_user_profile',
      icon: Icons.person_outline,
    ),
  ],
  // Admin NavBar Items
  UserType.admin: [
    NavbarItem(
      label: BottomNavigationStrings.home,
      route: 'business_dashboard',
      icon: Icons.home_filled,
    ),
    NavbarItem(
      label: BottomNavigationStrings.orders,
      route: 'business_user_orders',
      icon: Icons.inventory_2,
    ),
    NavbarItem(
      label: BottomNavigationStrings.profile,
      route: 'admin_profile',
      icon: Icons.assignment_ind_outlined,
    ),
  ],
};
