import 'package:flutter/material.dart';
import 'package:spl_front/pages/auth/login/register_link.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/login/login_form.dart';

import '../../../widgets/logic_widgets/user_widgets/login/custom_welcome.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WelcomeLogin(),
                  const SizedBox(height: 40),

                  // Login Form
                  LoginForm(
                      emailController: emailController,
                      passwordController: passwordController),
                  const SizedBox(height: 20),

                  // Register Link
                  RegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
