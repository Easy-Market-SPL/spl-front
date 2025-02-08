import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';

class SaveChangesButton extends StatelessWidget {
  final VoidCallback onPressed;
  // TODO: Receive the user, and update the information in the database

  const SaveChangesButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          ProfileStrings.saveChanges,
          // TODO: Update the data in the and the state management
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
