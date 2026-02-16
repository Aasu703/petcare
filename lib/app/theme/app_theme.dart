import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

/// Returns the light theme for the application
ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: false,
    fontFamily: 'Open Sans',

    // Primary Colors
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.buttonTextColor),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: AppColors.buttonTextColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Nunito',
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 18,
          color: AppColors.buttonTextColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'Open Sans',
        ),
        backgroundColor: AppColors.buttonPrimaryColor,
        foregroundColor: AppColors.buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Open Sans',
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Open Sans',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textHintColor,
        fontFamily: 'Open Sans',
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textHintColor,
        fontFamily: 'Open Sans',
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.iconPrimaryColor, size: 24),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceColor,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.iconSecondaryColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Open Sans',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'Open Sans',
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.buttonTextColor,
      elevation: 4,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Nunito',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Nunito',
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Nunito',
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Nunito',
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Nunito',
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Nunito',
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Open Sans',
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Open Sans',
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Open Sans',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColor,
        fontFamily: 'Open Sans',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColor,
        fontFamily: 'Open Sans',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textLightColor,
        fontFamily: 'Open Sans',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Open Sans',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        fontFamily: 'Open Sans',
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textLightColor,
        fontFamily: 'Open Sans',
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.overlayColor,
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.buttonTextColor,
        fontFamily: 'Open Sans',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Returns the dark theme for the application
ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: false,
    fontFamily: 'Open Sans',

    // Primary Colors
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColorDark,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.buttonTextColor),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: AppColors.buttonTextColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Nunito',
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 18,
          color: AppColors.buttonTextColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'Open Sans',
        ),
        backgroundColor: AppColors.buttonPrimaryColor,
        foregroundColor: AppColors.buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Open Sans',
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Open Sans',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceColorDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: AppColors.borderColorDark,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: AppColors.borderColorDark,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textHintColorDark,
        fontFamily: 'Open Sans',
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textHintColorDark,
        fontFamily: 'Open Sans',
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.iconPrimaryColor, size: 24),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceColorDark,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.iconSecondaryColorDark,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Open Sans',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'Open Sans',
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.buttonTextColor,
      elevation: 4,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Nunito',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Nunito',
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Nunito',
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Nunito',
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Nunito',
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Nunito',
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Open Sans',
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Open Sans',
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Open Sans',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColorDark,
        fontFamily: 'Open Sans',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColorDark,
        fontFamily: 'Open Sans',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textLightColorDark,
        fontFamily: 'Open Sans',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Open Sans',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColorDark,
        fontFamily: 'Open Sans',
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textLightColorDark,
        fontFamily: 'Open Sans',
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.overlayColorDark,
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.buttonTextColor,
        fontFamily: 'Open Sans',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
