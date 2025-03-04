import 'package:flutter/material.dart';
import 'package:spl_front/services/supabase/auth/auth_service.dart';
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
  /// Validate form fields
  /// Returns true if all fields are filled and email is valid
  bool _validate() {
    // Validation of empty fields
    if (widget.emailController.text.isEmpty ||
        widget.passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LoginStrings.emptyFields)),
      );
      return false;
    }
    // Validation of email with regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (widget.emailController.text.isEmpty ||
        !emailRegex.hasMatch(widget.emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LoginStrings.invalidEmail)),
      );
      return false;
    }
    return true;
  }

  /// Sign in method using Supabase
  /// If the login is successful, the user is redirected to the home page according to his role
  void login() async {
    if (!_validate()) return;

    try {
      await SupabaseAuth.signIn(
          email: widget.emailController.text,
          password: widget.passwordController.text);
      _redirectOnceLogged();
    } catch (e) {
      if (context.mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LoginStrings.wrongCredentials)),
        );
      }
    }
  }

  void _redirectOnceLogged() {
    final user = SupabaseAuth.getCurrentSession()?.user;
    if(user == null) return;

    // TODO Add user retrieval from the database and check the role
    // TODO Add the redirection for delivery
    var userRole = 'customer'; // user.role
    userRole == 'admin' || userRole == 'business'
        ? Navigator.pushReplacementNamed(context, 'business_dashboard')
        : userRole == 'delivery'
        ? Navigator.pushReplacementNamed(context, 'delivery_profile')
        : userRole == 'customer'
        ? Navigator.pushReplacementNamed(context, 'customer_dashboard')
        // If the user has no role no redirection is done and an error message is displayed
        : ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LoginStrings.unknownError)),
          );
  }



  /////////////////////
  /// BUILD METHOD
  ////////////////////
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
                eventHandler: () => login(),
                buttonText: LoginStrings.loginButton,
              ),
            ],
          )),
    );
  }
}
