import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

ThemeData getLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
    brightness: Brightness.light,
    primary: AppColors.primaryColor,
    secondary: AppColors.accentColor,
    tertiary: AppColors.tertiaryColor,
    surface: AppColors.surfaceColor,
    onSurface: AppColors.textPrimaryColor,
    onSurfaceVariant: AppColors.textSecondaryColor,
    error: AppColors.errorColor,
  );

  return _buildTheme(
    scheme: scheme,
    scaffoldColor: AppColors.backgroundColor,
    hintColor: AppColors.textHintColor,
  );
}

ThemeData getDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryLightColor,
    brightness: Brightness.dark,
    primary: AppColors.primaryLightColor,
    secondary: AppColors.accentColor,
    tertiary: AppColors.tertiaryColor,
    surface: AppColors.surfaceColorDark,
    onSurface: AppColors.textPrimaryColorDark,
    onSurfaceVariant: AppColors.textSecondaryColorDark,
    error: AppColors.errorColor,
  );

  return _buildTheme(
    scheme: scheme,
    scaffoldColor: AppColors.backgroundColorDark,
    hintColor: AppColors.textHintColorDark,
  );
}

ThemeData _buildTheme({
  required ColorScheme scheme,
  required Color scaffoldColor,
  required Color hintColor,
}) {
  final isDark = scheme.brightness == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffoldColor,
    fontFamily: 'OpenSans',
  );

  final textTheme = base.textTheme
      .apply(
        fontFamily: 'OpenSans',
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      )
      .copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
        displayMedium: base.textTheme.displayMedium?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.35),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
        bodySmall: base.textTheme.bodySmall?.copyWith(height: 1.35),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        labelMedium: base.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      );

  final roundedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  return base.copyWith(
    primaryColor: scheme.primary,
    textTheme: textTheme,
    iconTheme: IconThemeData(color: scheme.primary, size: 22),
    dividerColor: isDark ? AppColors.dividerColorDark : AppColors.dividerColor,
    dividerTheme: DividerThemeData(
      color: isDark ? AppColors.dividerColorDark : AppColors.dividerColor,
      thickness: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontSize: 22,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: isDark ? AppColors.shadowColorDark : AppColors.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.borderColorDark : AppColors.borderColor,
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      textColor: scheme.onSurface,
      shape: roundedShape,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: textTheme.bodyMedium?.copyWith(color: hintColor),
      hintStyle: textTheme.bodyMedium?.copyWith(color: hintColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderColorDark : AppColors.borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderColorDark : AppColors.borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      prefixIconColor: scheme.primary,
      suffixIconColor: hintColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: isDark
            ? AppColors.disabledColorDark
            : AppColors.disabledColor,
        disabledForegroundColor: scheme.onPrimary.withOpacity(0.7),
        shape: roundedShape,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        shape: roundedShape,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary, width: 1.5),
        shape: roundedShape,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: scheme.surface,
      selectedColor: scheme.primary.withOpacity(0.14),
      disabledColor: (isDark ? AppColors.disabledColorDark : AppColors.disabledColor)
          .withOpacity(0.6),
      side: BorderSide(
        color: isDark ? AppColors.borderColorDark : AppColors.borderColor,
      ),
      labelStyle: textTheme.labelMedium?.copyWith(color: scheme.onSurface),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: scheme.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: scheme.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurfaceVariant,
      elevation: 0,
      selectedLabelStyle: textTheme.labelSmall,
      unselectedLabelStyle: textTheme.labelSmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: scheme.surface.withOpacity(0.96),
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withOpacity(0.14),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: scheme.primary);
        }
        return IconThemeData(color: scheme.onSurfaceVariant);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        final selected = states.contains(MaterialState.selected);
        return textTheme.labelSmall?.copyWith(
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        );
      }),
      height: 70,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.secondary,
      foregroundColor: scheme.onSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? AppColors.overlayColorDark : AppColors.overlayColor,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.buttonTextColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
