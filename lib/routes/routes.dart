import 'package:flutter/cupertino.dart';
import 'package:spl_front/pages/admin_user/profile_admin.dart';
import 'package:spl_front/pages/business_user/add_product.dart';
import 'package:spl_front/pages/business_user/dashboard_business_user.dart';
import 'package:spl_front/pages/business_user/profile_business_user.dart';
import 'package:spl_front/pages/customer_user/dashboard_customer_user.dart';
import 'package:spl_front/pages/customer_user/profile_customer_user.dart';
import 'package:spl_front/pages/delivery_user/profile_delivery.dart';
import 'package:spl_front/pages/login_page_web.dart';

import '../pages/chat/chat.dart';
import '../pages/login/login_page.dart';
import '../pages/login/login_page_variant.dart';
import '../pages/register/register_page.dart';
import '../pages/register/register_page_variant.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  // MOBILE PAGES
  'login': (_) => LoginPage(),
  'login_variant': (_) => LoginPageVariant(),
  'register': (_) => RegisterPage(),
  'register_variant': (_) => RegisterPageVariant(),
  'delivery_profile': (_) => DeliveryProfilePage(),
  'business_user_profile': (_) => BusinessUserProfilePage(),
  'admin_profile': (_) => AdminPanelPage(),
  'customer_profile': (_) => CustomerProfilePage(),
  'customer_dashboard': (_) => CustomerMainDashboard(),
  'business_dashboard': (_) => BusinessUserMainDashboard(),
  'add_product': (_) => AddProductPage(),
  'costumer_user_chat': (_) =>
      ChatScreen(userType: ChatUserType.costumer, userName: "userName"),
  'business_user_chat': (_) =>
      ChatScreen(userType: ChatUserType.business, userName: "costumerName"),

  // WEB PAGES
  'login_web': (_) => WebLoginPage(),
};
