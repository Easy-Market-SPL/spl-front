import 'package:flutter/material.dart';
import 'package:spl_front/services/supabase/auth/auth_service.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Sign out the user
          SupabaseAuth.signOut();
          Navigator.pushReplacementNamed(context, 'login');
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
