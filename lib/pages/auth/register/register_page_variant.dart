import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/register_strings.dart';
import 'package:spl_front/widgets/auth/social_auth.dart';
import 'package:spl_front/widgets/register/custom_welcome.dart';
import 'package:spl_front/widgets/register/register_form.dart';

class RegisterPageVariant extends StatefulWidget {
  const RegisterPageVariant({super.key});

  @override
  State<RegisterPageVariant> createState() => _RegisterPageVariantState();
}

class _RegisterPageVariantState extends State<RegisterPageVariant> {
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

                  SocialAuthButtons(),

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
        text: RegisterStrings.alreadyAccountText,
        style: TextStyle(color: Colors.grey[600]),
        children: [
          TextSpan(
            text: RegisterStrings.loginLink,
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Make the variability according to the SPL Configuration
                Navigator.pushReplacementNamed(context, 'login_variant');
              },
          ),
        ],
      ),
    );
  }
}
