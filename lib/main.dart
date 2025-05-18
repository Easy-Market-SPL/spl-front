import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users_management/users_management_bloc.dart';
import 'package:spl_front/providers/info_trip_provider.dart';
import 'package:spl_front/providers/product_form_provider.dart';
import 'package:spl_front/providers/selected_labels_provider.dart';
import 'package:spl_front/routes/routes.dart';
import 'package:spl_front/services/api_services/order_service/order_service.dart';
import 'package:spl_front/services/api_services/product_services/color_service.dart';
import 'package:spl_front/services/api_services/product_services/label_service.dart';
import 'package:spl_front/services/api_services/product_services/product_service.dart';
import 'package:spl_front/services/api_services/review_service/review_service.dart';
import 'package:spl_front/services/api_services/user_service/user_service.dart';
import 'package:spl_front/services/external_services/google_maps/map_service.dart';
import 'package:spl_front/services/external_services/stripe/stripe_service.dart';
import 'package:spl_front/services/supabase_services/real-time/real_time_chat_service.dart';
import 'package:spl_front/services/supabase_services/supabase_config.dart';
import 'package:spl_front/spl/load_env_spl.dart';
import 'package:spl_front/theme/theme.dart';
import 'package:spl_front/utils/map/helpers/google_maps_api_web_loader.dart';

import 'bloc/chat_bloc/list_chats_bloc/chats_bloc.dart';
import 'bloc/chat_bloc/single_chat_bloc/chat_bloc.dart';
import 'bloc/location_management_bloc/gps_bloc/gps_bloc.dart';
import 'bloc/location_management_bloc/location_bloc/location_bloc.dart';
import 'bloc/orders_bloc/order_bloc.dart';
import 'bloc/product_blocs/labels_store/labels_store_bloc.dart';
import 'bloc/product_blocs/product_details/product_details_bloc.dart';
import 'bloc/product_blocs/product_filter/product_filter_bloc.dart';
import 'bloc/product_blocs/product_form/labels/label_bloc.dart';
import 'bloc/product_blocs/product_form/product_form_bloc.dart';
import 'bloc/product_blocs/products_management/product_bloc.dart';
import 'bloc/ui_blocs/map_bloc/map_bloc.dart';
import 'bloc/ui_blocs/profile_tab_bloc/profile_tab_bloc.dart';
import 'bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import 'bloc/users_session_information_blocs/address_bloc/address_bloc.dart';
import 'bloc/users_session_information_blocs/payment_bloc/payment_bloc.dart';

Future main() async {
  // Load the environment variables from the .env file for begin the app
  await dotenv.load(fileName: '.env');
  await LoadSPLClass.initializateSPLVariables();
  await SupabaseConfig.initializeSupabase();
  await ProductService.initializeProductService();
  await LabelService.initializeLabelService();
  await ColorService.initializeProductService();
  await UserService.initializeUserService();
  await OrderService.initializeOrderService();
  await ReviewService.initializeReviewService();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (kIsWeb) {
      GoogleMapsApiWebLoader.loadGoogleMapsApi();
    }
  });

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
        BlocProvider(
            create: (context) => ChatBloc(chatService: RealTimeChatService())),
        BlocProvider(
            create: (context) => ChatsBloc(chatService: RealTimeChatService())),
        BlocProvider(create: (context) => ProductBloc()),
        BlocProvider(create: (context) => ProductFormBloc()),
        BlocProvider(create: (context) => ProductDetailsBloc()),
        BlocProvider<ProductFilterBloc>(
          create: (context) => ProductFilterBloc(
            productBloc: context.read<ProductBloc>(),
          ),
        ),
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
