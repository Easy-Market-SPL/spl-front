import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/user.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/buttons/create_user_button.dart';
import 'package:spl_front/widgets/inputs/custom_input.dart';

import '../../../bloc/users_blocs/users_management/users_management_bloc.dart';

class EditUserDialog extends StatelessWidget {
  final UserModel user;
  EditUserDialog({super.key, required this.user});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final ValueNotifier<String?> selectedRole = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    // Pre-cargar los valores actuales
    nameController.text = user.fullname;
    userNameController.text = user.username;
    selectedRole.value = user.rol;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ProfileStrings
                    .editUserTitle, // Asegúrate de definir esta cadena, por ejemplo "Edit User"
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Nombre
              CustomInput(
                hintText: ProfileStrings.nameHint,
                textController: nameController,
                labelText: ProfileStrings.nameLabel,
                isPassword: false,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              // Usuario
              CustomInput(
                hintText: ProfileStrings.userNameHint,
                textController: userNameController,
                labelText: ProfileStrings.userNameLabel,
                isPassword: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Seleccionar Rol
              buildRoleValueListenable(),
              const SizedBox(height: 24),
              // Botón de "Guardar cambios"
              CreateUserButton(
                onPress: () => handleEditUser(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ValueListenableBuilder<String?> buildRoleValueListenable() {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedRole,
      builder: (context, value, child) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Rol",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'admin',
              child: Text(ProfileStrings.adminProfile),
            ),
            DropdownMenuItem(
              value: 'business',
              child: Text(ProfileStrings.productsManagerProfile),
            ),
            DropdownMenuItem(
              value: 'delivery',
              child: Text(ProfileStrings.deliveryProfile),
            ),
            DropdownMenuItem(
              value: 'customer',
              child: Text(ProfileStrings.customerProfile),
            ),
          ],
          value: value,
          onChanged: (newValue) {
            selectedRole.value = newValue;
          },
        );
      },
    );
  }

  Future<void> handleEditUser(BuildContext context) async {
    final String newName = nameController.text.trim();
    final String newUsername = userNameController.text.trim();
    final String? newRole = selectedRole.value;

    /// Update all the user fields that have been modified
    if (newName.isNotEmpty) {
      user.fullname = newName;
    }

    if (newUsername.isNotEmpty) {
      user.username = newUsername;
    }

    if (newRole != null) {
      user.rol = newRole;
    }

    // Create a new user object with the updated values
    final updatedUser = UserModel(
      id: user.id,
      username: newUsername,
      fullname: newName,
      email: user.email,
      rol: newRole!,
    );

    try {
      bool success = await UserService.updateUser(updatedUser, user.id);
      if (success) {
        /// Update the user in the state
        BlocProvider.of<UsersManagementBloc>(context)
            .add(OnUpdateUserEvent(updatedUser));

        /// Show the successful changes dialog
        Navigator.pop(context); // Show back the dialog

        _showSuccessfulChangesDialog(context);
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating user")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showSuccessfulChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              ProfileStrings.successFullProfileUpdate,
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
                ProfileStrings.successFullProfileUpdateDescription,
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
