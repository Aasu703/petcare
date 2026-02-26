import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.successColor);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.errorColor);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: Colors.blueGrey);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
