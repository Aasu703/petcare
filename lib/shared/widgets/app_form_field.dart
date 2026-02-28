import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class AppFormLabel extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final Color? color;
  final double fontSize;

  const AppFormLabel({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? context.textPrimary,
      ),
    );
  }
}

class AppFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final double borderRadius;
  final Color? fillColor;
  final Color? hintColor;
  final Color? borderColor;
  final EdgeInsetsGeometry contentPadding;

  const AppFormTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.borderRadius = 12,
    this.fillColor,
    this.hintColor,
    this.borderColor,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor = borderColor ?? AppColors.borderColor;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 15, color: context.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          color: hintColor ?? AppColors.textHintColor,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.iconSecondaryColor, size: 22)
            : null,
        filled: true,
        fillColor: fillColor ?? AppColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: resolvedBorderColor.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: resolvedBorderColor.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        contentPadding: contentPadding,
      ),
    );
  }
}
