import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/buttons/create_user_button.dart';
import 'package:spl_front/widgets/inputs/custom_input.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                keyboardType: TextInputType.name),
            const SizedBox(height: 16),

            // Username
            CustomInput(
                hintText: ProfileStrings.userNameHint,
                textController: userNameController,
                labelText: ProfileStrings.userNameLabel,
                isPassword: false,
                keyboardType: TextInputType.text),
            const SizedBox(height: 16),

            // Email
            CustomInput(
                hintText: ProfileStrings.emailHint,
                textController: emailController,
                labelText: ProfileStrings.emailLabel,
                isPassword: false,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            // Password
            CustomInput(
                hintText: ProfileStrings.passwordHint,
                textController: passwordController,
                labelText: ProfileStrings.passwordLabel,
                isPassword: true,
                keyboardType: TextInputType.visiblePassword),
            const SizedBox(height: 16),

            // Select Role
            //TODO: Change those values per the fetch from the database
            buildRoleValueListenable(),
            const SizedBox(height: 24),

            // Save Changes Button
            // TODO: Pass the method for save the user in the database
            CreateUserButton(context: context),
          ],
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
              value: ProfileStrings.adminProfile,
              child: Text(ProfileStrings.adminProfile),
            ),
            DropdownMenuItem(
              value: ProfileStrings.productsManagerProfile,
              child: Text(ProfileStrings.productsManagerProfile),
            ),
            DropdownMenuItem(
              value: ProfileStrings.deliveryProfile,
              child: Text(ProfileStrings.deliveryProfile),
            ),
            DropdownMenuItem(
              value: ProfileStrings.supportProfile,
              child: Text(ProfileStrings.supportProfile),
            ),
          ],
          onChanged: (value) {
            selectedRole.value = value;
          },
        );
      },
    );
  }
}
