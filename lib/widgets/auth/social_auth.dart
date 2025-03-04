import 'package:flutter/material.dart';
import 'package:spl_front/services/supabase/auth/auth_service.dart';
import 'package:spl_front/utils/strings/login_strings.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Texto descriptivo
          Text(
            LoginStrings.continueOption,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Row of Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: SocialButton(
                  text: LoginStrings.facebookText,
                  color: Colors.blue,
                  image: AssetImage("assets/images/facebook_logo.png"),
                  onTap: () {
                    // TODO: Implement the Facebook Sign In
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SocialButton(
                  text: LoginStrings.googleText,
                  color: Colors.white,
                  image: AssetImage("assets/images/google_logo.png"),
                  onTap: () {
                    SupabaseAuth.nativeGoogleSignIn();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final Color color;
  final AssetImage image;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.text,
    required this.color,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: image,
            height: 20,
            width: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color == Colors.white ? Colors.black : Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
