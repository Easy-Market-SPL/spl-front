import 'package:flutter/material.dart';

class SignButton extends StatelessWidget {
  final VoidCallback? eventHandler;
  final String buttonText;

  const SignButton({super.key, this.eventHandler, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: eventHandler,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
