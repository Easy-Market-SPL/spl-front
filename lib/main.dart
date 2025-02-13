import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/chat/chat_bloc.dart';
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Set the status bar color (Android)
      statusBarIconBrightness: Brightness.dark, // Set the status bar icon color to dark (Android)
      statusBarBrightness: Brightness.dark // Set the status bar brightness to dark (iOS).
    ));
    return MultiBlocProvider(
      // Providers using BLoC, managed on the folder lib/bloc/...
      providers: [
        BlocProvider(create: (_) => ProfileTabBloc()),
        BlocProvider(create: (_) => ChatBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SPL Front',
        initialRoute: SPLVariables.hasThirdAuth ? 'login_variant' : 'login',
        routes: appRoutes,
      ),
    );
  }
}
