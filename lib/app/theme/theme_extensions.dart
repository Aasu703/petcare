import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColorsExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  bool get isDark => theme.brightness == Brightness.dark;

  Color get primaryColor => AppColors.primaryColor;

  Color get accentColor => AppColors.accentColor;

  Color get backgroundColor =>
      isDark ? AppColors.backgroundColorDark : AppColors.backgroundColor;

  Color get surfaceColor =>
      isDark ? AppColors.surfaceColorDark : AppColors.surfaceColor;

  Color get cardColor => isDark ? AppColors.cardColorDark : AppColors.cardColor;

  Color get textPrimary =>
      isDark ? AppColors.textPrimaryColorDark : AppColors.textPrimaryColor;

  Color get textSecondary =>
      isDark ? AppColors.textSecondaryColorDark : AppColors.textSecondaryColor;

  Color get textLight =>
      isDark ? AppColors.textLightColorDark : AppColors.textLightColor;

  Color get hintColor =>
      isDark ? AppColors.textHintColorDark : AppColors.textHintColor;

  Color get borderColor =>
      isDark ? AppColors.borderColorDark : AppColors.borderColor;

  Color get dividerColor =>
      isDark ? AppColors.dividerColorDark : AppColors.dividerColor;

  Color get successColor => AppColors.successColor;

  Color get errorColor => AppColors.errorColor;

  Color get warningColor => AppColors.warningColor;

  Color get infoColor => AppColors.infoColor;

  Color get buttonPrimaryColor => AppColors.buttonPrimaryColor;

  Color get buttonTextColor => AppColors.buttonTextColor;

  Color get iconPrimaryColor => AppColors.iconPrimaryColor;

  Color get iconSecondaryColor =>
      isDark ? AppColors.iconSecondaryColorDark : AppColors.iconSecondaryColor;
}
