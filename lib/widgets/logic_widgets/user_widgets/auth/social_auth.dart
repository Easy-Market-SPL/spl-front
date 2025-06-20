import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/login_strings.dart';

import '../../../../services/supabase_services/auth/auth_service.dart';

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
              const SizedBox(width: 10),
              Expanded(
                child: SocialButton(
                  text: LoginStrings.googleText,
                  color: Colors.white,
                  image: AssetImage("assets/images/google_logo.png"),
                  onTap: () async {
                    try {
                      if (!kIsWeb) {
                        await SupabaseAuth.nativeGoogleSignIn();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        await SupabaseAuth.googleSignIn(context);
                      }
                    } catch (e) {
                      debugPrint("Error: $e");
                    }
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
