import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        ScaffoldMessenger,
        SnackBar,
        Text,
        SnackBarBehavior,
        Colors;

void showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color ?? Colors.green,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
