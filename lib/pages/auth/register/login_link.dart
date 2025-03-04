import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/register_strings.dart';

class LogInLink extends StatelessWidget {
  const LogInLink({
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
                Navigator.pop(context);
              },
          ),
        ],
      ),
    );
  }
}
