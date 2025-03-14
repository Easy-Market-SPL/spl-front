import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/pages/auth/login/register_link.dart';
import 'package:spl_front/widgets/auth/social_auth.dart';
import 'package:spl_front/widgets/login/custom_welcome.dart';
import 'package:spl_front/widgets/login/login_form.dart';

class LoginPageVariant extends StatefulWidget {
  const LoginPageVariant({super.key});

  @override
  State<LoginPageVariant> createState() => _LoginPageVariantState();
}

class _LoginPageVariantState extends State<LoginPageVariant> {
  // Create the controllers for the email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // Call the clearUser method from usersBloc
    final usersBloc = BlocProvider.of<UsersBloc>(context);
    usersBloc.clearUser();
    super.initState();
  }

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

                  // Third auth
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
