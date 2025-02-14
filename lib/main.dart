import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/profile_tab/profile_tab_bloc.dart';
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
        BlocProvider(create: (_) => OrderStatusBloc(),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SPL Front',
        //initialRoute: SPLVariables.hasThirdAuth ? 'login_variant' : 'login',
        initialRoute: 'business_user_order_tracking',
        routes: appRoutes,
      ),
    );
  }
}
