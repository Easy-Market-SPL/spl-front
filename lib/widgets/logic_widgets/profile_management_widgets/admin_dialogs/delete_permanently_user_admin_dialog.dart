import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users_management/users_management_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';

import '../../../../models/users_models/user.dart';
import '../../../../services/api_services/user_service/user_service.dart';

class DeletePermanentlyUserDialog extends StatelessWidget {
  final UserModel user;

  const DeletePermanentlyUserDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          ProfileStrings.confirmPermanentlyDeleteTitle,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.blue, size: 50),
          SizedBox(height: 10),
          Text(
            ProfileStrings.confirmDeletePermanentlyDescription,
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
            final success = await UserService.deletePermanentlyUser(user.id);

            if (success) {
              // Update the bloc state with the new list of users
              BlocProvider.of<UsersManagementBloc>(context)
                  .add(OnPermanentDeleteUserEvent(user));

              /// Show the successful changes dialog
              _showSuccessfulDeleteDialog(context);
              await Future.delayed(
                  const Duration(seconds: 1, milliseconds: 500));
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Close the external Dialog
              Navigator.of(context)
                  .pop(); // Close the dialog of soft-deleted users
            } else {
              // Error Message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Error en la eliminación permanente del usuario")),
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
              ProfileStrings.deletePermanentlyConfirmation,
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
                ProfileStrings.deletePermanentlyConfirmationDescription,
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
