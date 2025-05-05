import 'package:flutter/material.dart';
import 'package:spl_front/pages/auth/login/register_link.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/auth/social_auth.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/login/login_form.dart';

import '../../../widgets/logic_widgets/user_widgets/login/custom_welcome.dart';

class WebLoginPage extends StatelessWidget {
  const WebLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: 600,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WelcomeLogin(),
                      const SizedBox(height: 30),
                      LoginForm(
                        emailController: TextEditingController(),
                        passwordController: TextEditingController(),
                      ),

                      if (SPLVariables.hasThirdAuth)...[
                        SocialAuthButtons(),
                        const SizedBox(height: 20),
                      ],

                      const SizedBox(height: 15),
                      RegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
