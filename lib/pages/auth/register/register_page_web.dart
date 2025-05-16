import 'package:flutter/material.dart';
import 'package:spl_front/pages/auth/register/login_link.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/auth/social_auth.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/register/register_form.dart';
import '../../../widgets/logic_widgets/user_widgets/register/custom_welcome.dart';

class RegisterPageWeb extends StatefulWidget {
  const RegisterPageWeb({super.key});

  @override
  State<RegisterPageWeb> createState() => _RegisterPageWebState();
}

class _RegisterPageWebState extends State<RegisterPageWeb> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
              maxHeight: 700, // Slightly taller for registration form
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, 
                    vertical: 20.0
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WelcomeRegister(),
                        const SizedBox(height: 30),
                        
                        // Register Form
                        RegisterForm(
                          emailController: emailController,
                          passwordController: passwordController,
                          usernameController: usernameController,
                          nameController: nameController,
                          verifyPasswordController: verifyPasswordController,
                        ),

                        const SizedBox(height: 20),

                        // Social auth buttons
                        if (SPLVariables.hasThirdAuth) ...[
                          SocialAuthButtons(),
                          const SizedBox(height: 20),
                        ],

                        const SizedBox(height: 15),
                        
                        // Login link
                        LogInLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    verifyPasswordController.dispose();
    super.dispose();
  }
}