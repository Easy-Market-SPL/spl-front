import 'package:flutter/cupertino.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/admin_user/profile_admin.dart';
import 'package:spl_front/pages/auth/wrapper.dart';
import 'package:spl_front/pages/business_user/add_product.dart';
import 'package:spl_front/pages/business_user/chats_business_user.dart';
import 'package:spl_front/pages/business_user/dashboard_business_user.dart';
import 'package:spl_front/pages/business_user/profile_business_user.dart';
import 'package:spl_front/pages/chat/chats_web.dart';
import 'package:spl_front/pages/customer_user/cart.dart';
import 'package:spl_front/pages/customer_user/dashboard_customer_user.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/add_address.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/confirm_address.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/map_address_page.dart';
import 'package:spl_front/pages/customer_user/profile_customer_user.dart';
import 'package:spl_front/pages/delivery_user/profile_delivery.dart';
import 'package:spl_front/pages/auth/login/login_page_web.dart';
import 'package:spl_front/pages/menu/menu.dart';
import 'package:spl_front/pages/notifications/notifications.dart';
import 'package:spl_front/pages/order/delivery/orders_list_delivery.dart';
import 'package:spl_front/pages/order/order_details.dart';
import 'package:spl_front/pages/order/order_tracking.dart';
import 'package:spl_front/pages/order/orders_list.dart';
import 'package:spl_front/spl/spl_variables.dart';

import '../pages/chat/chat.dart';
import '../pages/delivery_user/delivery_user_tracking.dart';
import '../pages/auth/login/login_page.dart';
import '../pages/auth/login/login_page_variant.dart';
import '../pages/auth/register/register_page.dart';
import '../pages/auth/register/register_page_variant.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  /// AUTH RELATED
  '': (_) => Wrapper(),
  // auth forms
  'login': (_) => !SPLVariables.hasThirdAuth
      ? LoginPage() 
      : LoginPageVariant(),
  'register': (_) => !SPLVariables.hasThirdAuth
      ? RegisterPage()
      : RegisterPageVariant(),
  'login_web': (_) => WebLoginPage(),

  /// PROFILE PAGES
  'delivery_profile': (_) => DeliveryProfilePage(),
  'business_user_profile': (_) => BusinessUserProfilePage(),
  'admin_profile': (_) => AdminPanelPage(),
  'customer_profile': (_) => CustomerProfilePage(),

  /// MENU PAGES
  'delivery_user_menu': (_) => MenuScreen(userType: UserType.delivery),
  'business_user_menu': (_) => MenuScreen(userType: UserType.business),
  'customer_user_menu': (_) => MenuScreen(userType: UserType.customer),

  /// DASHBOARD PAGES
  'customer_dashboard': (_) => CustomerMainDashboard(),
  'business_dashboard': (_) => BusinessUserMainDashboard(),

  /// CHAT PAGES
  'customer_user_chat': (_) =>
      ChatScreen(userType: UserType.customer, userName: "userName"),
  'customer_chat_web': (_) => ChatWeb(userType: UserType.customer,),
  'business_user_chat': (_) =>
      ChatScreen(userType: UserType.business, userName: "customerName"),
  'business_user_chats': (_) => ChatsScreen(),
  'business_chat_web': (_) => ChatWeb(userType: UserType.business,),

  /// ORDER PAGES
  'add_product': (_) => AddProductPage(),
  'business_user_orders': (_) => OrdersScreen(userType: UserType.business),
  'customer_user_orders': (_) => OrdersScreen(userType: UserType.customer),
  'delivery_user_orders': (_) => OrdersScreenDelivery(),
  // order tracking
  'business_user_order_tracking': (_) => OrderTrackingScreen(
        userType: UserType.business,
      ),
  'customer_user_order_tracking': (_) => OrderTrackingScreen(
        userType: UserType.customer,
      ),
  'delivery_user_tracking': (_) => DeliveryUserTracking(),
  // order details
  'business_user_order_details': (_) =>
      OrderDetailsPage(userType: UserType.business),
  'customer_user_order_details': (_) =>
      OrderDetailsPage(userType: UserType.customer),

  /// ADDRESS PAGES
  'add_address': (_) => AddAddressPage(),
  'map_address': (_) => MapAddressPage(),
  'confirm_address': (_) => ConfirmAddressPage(),
  'customer_user_cart': (_) => CartScreen(),

  /// NOTIFICATIONS
  'customer_notifications': (_) => NotificationsScreen(
        userType: UserType.customer,
      ),
  'business_notifications': (_) => NotificationsScreen(
        userType: UserType.business,
      ),
};
