import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final int maxLines;
  final String? Function(String?)? validator;
  final Color textColor;
  final Color accentColor;
  final Color iconColor;
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;

  const AuthFormField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hint,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
    this.textColor = Colors.black,
    this.accentColor = AppColors.accentColor,
    this.iconColor = AppColors.iconPrimaryColor,
    this.fillColor = const Color(0x80FFFFFF),
    this.borderColor = const Color(0x14000000),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: textColor.withValues(alpha: 0.35),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: textColor.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          icon,
          color: iconColor.withValues(alpha: 0.7),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is empty';
            }
            return null;
          },
    );
  }
}
