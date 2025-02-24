import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/bloc/ui_management/address/address_bloc.dart';
import 'package:spl_front/bloc/ui_management/chat/chat_bloc.dart';
import 'package:spl_front/bloc/ui_management/chats/chats_bloc.dart';
import 'package:spl_front/bloc/ui_management/gps/gps_bloc.dart';
import 'package:spl_front/bloc/ui_management/labels_store/labels_store_bloc.dart';
import 'package:spl_front/bloc/ui_management/location/location_bloc.dart';
import 'package:spl_front/bloc/ui_management/map/map_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/bloc/ui_management/profile_tab/profile_tab_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/pages/login/login_page.dart';
import 'package:spl_front/pages/login/login_page_variant.dart';
import 'package:spl_front/pages/login_page_web.dart';
import 'package:spl_front/providers/product_form_provider.dart';
import 'package:spl_front/providers/selected_labels_provider.dart';
import 'package:spl_front/routes/routes.dart';
import 'package:spl_front/services/gui/map/map_service.dart';
import 'package:spl_front/spl/spl_variables.dart';

Future main() async {
  // Load the environment variables from the .env file for begin the app
  await dotenv.load(fileName: '.env');
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
        // Providers for manage the Location, GPS and Map on the App
        BlocProvider(create: (context) => GpsBloc()),
        BlocProvider(create: (context) => LocationBloc()),
        BlocProvider(
            create: (context) =>
                MapBloc(locationBloc: BlocProvider.of<LocationBloc>(context))),
        BlocProvider(
            create: (context) => SearchPlacesBloc(mapService: MapService())),

        // Providers for UI Management
        BlocProvider(create: (context) => ProfileTabBloc()),
        BlocProvider(create: (context) => AddressBloc()),
        BlocProvider(create: (context) => LabelsStoreBloc()),
        ChangeNotifierProvider(create: (context) => ProductFormProvider()),
        ChangeNotifierProvider(create: (context) => LabelsProvider()),
        BlocProvider(create: (context) => ChatBloc()),
        BlocProvider(create: (context) => OrderStatusBloc()),
        BlocProvider(create: (context) => ChatsBloc()),
        BlocProvider(create: (context) => OrderListBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SPL Front',
        home: _getInitialRoute(),
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
