import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/login_strings.dart';
import 'package:spl_front/widgets/buttons/custom_login_button.dart';
import 'package:spl_front/widgets/inputs/custom_input.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Email Field
              CustomInput(
                  hintText: LoginStrings.emailHint,
                  textController: widget.emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: LoginStrings.emailLabel,
                  isPassword: false),

              // Separate the fields with a space
              const SizedBox(height: 20),

              // Password Field
              CustomInput(
                  hintText: LoginStrings.passwordHint,
                  textController: widget.passwordController,
                  labelText: LoginStrings.passwordLabel,
                  isPassword: true),

              // Separate the fields with a space
              const SizedBox(height: 20),

              // Login Button
              SignButton(
                eventHandler: () => {
                  // TODO: Implement the logic of auth according to the role of the current user
                  Navigator.pushReplacementNamed(
                      context, 'delivery_user_orders')
                },
                buttonText: LoginStrings.loginButton,
              ),
            ],
          )),
    );
  }
}
