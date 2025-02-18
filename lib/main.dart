import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/bloc/ui_management/chat/chat_bloc.dart';
import 'package:spl_front/bloc/ui_management/labels_store/labels_store_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_bloc.dart';
import 'package:spl_front/bloc/ui_management/profile_tab/profile_tab_bloc.dart';
import 'package:spl_front/pages/login/login_page.dart';
import 'package:spl_front/pages/login/login_page_variant.dart';
import 'package:spl_front/pages/login_page_web.dart';
import 'package:spl_front/providers/product_form_provider.dart';
import 'package:spl_front/providers/selected_labels_provider.dart';
import 'package:spl_front/routes/routes.dart';
import 'package:spl_front/spl/spl_variables.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Providers using BLoC, managed on the folder lib/bloc/...
      providers: [
        BlocProvider(create: (_) => ProfileTabBloc()),
        BlocProvider(create: (_) => LabelsStoreBloc()),
        ChangeNotifierProvider(create: (_) => ProductFormProvider()),
        ChangeNotifierProvider(create: (_) => LabelsProvider()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => OrderStatusBloc()),
        BlocProvider(create: (_) => ChatsBloc())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SPL Front',
        home: _getInitialRoute(),
        //initialRoute: SPLVariables.hasThirdAuth ? 'login_variant' : 'login',
        initialRoute: 'customer_user_order_tracking',
        routes: appRoutes,
      ),
    );
  }

  // Get the platform initial route
  Widget _getInitialRoute() {
    // Check if the platform is web, in this case, don't use the SPL var cause KIsWeb allows to check if the platform nature
    if (kIsWeb) {
      return const WebLoginPage();
    } else {
      // Mobile platform, so check if the third auth is enabled with the SPL Vars
      return SPLVariables.hasThirdAuth ? LoginPageVariant() : LoginPage();
    }
  }
}
