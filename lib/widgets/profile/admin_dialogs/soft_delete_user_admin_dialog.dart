import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users_management/users_management_bloc.dart';
import 'package:spl_front/models/user.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';

class SoftDeleteUserDialog extends StatelessWidget {
  final UserModel user;

  const SoftDeleteUserDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          ProfileStrings.confirmDeleteTitle,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.blue, size: 50),
          SizedBox(height: 10),
          Text(
            ProfileStrings.confirmDeleteDescription,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        // Cancel Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(ProfileStrings.cancel),
        ),
        // Confirm Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            final success = await UserService.deleteUser(user.id);

            if (success) {
              // Update the bloc state with the new list of users
              BlocProvider.of<UsersManagementBloc>(context).add(
                OnSoftDeleteUserEvent(user),
              );

              _showSuccessfulDeleteDialog(context);

              /// Show the successful changes dialog
              await Future.delayed(
                const Duration(seconds: 1),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else {
              // Error Message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error deleting user")),
              );
            }
          },
          child: const Text(ProfileStrings.confirm),
        ),
      ],
    );
  }

  void _showSuccessfulDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              ProfileStrings.deleteConfirmation,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.blue, size: 50),
              SizedBox(height: 10),
              Text(
                ProfileStrings.deleteConfirmationDescription,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
