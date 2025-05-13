import 'package:flutter/material.dart';

class BtnBackLocation extends StatelessWidget {
  const BtnBackLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        child: IconButton(
          icon: Icon(
            Icons.backspace_rounded,
            color: Color(0xFF0B2477),
          ),
          onPressed: () {
            Navigator.popAndPushNamed(context, 'add_address');
          },
        ),
      ),
    );
  }
}
