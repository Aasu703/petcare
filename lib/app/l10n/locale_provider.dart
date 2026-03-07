import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppLocaleNotifier extends Notifier<Locale> {
  static const String _localeKey = 'app_locale';
  static const Locale _english = Locale('en');
  static const Locale _nepali = Locale('ne');

  @override
  Locale build() {
    _loadSavedLocale();
    return _english;
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localeKey);
    if (stored == null) {
      return;
    }
    state = _fromCode(stored);
  }

  Future<void> setEnglish() => _setLocale(_english);

  Future<void> setNepali() => _setLocale(_nepali);

  Future<void> toggleEnglishNepali() async {
    if (state.languageCode == _nepali.languageCode) {
      await setEnglish();
      return;
    }
    await setNepali();
  }

  Future<void> _setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Locale _fromCode(String languageCode) {
    if (languageCode == _nepali.languageCode) {
      return _nepali;
    }
    return _english;
  }
}
