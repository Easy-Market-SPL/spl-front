import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/services/supabase/auth/auth_service.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';

import '../../bloc/ui_management/users/users_bloc.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final usersBloc = context.read<UsersBloc>();

          // Do the signout process and clear the status user from Bloc
          await SupabaseAuth.signOut();
          usersBloc.clearUser();

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
