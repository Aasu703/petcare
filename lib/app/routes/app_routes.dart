import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  // Push a new route and remove all previous routes until the specified route is found
  static void push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // Push a new route and remove all previous routes until the specified route is found
  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  // pop the current route and push a new route
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  // pop to first route (root)
  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
