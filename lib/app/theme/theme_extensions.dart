import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColorsExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  bool get isDark => theme.brightness == Brightness.dark;

  Color get primaryColor => colorScheme.primary;

  Color get accentColor => colorScheme.secondary;

  Color get backgroundColor => theme.scaffoldBackgroundColor;

  Color get surfaceColor => colorScheme.surface;

  Color get cardColor => theme.cardColor;

  Color get textPrimary => colorScheme.onSurface;

  Color get textSecondary => colorScheme.onSurfaceVariant;

  Color get textLight =>
      isDark ? AppColors.textLightColorDark : AppColors.textLightColor;

  Color get hintColor =>
      isDark ? AppColors.textHintColorDark : AppColors.textHintColor;

  Color get borderColor => colorScheme.outline;

  Color get dividerColor => theme.dividerColor;

  Color get successColor => AppColors.successColor;

  Color get errorColor => colorScheme.error;

  Color get warningColor => AppColors.warningColor;

  Color get infoColor => AppColors.infoColor;

  Color get buttonPrimaryColor => colorScheme.primary;

  Color get buttonTextColor => colorScheme.onPrimary;

  Color get iconPrimaryColor => colorScheme.primary;

  Color get iconSecondaryColor => colorScheme.onSurfaceVariant;
}
