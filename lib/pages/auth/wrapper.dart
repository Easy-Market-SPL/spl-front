import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/routes/routes.dart';

import '../../bloc/ui_management/users/users_bloc.dart';
import '../../services/supabase/supabase_config.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  String? _lastRequestedUserId;

  @override
  Widget build(BuildContext context) {
    final usersBloc = context.read<UsersBloc>();

    return StreamBuilder(
      stream: SupabaseConfig().client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Error handling and initial loading
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final authState = snapshot.data;
        final session = authState?.session;
        if (session == null) {
          // Reset the user variable when there is no session
          _lastRequestedUserId = null;
          return appRoutes['login']!(context);
        }

        // With an active session, delegate the logic to the BlocBuilder
        return BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            // If the user in the bloc is null or its ID does not match the current session...
            if (state.sessionUser == null ||
                state.sessionUser!.id != session.user.id) {
              // And if the user for this ID has not been requested yet, request it
              if (_lastRequestedUserId != session.user.id) {
                _lastRequestedUserId = session.user.id;
                Future.microtask(() {
                  usersBloc.getUser(session.user.id);
                });
              }
              return const Center(child: CircularProgressIndicator());
            }

            // Once the user has been loaded, redirect according to their role.
            final userRole = state.sessionUser!.rol;
            if (userRole == 'admin' || userRole == 'business') {
              return appRoutes['business_dashboard']!(context);
            } else if (userRole == 'delivery') {
              return appRoutes['delivery_user_orders']!(context);
            } else if (userRole == 'customer') {
              return appRoutes['customer_dashboard']!(context);
            }
            // If the role doesn't match any, show loading (or you could handle another case)
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
