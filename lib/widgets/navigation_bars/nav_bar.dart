import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/widgets/navigation_bars/business_nav_bar.dart';
import 'package:spl_front/widgets/navigation_bars/customer_nav_bar.dart';
import 'package:spl_front/widgets/navigation_bars/delivery_user_nav_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final UserType userType;

  const CustomBottomNavigationBar({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android){
      switch (userType) {
        case UserType.customer:
          return const CustomerBottomNavigationBar();
        case UserType.business:
          return const BusinessBottomNavigationBar();
        case UserType.delivery:
          return const DeliveryUserBottomNavigationBar();
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
