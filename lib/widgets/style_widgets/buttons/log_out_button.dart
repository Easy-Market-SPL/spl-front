import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/utils/ui/ui_user_type_helper.dart';

import '../../../bloc/orders_bloc/order_bloc.dart';
import '../../../bloc/orders_bloc/order_event.dart';
import '../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import '../../../bloc/users_blocs/users/users_bloc.dart';
import '../../../services/supabase_services/auth/auth_service.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final usersBloc = context.read<UsersBloc>();
          final searchPlacesBloc = context.read<SearchPlacesBloc>();
          final ordersBloc = context.read<OrdersBloc>();

          await SupabaseAuth.signOut();
          usersBloc.clearUser();
          searchPlacesBloc.emptyGooglePlaces();
          searchPlacesBloc.clearSelectedPlace();
          ordersBloc.add(ClearOrdersEvent());

          UIUserTypeHelper.isAdmin = false;

          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '', // Wrapper's route
              (Route<dynamic> route) => false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          side: const BorderSide(color: Colors.red),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          ProfileStrings.logout,
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }
}
