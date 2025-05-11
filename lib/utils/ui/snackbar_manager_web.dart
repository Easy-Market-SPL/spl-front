import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A utility class to show standardized snackbars in web dialogs
class SnackbarManager {
  /// Shows a success snackbar with a checkmark icon
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String closeLabel = 'CERRAR',
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green.shade700,
      icon: Icons.check_circle_outline,
      duration: duration,
      closeLabel: closeLabel,
    );
  }

  /// Shows an error snackbar
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? closeLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red.shade700,
      icon: Icons.error_outline,
      duration: duration,
      closeLabel: closeLabel,
    );
  }

  /// Shows an info snackbar
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? closeLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue.shade700,
      icon: Icons.info_outline,
      duration: duration,
      closeLabel: closeLabel,
    );
  }

  /// Shows a warning snackbar
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? closeLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_outlined,
      duration: duration,
      closeLabel: closeLabel,
    );
  }

  /// Base method to show a snackbar with customizable styling
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    String? closeLabel,
  }) {
    // Hide any existing SnackBar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Create the new SnackBar
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      width: kIsWeb ? 400 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: closeLabel != null
          ? SnackBarAction(
              label: closeLabel,
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            )
          : null,
    );

    // Show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}