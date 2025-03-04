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
import 'package:spl_front/pages/business_user/dashboard_business_user.dart';
import 'package:spl_front/pages/customer_user/dashboard_customer_user.dart';
import 'package:spl_front/pages/delivery_user/profile_delivery.dart';
import 'package:spl_front/pages/login/login_page.dart';
import 'package:spl_front/pages/login/login_page_variant.dart';
import 'package:spl_front/pages/login_page_web.dart';
import 'package:spl_front/providers/info_trip_provider.dart';
import 'package:spl_front/providers/product_form_provider.dart';
import 'package:spl_front/providers/selected_labels_provider.dart';
import 'package:spl_front/routes/routes.dart';
import 'package:spl_front/services/gui/map/map_service.dart';
import 'package:spl_front/services/supabase/supabase_config.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/login_strings.dart';

Future main() async {
  // Load the environment variables from the .env file for begin the app
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initializeSupabase();
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
        BlocProvider(create: (context) => ChatBloc()),
        BlocProvider(create: (context) => OrderStatusBloc()),
        BlocProvider(create: (context) => ChatsBloc()),
        BlocProvider(create: (context) => OrderListBloc()),

        // Change Notifier Providers
        ChangeNotifierProvider(create: (context) => ProductFormProvider()),
        ChangeNotifierProvider(create: (context) => LabelsProvider()),
        ChangeNotifierProvider(create: (context) => InfoTripProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SPL Front',
        home: Wrapper(),
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

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: SupabaseConfig().client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final authState = snapshot.data;

          if (authState == null) {
            return const Text("Error desconocido");
          } else {
            final session = authState.session;
            if (session != null) {
              // final user = session.user;
              // TODO Add user retrieval from the database and check the role Add the redirection for delivery
              
              var userRole = 'customer'; // user.role

              if (userRole == 'admin' || userRole == 'business') {
                return const BusinessUserMainDashboard();
              } else if (userRole == 'delivery') {
                return const DeliveryProfilePage();
              } else if (userRole == 'customer') {
                return const CustomerMainDashboard();
              }
            } else {
              return const LoginPage();
            }
          }
          return const SizedBox.shrink();
        });
  }
}
