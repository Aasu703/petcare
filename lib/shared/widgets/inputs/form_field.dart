import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

/// Label widget for form fields
class FormLabel extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final Color? color;
  final double fontSize;
  final bool isRequired;

  const FormLabel({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.fontSize = 14,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color ?? context.textPrimary,
            ),
          ),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: AppColors.errorColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// Standard text form field with customization options
class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final double borderRadius;
  final Color? fillColor;
  final Color? hintColor;
  final Color? borderColor;
  final EdgeInsetsGeometry contentPadding;
  final TextCapitalization textCapitalization;

  const FormTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.borderRadius = 12,
    this.fillColor,
    this.hintColor,
    this.borderColor,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor = borderColor ?? AppColors.borderColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          FormLabel(text: labelText!),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          textCapitalization: textCapitalization,
          style: TextStyle(fontSize: 15, color: context.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 15,
              color: hintColor ?? AppColors.textHintColor,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppColors.iconSecondaryColor,
                    size: 22,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: AppColors.iconSecondaryColor,
                      size: 22,
                    ),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            filled: true,
            fillColor: fillColor ?? AppColors.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: resolvedBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: resolvedBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.iconPrimaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dropdown form field widget
class FormDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String hintText;
  final String? labelText;
  final String? Function(T?)? validator;
  final double borderRadius;
  final Color? fillColor;

  const FormDropdownField({
    super.key,
    required this.items,
    required this.hintText,
    this.value,
    this.onChanged,
    this.labelText,
    this.validator,
    this.borderRadius = 12,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          FormLabel(text: labelText!),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(fontSize: 15, color: context.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: fillColor ?? AppColors.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: AppColors.iconPrimaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Backward compatibility - kept old names as exports
typedef AppFormTextField = FormTextField;
typedef AppFormLabel = FormLabel;
