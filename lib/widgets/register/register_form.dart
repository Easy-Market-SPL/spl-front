import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/register_strings.dart';
import 'package:spl_front/widgets/buttons/custom_login_button.dart';
import 'package:spl_front/widgets/inputs/custom_input.dart';

import '../../services/supabase/auth/auth_service.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController verifyPasswordController;

  const RegisterForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.nameController,
    required this.verifyPasswordController,
  });



  @override
  State<RegisterForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<RegisterForm> {
  void _register() async {
    final email = widget.emailController.text;
    final password = widget.passwordController.text;

    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final response = await SupabaseAuth.signUp(email: email, password: password);
    if (response.user != null) {
      Navigator.pop(context);
    } else {
      // Handle registration error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed')),
      );
    }
  }

  bool _validate() {
    final email = widget.emailController.text;
    final password = widget.passwordController.text;
    final verifyPassword = widget.verifyPasswordController.text;
    final username = widget.usernameController.text;
    final name = widget.nameController.text;

    // Check no empty fields
    if (email.isEmpty || password.isEmpty || verifyPassword.isEmpty || username.isEmpty || name.isEmpty) {
      return false;
    }

    // Check if password and verify password are the same
    if (password != verifyPassword) {
      return false;
    }

    // Check if email is valid with regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Username Field
            CustomInput(
              hintText: RegisterStrings.userHint,
              textController: widget.usernameController,
              keyboardType: TextInputType.text,
              labelText: RegisterStrings.userLabel,
              isPassword: false,
            ),

            const SizedBox(height: 20),

            // Name Field
            CustomInput(
              hintText: RegisterStrings.nameHint,
              textController: widget.nameController,
              keyboardType: TextInputType.text,
              labelText: RegisterStrings.nameLabel,
              isPassword: false,
            ),

            const SizedBox(height: 20),

            // Email Field
            CustomInput(
              hintText: RegisterStrings.emailHint,
              textController: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              labelText: RegisterStrings.emailLabel,
              isPassword: false,
            ),

            const SizedBox(height: 20),

            // Password Field
            CustomInput(
              hintText: RegisterStrings.passwordHint,
              textController: widget.passwordController,
              labelText: RegisterStrings.passwordLabel,
              isPassword: true,
            ),

            const SizedBox(height: 20),

            // Verify Password Field
            CustomInput(
              hintText: RegisterStrings.verifyPasswordHint,
              textController: widget.verifyPasswordController,
              labelText: RegisterStrings.verifyPasswordLabel,
              isPassword: true,
            ),

            const SizedBox(height: 20),

            // Login Button
            SignButton(
              eventHandler: _register,
              buttonText: RegisterStrings.registerButton,
            ),
          ],
        ));
  }
}
