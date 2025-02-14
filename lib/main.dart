import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/bloc/ui_management/labels_store/labels_store_bloc.dart';
import 'package:spl_front/bloc/ui_management/profile_tab/profile_tab_bloc.dart';
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
