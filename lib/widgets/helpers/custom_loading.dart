import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: LoadingAnimationWidget.flickr(
            leftDotColor: Colors.blue,
            rightDotColor: Colors.lightBlue,
            size: 65,
          ),
        ),
      ),
    );
  }
}
