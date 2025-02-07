import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/register_strings.dart';
import 'package:spl_front/widgets/buttons/custom_login_button.dart';
import 'package:spl_front/widgets/inputs/custom_input.dart';

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
              textController: widget.passwordController,
              labelText: RegisterStrings.verifyPasswordLabel,
              isPassword: true,
            ),

            const SizedBox(height: 20),

            // Login Button
            SignButton(
              eventHandler: () => {
                // TODO: Implement the logic of auth according to the email and password
                // print("A Mora le gusta el Gil")
              },
              buttonText: RegisterStrings.registerButton,
            ),
          ],
        ));
  }
}
