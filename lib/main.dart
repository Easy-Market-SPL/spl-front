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
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/payment/payment_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/details/product_details_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/profile_tab/profile_tab_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users_management/users_management_bloc.dart';
import 'package:spl_front/providers/info_trip_provider.dart';
import 'package:spl_front/providers/product_form_provider.dart';
import 'package:spl_front/providers/selected_labels_provider.dart';
import 'package:spl_front/routes/routes.dart';
import 'package:spl_front/services/api/color_service.dart';
import 'package:spl_front/services/api/label_service.dart';
import 'package:spl_front/services/api/order_service.dart';
import 'package:spl_front/services/api/product_service.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/services/gui/map/map_service.dart';
import 'package:spl_front/services/gui/stripe/stripe_service.dart';
import 'package:spl_front/services/supabase/supabase_config.dart';
import 'package:spl_front/theme/theme.dart';

Future main() async {
  // Load the environment variables from the .env file for begin the app
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initializeSupabase();
  await ProductService.initializeProductService();
  await LabelService.initializeLabelService();
  await ColorService.initializeProductService();
  await UserService.initializeUserService();
  await OrderService.initializeOrderService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Stripe Service as a singleton
    StripeService().init();

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
        BlocProvider(create: (context) => ChatsBloc()),
        BlocProvider(create: (context) => ProductBloc()),
        BlocProvider(create: (context) => ProductFormBloc()),
        BlocProvider(create: (context) => ProductDetailsBloc()),
        BlocProvider(create: (context) => LabelBloc()),
        BlocProvider(create: (context) => OrdersBloc()),

        // Provider for Payment Management
        BlocProvider(create: (context) => PaymentBloc()),

        // Provider for User Management
        BlocProvider(create: (context) => UsersBloc()),
        BlocProvider(create: (context) => UsersManagementBloc()),

        // Change Notifier Providers
        ChangeNotifierProvider(create: (context) => ProductFormProvider()),
        ChangeNotifierProvider(create: (context) => LabelsProvider()),
        ChangeNotifierProvider(create: (context) => InfoTripProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SPL Front',
          home: appRoutes['']!(
              context), // Wrapper is a widget that manage the auth state
          routes: appRoutes,
          theme: appTheme),
    );
  }
}
