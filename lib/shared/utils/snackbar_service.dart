import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        ScaffoldMessenger,
        SnackBar,
        Text,
        SnackBarBehavior,
        Colors;

/// Utility service for displaying snackbars across the app
/// Replaces the old common/mysnackbar.dart
class SnackbarService {
  /// Shows a snackbar with custom styling
  static void show({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.green,
        duration: duration ?? const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a success snackbar
  static void success({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Shows an error snackbar
  static void error({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Shows a warning snackbar
  static void warning({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// Shows an info snackbar
  static void info({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }
}

/// Backward compatibility: Keep the old function name for existing code
void showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
}) {
  SnackbarService.show(
    context: context,
    message: message,
    backgroundColor: color,
  );
}
