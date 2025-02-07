import 'package:flutter/material.dart';
import 'package:spl_front/routes/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SPL Front',
      initialRoute: 'login',
      routes: appRoutes,
    );
  }
}
