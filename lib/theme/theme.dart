import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  cardColor: Colors.white,
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[200],
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Colors.blue,
    circularTrackColor: Colors.blue,
    linearTrackColor: Colors.blue,
    refreshBackgroundColor: Colors.blue
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionColor: Colors.blue,
    selectionHandleColor: Colors.blue,
  ),
);