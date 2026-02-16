import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider (persistent)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeModeKey = 'theme_mode';

  @override
  ThemeMode build() {
    // Default to system until loaded from storage
    _loadSavedThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModeKey);
    if (stored == null) return;
    state = _stringToThemeMode(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
  }

  Future<void> setLight() => setThemeMode(ThemeMode.light);
  Future<void> setDark() => setThemeMode(ThemeMode.dark);
  Future<void> setSystem() => setThemeMode(ThemeMode.system);

  Future<void> toggle() async {
    if (state == ThemeMode.dark) {
      await setLight();
    } else {
      await setDark();
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

// Helpful WidgetRef extensions to read and control theme from widgets
extension ThemeRefX on WidgetRef {
  ThemeMode get themeMode => watch(themeModeProvider);

  bool isDarkMode(BuildContext context) {
    final mode = themeMode;
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    // system
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  Future<void> setLight() => read(themeModeProvider.notifier).setLight();
  Future<void> setDark() => read(themeModeProvider.notifier).setDark();
  Future<void> setSystem() => read(themeModeProvider.notifier).setSystem();
  Future<void> toggleTheme() => read(themeModeProvider.notifier).toggle();
}
