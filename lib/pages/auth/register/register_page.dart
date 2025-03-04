import 'package:flutter/material.dart';
import 'package:spl_front/pages/auth/register/login_link.dart';
import 'package:spl_front/widgets/register/custom_welcome.dart';
import 'package:spl_front/widgets/register/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyPasswordController =
      TextEditingController();

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
                  WelcomeRegister(),
                  const SizedBox(height: 40),

                  // Register Form
                  RegisterForm(
                      emailController: emailController,
                      passwordController: passwordController,
                      usernameController: usernameController,
                      nameController: nameController,
                      verifyPasswordController: verifyPasswordController),

                  const SizedBox(height: 20),

                  // Register Link
                  LogInLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}