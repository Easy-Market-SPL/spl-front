import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/widgets/navigation_bars/business_nav_bar.dart';
import 'package:spl_front/widgets/navigation_bars/customer_nav_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final UserType userType;

  const CustomBottomNavigationBar({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    switch (userType) {
      case UserType.customer:
        return const CustomerBottomNavigationBar();
      case UserType.business:
        return const BusinessBottomNavigationBar();
    }
  }
}