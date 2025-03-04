import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/login_strings.dart';
import 'package:spl_front/widgets/login/custom_welcome.dart';
import 'package:spl_front/widgets/login/login_form.dart';

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

class RegisterLink extends StatelessWidget {
  const RegisterLink({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: LoginStrings.noAccountText,
        style: TextStyle(color: Colors.grey[600]),
        children: [
          TextSpan(
            text: LoginStrings.registerLink,
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Make the variability according to the SPL Configuration
                Navigator.pushReplacementNamed(context, 'register');
              },
          ),
        ],
      ),
    );
  }
}
