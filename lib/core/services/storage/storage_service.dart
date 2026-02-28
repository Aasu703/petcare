import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  // Double
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);

  // Boolean
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  // StringList
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // remove & clear
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // Check if key exists
  bool containsKey(String key) => _prefs.containsKey(key);
}
