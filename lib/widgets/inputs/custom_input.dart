import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextEditingController textController;
  final TextInputType? keyboardType;
  final bool isPassword;

  // Make the constructor with the required parameters
  const CustomInput(
      {super.key,
      required this.hintText,
      required this.textController,
      this.keyboardType,
      required this.labelText,
      required this.isPassword});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
