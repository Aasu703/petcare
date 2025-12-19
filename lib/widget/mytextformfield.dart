import 'package:flutter/material.dart';

class MyTextformfield extends StatelessWidget {
  const MyTextformfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.errorMessage,
    this.prefixIcon,
    this.filled,
    this.fillcolor,
    this.focusNode,
    this.obscureText,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String errorMessage;
  final Widget? prefixIcon;
  final bool? filled;
  final Color? fillcolor;
  final FocusNode? focusNode;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,

      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        prefixIcon: prefixIcon,
        filled: filled,
        fillColor: fillcolor,
      ),

      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return errorMessage;
            }
            return null;
          },
    );
  }
}
