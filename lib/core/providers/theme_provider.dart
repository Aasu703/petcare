import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';

/// Theme mode provider that manages light/dark theme switching
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return _loadThemeMode(prefs);
  }

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final themeString = prefs.getString(_themeKey);
    if (themeString == 'dark') {
      return ThemeMode.dark;
    } else if (themeString == 'light') {
      return ThemeMode.light;
    }
    return ThemeMode.light; // Default to light theme
  }

  Future<void> toggleTheme() async {
    final prefs = ref.read(sharedPrefsProvider);
    final newThemeMode = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    state = newThemeMode;
    await prefs.setString(_themeKey, newThemeMode.name);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = ref.read(sharedPrefsProvider);
    state = themeMode;
    await prefs.setString(_themeKey, themeMode.name);
  }
}
