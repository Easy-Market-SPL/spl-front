import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/routes/routes.dart';
import 'package:spl_front/services/api_services/user_service/user_service.dart';
import 'package:spl_front/services/api_services/user_service/user_sync_service.dart';
import 'package:spl_front/utils/ui/snackbar_manager_web.dart';
import 'package:spl_front/utils/ui/ui_user_type_helper.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html; // To avoid issues when on mobile

import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../services/supabase_services/supabase_config.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  String? _lastRequestedUserId;
  bool isExternalAuth = false; 

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
          return const Center(child: CustomLoading());
        }

        final authState = snapshot.data;
        final session = authState?.session;
        if (session == null) {
          // Reset the user variable when there is no session
          _lastRequestedUserId = null;
          return appRoutes['login']!(context);
        } else{
          isExternalAuth = session.user.appMetadata['provider'] != 'email';
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
                Future.microtask(() async {
                  if (isExternalAuth) {
                    await _processExternalUser(context, usersBloc, session);
                  } else {
                    usersBloc.getUser(session.user.id);
                  }
                  
                });
              }
              return const Center(child: CustomLoading());
            }

            // Once the user has been loaded, redirect according to their role.
            final userRole = state.sessionUser!.rol;
            if (userRole == 'admin') {
              UIUserTypeHelper.isAdmin = true;
              return appRoutes['business_dashboard']!(context);
            } else if (userRole == 'business') {
              return appRoutes['business_dashboard']!(context);
            } else if (userRole == 'delivery') {
              return appRoutes['delivery_user_orders']!(context);
            } else if (userRole == 'customer') {
              return appRoutes['customer_dashboard']!(context);
            }

            // If the role doesn't match any, show loading or the appropiate handling
            return appRoutes['login']!(context);
          },
        );
      },
    );
  }

  Future<void> _processExternalUser(
      BuildContext context, UsersBloc usersBloc, Session session) async {

    // Try to get the user from the database
    final existingUser = await UserService.getUser(session.user.id);

    if (existingUser != null) {
      usersBloc.add(OnUpdateSessionUserEvent(existingUser));
      _cleanUrlAfterAuth();
    } else {
      await _createNewExternalUser(context, usersBloc, session);
    }
  }

  Future<void> _createNewExternalUser(
      BuildContext context, UsersBloc usersBloc, Session session) async {
    
    final newUser = await UserSyncService.syncExternalUser(session.user);

    if (newUser != null) {
      usersBloc.add(OnUpdateSessionUserEvent(newUser));
      _cleanUrlAfterAuth();
    } else {
      if (context.mounted) {
        SnackbarManager.showError(context, message: "Error al crear usuario");
      }
    }
  }

  void _cleanUrlAfterAuth() {
    if (kIsWeb) {
      final uri = Uri.parse(html.window.location.href);
      if (uri.queryParameters.containsKey('code')) {
        final baseUrl = html.window.location.origin;
        final hash = html.window.location.hash;

        // Creates the clean URL without the query parameters but with the hash
        final cleanUrl = '$baseUrl/$hash';

        // Replace the current URL without refreshing the page
        html.window.history.replaceState({}, '', cleanUrl);
      }
    }
  }
}
