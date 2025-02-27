import 'package:flutter/cupertino.dart';
import 'package:spl_front/pages/admin_user/profile_admin.dart';
import 'package:spl_front/pages/business_user/add_product.dart';
import 'package:spl_front/pages/business_user/chats_business_user.dart';
import 'package:spl_front/pages/business_user/dashboard_business_user.dart';
import 'package:spl_front/pages/business_user/add_product.dart';
import 'package:spl_front/pages/business_user/dashboard_business_user.dart';
import 'package:spl_front/pages/business_user/chats_business_user.dart';
import 'package:spl_front/pages/business_user/profile_business_user.dart';
import 'package:spl_front/pages/customer_user/cart.dart';
import 'package:spl_front/pages/customer_user/dashboard_customer_user.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/add_address.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/confirm_address.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/map_address_page.dart';
import 'package:spl_front/pages/customer_user/profile_customer_user.dart';
import 'package:spl_front/pages/delivery_user/profile_delivery.dart';
import 'package:spl_front/pages/login_page_web.dart';
import 'package:spl_front/pages/menu/menu.dart';
import 'package:spl_front/pages/order/order_details.dart';
import 'package:spl_front/pages/order/order_tracking.dart';
import 'package:spl_front/pages/order/orders_list.dart';

import '../pages/chat/chat.dart';
import '../pages/login/login_page.dart';
import '../pages/login/login_page_variant.dart';
import '../pages/register/register_page.dart';
import '../pages/register/register_page_variant.dart';
import 'package:spl_front/pages/login_page_web.dart';
import 'package:spl_front/pages/menu/menu.dart';
import 'package:spl_front/pages/notifications/notifications.dart';
import 'package:spl_front/pages/order/order_details.dart';
import 'package:spl_front/pages/order/orders_list.dart';

import '../pages/chat/chat.dart';
import '../pages/login/login_page.dart';
import '../pages/login/login_page_variant.dart';
import '../pages/register/register_page.dart';
import '../pages/register/register_page_variant.dart';
import 'package:spl_front/pages/order/order_tracking.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  // MOBILE PAGES
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
  'customer_user_chat': (_) =>
      ChatScreen(userType: ChatUserType.customer, userName: "userName"),
  'business_user_chat': (_) =>
      ChatScreen(userType: ChatUserType.business, userName: "customerName"),
  'business_user_chats': (_) => ChatsScreen(),
  'business_user_menu': (_) => MenuScreen(userType: ChatUserType.business),
  'customer_user_menu': (_) => MenuScreen(userType: ChatUserType.customer),
  'business_user_order_tracking': (_) => OrderTrackingScreen(
        userType: ChatUserType.business,
      ),
  'customer_user_order_tracking': (_) => OrderTrackingScreen(
        userType: ChatUserType.customer,
      ),
  'business_user_order_details': (_) =>
      OrderDetailsPage(userType: ChatUserType.business),
  'customer_user_order_details': (_) =>
      OrderDetailsPage(userType: ChatUserType.customer),
  'business_user_orders': (_) => OrdersScreen(userType: ChatUserType.business),
  'customer_user_orders': (_) => OrdersScreen(userType: ChatUserType.customer),
  'add_address': (_) => AddAddressPage(),
  'map_address': (_) => MapAddressPage(),
  'confirm_address': (_) => ConfirmAddressPage(),
  'customer_user_cart': (_) => CartScreen(),

  // WEB PAGES
  'login_web': (_) => WebLoginPage(),
  'business_dashboard': (_) => BusinessUserMainDashboard(),
  'add_product': (_) => AddProductPage(),
  'customer_user_chat': (_) =>
      ChatScreen(userType: ChatUserType.customer, userName: "userName"),
  'business_user_chat': (_) =>
      ChatScreen(userType: ChatUserType.business, userName: "customerName"),
  'business_user_chats': (_) => ChatsScreen(),
  'business_user_menu': (_) => MenuScreen(userType: ChatUserType.business),
  'customer_user_menu': (_) => MenuScreen(userType: ChatUserType.customer),
  'business_user_order_tracking': (_) => OrderTrackingScreen(userType: ChatUserType.business,),
  'customer_user_order_tracking': (_) => OrderTrackingScreen(userType: ChatUserType.customer,),
  'business_user_order_details': (_) => OrderDetailsPage(userType: ChatUserType.business),
  'customer_user_order_details': (_) => OrderDetailsPage(userType: ChatUserType.customer),
  'business_user_orders': (_) => OrdersScreen(userType: ChatUserType.business),
  'customer_user_orders': (_) => OrdersScreen(userType: ChatUserType.customer),
  'customer_notifications': (_) => NotificationsScreen(userType: ChatUserType.customer,),
  'business_notifications': (_) => NotificationsScreen(userType: ChatUserType.business,),

  // WEB PAGES
  'login_web': (_) => WebLoginPage(),
  
  
};
