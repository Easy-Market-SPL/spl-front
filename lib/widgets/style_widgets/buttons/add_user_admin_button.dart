import 'package:flutter/material.dart';

import '../../../utils/strings/profile_strings.dart';

class AddUserButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddUserButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          ProfileStrings.addUser,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
