import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/login_strings.dart';

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
                Navigator.pushNamed(context, 'register');
              },
          ),
        ],
      ),
    );
  }
}
