import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../bloc/users_blocs/users_management/users_management_bloc.dart';
import '../../../../models/users_models/user.dart';
import '../../../../services/api_services/user_service/user_service.dart';
import '../../../../services/supabase_services/auth/auth_service.dart';
import '../../../../spl/spl_variables.dart';
import '../../../style_widgets/buttons/create_user_button.dart';
import '../../../style_widgets/inputs/custom_input.dart';

class AddUserDialog extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<String?> selectedRole = ValueNotifier<String?>(null);

  AddUserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 450,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ProfileStrings.userTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Name
              CustomInput(
                hintText: ProfileStrings.nameHint,
                textController: nameController,
                labelText: ProfileStrings.nameLabel,
                isPassword: false,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              // Username
              CustomInput(
                hintText: ProfileStrings.userNameHint,
                textController: userNameController,
                labelText: ProfileStrings.userNameLabel,
                isPassword: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Email
              CustomInput(
                hintText: ProfileStrings.emailHint,
                textController: emailController,
                labelText: ProfileStrings.emailLabel,
                isPassword: false,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password
              CustomInput(
                hintText: ProfileStrings.passwordHint,
                textController: passwordController,
                labelText: ProfileStrings.passwordLabel,
                isPassword: true,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16),
              // Select Role
              buildRoleValueListenable(),
              const SizedBox(height: 24),
              // Create User Button: se le pasa el handler que valida y crea el usuario
              CreateUserButton(
                onPress: () => handleCreateUser(context),
              ),
            ],
          ),
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
            if (SPLVariables.hasRealTimeTracking) ...[
              DropdownMenuItem(
                value: 'delivery',
                child: Text(ProfileStrings.deliveryProfile),
              ),
            ],
          ],
          onChanged: (value) {
            selectedRole.value = value;
          },
        );
      },
    );
  }

  /// Show a dialog with a message of successful changes
  void _showSuccessfulCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              ProfileStrings.successFullUserCreated,
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
                ProfileStrings.successFullUserCreatedDescription,
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

  Future<void> handleCreateUser(BuildContext context) async {
    final name = nameController.text.trim();
    final username = userNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final role = selectedRole.value;

    // Validate empty fields
    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format")),
      );
      return;
    }

    // Validate password length
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    try {
      final UserResponse userResponse =
          await SupabaseAuth.createUser(email: email, password: password);
      final user = userResponse.user;
      late UserModel createdUser;
      if (user != null) {
        createdUser = UserModel(
          id: user.id,
          username: username,
          fullname: name,
          email: email,
          rol: role,
        );
        bool success = await UserService.createUser(createdUser);
        if (success) {
          final usersManagementBloc =
              BlocProvider.of<UsersManagementBloc>(context);
          usersManagementBloc.add(OnAddUserEvent(createdUser));

          // Show for 1.5 seconds the dialog of EveryThing OK
          _showSuccessfulCreationDialog(context);
          await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
          Navigator.pop(context); // Close the dialog

          Navigator.of(context).pop(); // Close dialog of user creation
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error creating user in API")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error creating user in Auth")),
        );
      }
    } catch (e) {
      if (e is AuthException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.message}. You might not have permission to create a user from the client side.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }
}
