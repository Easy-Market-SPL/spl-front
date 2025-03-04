import 'package:flutter/material.dart';

import '../../utils/strings/profile_strings.dart';

class CreateUserButton extends StatelessWidget {
  final BuildContext context;
  const CreateUserButton({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement the logic to save the new user in the database and the state management// Do nothing
          Navigator.pop(this.context); // Close the Dialog
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          ProfileStrings.saveChanges,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
